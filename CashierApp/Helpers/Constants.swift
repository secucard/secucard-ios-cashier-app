//
//  Constants.swift
//  CashierApp
//
//  Created by Jörn Schmidt on 02.06.15.
//  Copyright (c) 2015 secucard. All rights reserved.
//

import UIKit

public enum DefaultsKeys : String {
  case ClientId = "clientId"
  case ClientSecret = "clientSecret"
  case UUID = "uuid"
  case Server = "server"
}

public enum ProtocolType : String {
  case Https = "https://"
  case Http = "http://"
  
  var string: String {
    return self.rawValue
  }
  
}

public enum DeviceAuthHosts : String {
  case Live       = "http://www.secuoffice.com/"
  case Dev1       = "core-dev1.secupay-ag.de/app.main"
  case Dev2       = "core-dev2.secupay-ag.de/app.main"
  case Dev3       = "core-dev3.secupay-ag.de/app.main"
  case Dev4       = "core-dev4.secupay-ag.de/app.main"
  case Dev5       = "core-dev5.secupay-ag.de/app.main"
  case Dev6       = "core-dev6.secupay-ag.de/app.main"
  case Dev7       = "core-dev7.secupay-ag.de/app.main"
  case Dev8       = "core-dev8.secupay-ag.de/app.main"
  case Dev9       = "core-dev9.secupay-ag.de/app.main"
  case Dev10      = "core-dev10.secupay-ag.de/app.main"
  case Testing    = "core-testing.secupay-ag.de/app.main"
  
  static var all: [DeviceAuthHosts] {
    return [.Live, .Dev1, .Dev2, .Dev3, .Dev4, .Dev5, .Dev6, .Dev7, .Dev8, .Dev9, .Dev10, .Testing]
  }
  
  static var allStrings: [String] {
    return [DeviceAuthHosts.Live.string, DeviceAuthHosts.Dev1.string, DeviceAuthHosts.Dev2.string, DeviceAuthHosts.Dev3.string, DeviceAuthHosts.Dev4.string, DeviceAuthHosts.Dev5.string, DeviceAuthHosts.Dev6.string, DeviceAuthHosts.Dev7.string, DeviceAuthHosts.Dev8.string, DeviceAuthHosts.Dev9.string, DeviceAuthHosts.Dev10.string, DeviceAuthHosts.Testing.string]
  }
  
  var string: String {
    return self.rawValue
  }
  
  
}


public enum AvailableHosts : String {
  case Live       = "connect.secucard.com"
  case Dev1       = "connect-dev1.secupay-ag.de"
  case Dev2       = "connect-dev2.secupay-ag.de"
  case Dev3       = "connect-dev3.secupay-ag.de"
  case Dev4       = "connect-dev4.secupay-ag.de"
  case Dev5       = "connect-dev5.secupay-ag.de"
  case Dev6       = "connect-dev6.secupay-ag.de"
  case Dev7       = "connect-dev7.secupay-ag.de"
  case Dev8       = "connect-dev8.secupay-ag.de"
  case Dev9       = "connect-dev9.secupay-ag.de"
  case Dev10      = "connect-dev10.secupay-ag.de"
  case Testing    = "connect-testing.secupay-ag.de"
  
  static var all: [AvailableHosts] {
    return [.Live, .Dev1, .Dev2, .Dev3, .Dev4, .Dev5, .Dev6, .Dev7, .Dev8, .Dev9, .Dev10, .Testing]
  }
  
  static var allStrings: [String] {
    return [AvailableHosts.Live.string, AvailableHosts.Dev1.string, AvailableHosts.Dev2.string, AvailableHosts.Dev3.string, AvailableHosts.Dev4.string, AvailableHosts.Dev5.string, AvailableHosts.Dev6.string, AvailableHosts.Dev7.string, AvailableHosts.Dev8.string, AvailableHosts.Dev9.string, AvailableHosts.Dev10.string, AvailableHosts.Testing.string]
  }
  
  var string: String {
    return self.rawValue
  }
  
  var deviceAuthHost: String {
    
    for var i = 0; i < AvailableHosts.all.count; i++ {
      if AvailableHosts.all[i] == self {
        return DeviceAuthHosts.allStrings[i]
      }
    }
    
    return ""
    
  }
  
  static func byString(string:String) -> AvailableHosts {
    
    for var i = 0; i < AvailableHosts.allStrings.count; i++ {
      if AvailableHosts.allStrings[i] == string {
        return AvailableHosts.all[i]
      }
    }
    
    return .Live
    
  }
}


class Constants: NSObject {
  
  // API Settings
  
  static var baseUrl:String {
    return currentProtocol.string + currentHost.string + "/"
  }
  
  static var apiBaseUrl:String {
    return currentProtocol.string + currentHost.string + "/" + apiString
  }
  
  static var currentProtocol: ProtocolType = .Https
  static var currentHost: AvailableHosts {
    get {
      var serverName = NSUserDefaults.standardUserDefaults().stringForKey(DefaultsKeys.Server.rawValue)
      if serverName == nil {
        serverName = AvailableHosts.allStrings[0]
        NSUserDefaults.standardUserDefaults().setObject(serverName, forKey: DefaultsKeys.Server.rawValue)
      }
      return AvailableHosts.byString(serverName!)
    }
    set {
      NSUserDefaults.standardUserDefaults().setObject(newValue.string, forKey: DefaultsKeys.Server.rawValue)
    }
  }
  
  static let apiString: String = "api/v2/"
  
  static let stompVHost: String = "/"
  static let stompPort: Int32 = 61614
  static let replyQueue: String = "/temp-queue/main"
  static let connectionTimeoutSec: Int32 =   30
  static let socketTimeoutSec: Int32 =   30
  static let heartbeatMs: Int32 =   40000
  static let basicDestination: String = "/exchange/connect.api/"
  
  static let usernameAppSample: String = "checkoutsecucard"
  static let passwordAppSample: String = "checkout"
  static let deviceIdAppSample: String = "611c00ec6b2be6c77c2338774f50040b"
  
  static let clientIdAppSample: String = "app.mobile.secucard"
  static let clientSecretAppSample: String = "dc1f422dde755f0b1c4ac04e7efbd6c4c78870691fe783266d7d6c89439925eb"
  
  static let usernameCashierSample: String = "secucard.dresden"
  static let passwordCashierSample: String = "Kasse12345"
  
//  static let clientIdCashierSample: String = ""
//  static let deviceIdCashierSample: String = ""
//  static let clientSecretCashierSample: String = ""
  
    static let clientIdCashierSample: String = "611c00ec6b2be6c77c2338774f50040b"
    static let deviceIdCashierSample: String = "/vendor/vendor_name/cashier/iostest1"
    static let clientSecretCashierSample: String = "dc1f422dde755f0b1c4ac04e7efbd6c4c78870691fe783266d7d6c89439925eb"
  
  static let contactForename: String = "DeviD"
  static let contactSurname: String = "Testermann"
  static let contactSalutation: String = "Herr"
  static let contactEmail: String = "schmidt@devid.net"
  
  static let accountUsername: String = "schmidtdevid.net"
  static let acccountPassword: String = "Secucard123"
  
  static let merchantRef: String = "KundeXY"
  
  // Colors
  static let tintColor: UIColor = UIColor(red: 63/255, green: 116/255, blue: 164/255, alpha: 1)
  static let tintColorBright: UIColor = UIColor(red: 146/255, green: 186/255, blue: 224/255, alpha: 1)
  static let textColor: UIColor = UIColor.darkGrayColor()
  static let textColorBright: UIColor = UIColor.whiteColor()
  static let paneBgColor: UIColor = UIColor.whiteColor()

  static let paneBorderColor: UIColor = UIColor(red: 190/255, green: 190/255, blue: 190/255, alpha: 1)
  static let brightGreyColor: UIColor = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1)
  static let darkGreyColor: UIColor = UIColor(red: 55/255, green: 55/255, blue: 55/255, alpha: 1)
  
  static let warningColor: UIColor = UIColor.orangeColor()
  static let greenColor: UIColor = UIColor(red: 130/255, green: 202/255, blue: 56/255, alpha: 1)
  static let redColor: UIColor = UIColor(red: 209/255, green: 66/255, blue: 58/255, alpha: 1)
  
  // Fontsizes
  static let regularFont = UIFont.systemFontOfSize(12.0)
  static let headlineFont = UIFont.systemFontOfSize(16.0)
  static let settingFont = UIFont.systemFontOfSize(14.0)
  static let sumFont = UIFont.systemFontOfSize(18.0)
  static let statusFont = UIFont.systemFontOfSize(28.0)
  static let pinFont = UIFont.systemFontOfSize(40.0)
  
//  static let receiptHeadingFont = UIFont.init(name: "HiraKakuProN-W3", size: 16)
//  static let receiptRegularFont = UIFont.init(name: "HiraKakuProN-W3", size: 14)
//  static let receiptBoldFont = UIFont.init(name: "HiraKakuProN-W6", size: 14)
  
  static let receiptHeadingFont = UIFont.systemFontOfSize(16)
  static let receiptRegularFont = UIFont.systemFontOfSize(14)
  static let receiptBoldFont = UIFont.boldSystemFontOfSize(14)
  
}
