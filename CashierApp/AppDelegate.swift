  //
  //  AppDelegate.swift
  //  Sample
  //
  //  Created by Jörn Schmidt on 16.05.15.
  //  Copyright (c) 2015 devid. All rights reserved.
  //
  
  import Foundation
  import UIKit
  import SecucardConnectSDK
  import SwiftyJSON
  import HockeySDK
  
  @UIApplicationMain
  class AppDelegate: UIResponder, UIApplicationDelegate, InitializationViewDelegate {
    
    var window: UIWindow?
    var products: JSON?
    var mainController: MainViewController!
    var connectClient: SCConnectClient?
    var verificationView: InsertCodeView?
    var pollingTimer: NSTimer?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
      
      // integrate HockeyApp
      BITHockeyManager.sharedHockeyManager().configureWithIdentifier("6092e83f751fc2e16cd727b6af7f9411")
      BITHockeyManager.sharedHockeyManager().updateManager.alwaysShowUpdateReminder = false
      BITHockeyManager.sharedHockeyManager().startManager()
      BITHockeyManager.sharedHockeyManager().authenticator.authenticateInstallation()
      
      // notification oberservers
      NSNotificationCenter.defaultCenter().addObserver(self, selector: "showDeviceAuthInformation:", name: "deviceAuthCodeRequesting", object: nil)
      NSNotificationCenter.defaultCenter().addObserver(self, selector: "logAnyEvent:", name: "notificationStompEvent", object: nil)
      
      NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("stompConnectionChanged"), name: "stompConnected", object: nil)
      NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("stompConnectionChanged"), name: "stompDisconnected", object: nil)
      
      // read data
      if let path = NSBundle.mainBundle().pathForResource("products", ofType: "json") {
        
        if let data = NSData(contentsOfFile: path) {
          
          var parsingError: NSError?
          products = JSON(data: data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError)
          
          if let parsingError = parsingError {
            
            SCLogManager.error(parsingError)
            
          }
          
        }
      }
      
    
      // initialize view
      mainController = MainViewController()
      
      // with parsed data if avaliable
      if let parsedProducts = products {
        mainController.json = parsedProducts
      }
      
      // show window and initial view controller
      window = UIWindow(frame: UIScreen.mainScreen().bounds)
      window?.rootViewController = self.mainController
      window?.makeKeyAndVisible()
      
      connectCashier { (success: Bool, error: NSError?) -> Void in
        
        if let error = error {
          SCLogManager.error(error)
        }
        
      }
      
      return true
    }
    
    func connectCashier( handler: (success: Bool, error: NSError?) -> Void ) -> Void {
      
      // if still connected return fail gracefully
      guard !SCConnectClient.sharedInstance().connected else {
        handler(success: true, error: nil)
        return
      }
      
      // check if all information for initialization ist there
      let clientId = NSUserDefaults.standardUserDefaults().stringForKey(DefaultsKeys.ClientId.rawValue)
      let clientSecret = NSUserDefaults.standardUserDefaults().stringForKey(DefaultsKeys.ClientSecret.rawValue)
      let uuid = NSUserDefaults.standardUserDefaults().stringForKey(DefaultsKeys.UUID.rawValue)
      
      var server = NSUserDefaults.standardUserDefaults().stringForKey(DefaultsKeys.Server.rawValue)
      if server == nil {
        server = Constants.serverData[0]
        NSUserDefaults.standardUserDefaults().setObject(server, forKey: DefaultsKeys.Server.rawValue)
      }
      
      // if there are missing credientials, show the view and fail gracefully
      guard clientId != nil && clientSecret != nil && uuid != nil && server != nil else {
        
        let initView = InitializationView()
        initView.delegate = self
        
        if let window = window  {
          window.addSubview(initView)
          initView.somethingChanged = true
          initView.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(window)
          }
        }
        
        return;
        
      }
      
      // initialize connect client
      
      let restConfig: SCRestConfiguration = SCRestConfiguration(baseUrl: "\(server!)\(Constants.apiString)", andAuthUrl: "\(server!)")
      
      let stompConfig: SCStompConfiguration = SCStompConfiguration(host: Constants.stompHost, andVHost: Constants.stompVHost, port: Constants.stompPort, userId: "", password: "", useSSL: true, replyQueue: Constants.replyQueue, connectionTimeoutSec: Constants.connectionTimeoutSec, socketTimeoutSec: Constants.socketTimeoutSec, heartbeatMs: Constants.heartbeatMs, basicDestination: Constants.basicDestination)
      
      let clientCredentials: SCClientCredentials = SCClientCredentials(clientId: clientId, clientSecret: clientSecret)
      
      let clientConfig: SCClientConfiguration = SCClientConfiguration(restConfiguration: restConfig, stompConfiguration: stompConfig, defaultChannel: OnDemandChannel, stompEnabled: true, oauthUrl: "\(server!)", clientCredentials: clientCredentials, userCredentials: SCUserCredentials(), deviceId: uuid, authType: "device")
      
      // connect to server and try to login
      if let client = SCConnectClient.sharedInstance() {
        
        client.initWithConfiguration(clientConfig)
        
        // only when connecting we request auth code, so we have to do that directly
        if SCAccountManager.sharedManager().accessToken == nil {
          
          SCAccountManager.sharedManager().requestTokenWithDeviceAuth({ (token: String!, error: NSError!) -> Void in
            
            self.connectWhenSave(handler)
            
          })
          
        } else {
          
          SCAccountManager.sharedManager().token({ (token: String!, error: NSError!) -> Void in
            
            self.connectWhenSave(handler)
            
          })
          
        }
        
      }
      
    }
    
    func connectWhenSave( handler: (success: Bool, error: NSError?) -> Void ) -> Void {
      
      if let client = SCConnectClient.sharedInstance() {
        
        client.connect({ (success: Bool, error: NSError?) -> Void in
          
          if let error = error {
            handler(success: false, error: error)
          }
          
          if success {
            
            // close verification view
            if let vView = self.verificationView {
              dispatch_async(dispatch_get_main_queue(), { () -> Void in
                vView.hide()
              })
            }
            
            self.pollCheckins()
            
            // Add EventHandlers
            
            
            
            SCCheckinService.sharedService().addEventHandler({ (event: SCGeneralEvent?) -> Void in
              
              if let _ = event {
                self.mainController.logView.addToLog("handled event -> get checkins")
                self.pollCheckins()
              }
              
            })
            
            SCSmartTransactionService.sharedService().addEventHandler({ (event: SCGeneralEvent?) -> Void in
              
              if let _ = event {
                self.mainController.logView.addToLog("handled event -> print notification to transaction status")
              }
              
            })
            
            
            
            NSNotificationCenter.defaultCenter().postNotificationName("clientDidConnect", object: nil)
            
            handler(success: true, error: nil)
            
          } else {
            
            handler(success: false, error: nil)
            
          }
          
        })
        
      }
      
    }
    
    func clientConnected() -> Bool {
      return SCConnectClient.sharedInstance().connected
    }
    
    func stompConnectionChanged() {
      
      if clientConnected() {
        
        SCLogManager.info("STOMP: Connected")
        
      } else {
        
        SCLogManager.warn("STOMP: Disconnected")
        //reconnectStomp()
        
      }
      
    }
    
    func reconnectStomp() {
      
      if !SCConnectClient.sharedInstance().connected {
        
        SCLogManager.warn("STOMP: Needs reconnect, log back in")
        
        connectCashier({ (success, error) -> Void in
          
          SCLogManager.warn("STOMP: did log back in")
          
        })
        
      } else {
        
        if SCConnectClient.sharedInstance().connected {
          SCLogManager.info("STOMP: Does not need reconnect")
        }
        
      }
      
    }
    
    func pollCheckins() {
      
      // check for checkins
      SCCheckinService.sharedService().getCheckins({ ( result: [AnyObject]?, error: NSError?) -> Void in
        
        if let error = error {
          
          SCLogManager.errorWithDescription("couldn't get checkins because: \(error.localizedDescription)")
          
        } else if let checkins = result as? [SCSmartCheckin] {
          
          dispatch_async(dispatch_get_main_queue(), {
            self.mainController.checkins = checkins
            self.mainController.checkinsCollection.reloadData()
          })
          
        }
        
      });
      
    }
    
    func showDeviceAuthInformation(notification : NSNotification) {
      
      if let code: SCAuthDeviceAuthCode = notification.userInfo?["code"] as? SCAuthDeviceAuthCode {
        
        if let w = window {
          
          verificationView = InsertCodeView(authCode: code)
          
          if let verificationView = verificationView {
            
            w.addSubview(verificationView)
            
            verificationView.snp_makeConstraints { (make) -> Void in
              make.edges.equalTo(w)
            }
            
          }
          
        }
        
      }
      
    }
    
    func logAnyEvent(notification: NSNotification) {
      
      if let event = notification.userInfo?["event"] as? SCGeneralEvent {
        
        mainController.logView.addEventToLog(event)
        
      }
      
    }
    
    func didSaveCredentials() {
      
      SCConnectClient.sharedInstance().logoff { (success: Bool, error: NSError!) -> Void in
        
        if (success) {
          NSNotificationCenter.defaultCenter().postNotificationName("clientDidDisconnect", object: nil)
        }
        
                self.connectCashier { (success, error) -> Void in
        
                  if let error = error {
                    SCLogManager.error(error)
                  }
                }
        
      }
      
      
    }
    
    func applicationWillResignActive(application: UIApplication) {
      // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
      // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
      // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
      // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
      // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
      // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
      // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
  }
  
