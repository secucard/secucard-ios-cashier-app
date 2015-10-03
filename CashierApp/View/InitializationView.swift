//
//  InitializationView.swift
//  SecucardConnectClientLib
//
//  Created by Jörn Schmidt on 11.06.15.
//  Copyright (c) 2015 Jörn Schmidt. All rights reserved.
//

import UIKit
import SecucardConnectSDK

protocol InitializationViewDelegate {
  func didSaveCredentials()
}

class InitializationView: UIView, UITextFieldDelegate {

  let titleLabel = UILabel()
  
  let clientIdLabel = UILabel()
  let clientIdField = UITextField()
  
  let clientSecretLabel = UILabel()
  let clientSecretField = UITextField()
  
  let uuidLabel = UILabel()
  let uuidField = UITextField()
  
  let cancelButton = UIButton(type: UIButtonType.Custom)
  let logoffButton = UIButton(type: UIButtonType.Custom)
  let okButton = UIButton(type: UIButtonType.Custom)
  
  var delegate: InitializationViewDelegate?
  
  var somethingChanged = false {
    didSet {
      okButton.enabled = somethingChanged
      okButton.alpha = somethingChanged ? 1 : 0.5
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }
  
  required init(coder aDecoder: NSCoder) {
    fatalError("This class does not support NSCoding")
  }
  
  func setupView() {
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("connectionChanged"), name: "clientDidDisconnect", object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("connectionChanged"), name: "clientDidConnect", object: nil)
    
    alpha = 0;
    backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.7)
    
    let centerView: UIView = UIView()
    centerView.backgroundColor = UIColor.whiteColor()
    addSubview(centerView)
    
    centerView.snp_makeConstraints { (make) -> Void in
      make.width.equalTo(500)
      make.height.equalTo(300)
      make.centerX.equalTo(self)
      make.top.equalTo(50)
    }
    
    titleLabel.text = "Kasseneinstellungen"
    titleLabel.font = UIFont.systemFontOfSize(24)
    centerView.addSubview(titleLabel)
    
    titleLabel.snp_makeConstraints { (make) -> Void in
      make.top.left.equalTo(20)
      make.right.equalTo(-20)
      make.height.equalTo(30)
    }
    
    clientIdLabel.text = "Client Id"
    clientIdLabel.font = Constants.headlineFont
    centerView.addSubview(clientIdLabel)
    
    clientIdLabel.snp_makeConstraints { (make) -> Void in
      make.left.equalTo(20)
      make.top.equalTo(titleLabel.snp_bottom).offset(20)
      make.width.equalTo(100)
      make.height.equalTo(30)
    }
    
    clientIdField.font = Constants.settingFont
    clientIdField.layer.borderWidth = 1
    clientIdField.returnKeyType = UIReturnKeyType.Done
    clientIdField.delegate = self
    clientIdField.layer.borderColor = Constants.darkGreyColor.CGColor

    if let clientId = NSUserDefaults.standardUserDefaults().objectForKey(DefaultsKeys.ClientId.rawValue) as? String {
      clientIdField.text = clientId
    } else {
      clientIdField.text = Constants.clientIdCashierSample
    }
    
    centerView.addSubview(clientIdField)
    
    let idFieldSpacer = UIView(frame: CGRectMake(0, 0, 5, 5))
    clientIdField.leftViewMode = UITextFieldViewMode.Always
    clientIdField.leftView = idFieldSpacer
    
    clientIdField.snp_makeConstraints { (make) -> Void in
      make.left.equalTo(clientIdLabel.snp_right).offset(20)
      make.top.equalTo(clientIdLabel)
      make.right.equalTo(-20)
      make.height.equalTo(30)
    }
    
    // client secret
    
    clientSecretLabel.text = "Client Secret"
    clientSecretLabel.font = Constants.headlineFont
    centerView.addSubview(clientSecretLabel)
    
    clientSecretLabel.snp_makeConstraints { (make) -> Void in
      make.left.equalTo(20)
      make.top.equalTo(clientIdLabel.snp_bottom).offset(20)
      make.width.equalTo(100)
      make.height.equalTo(30)
    }
    
    clientSecretField.font = Constants.settingFont
    clientSecretField.layer.borderWidth = 1
    clientSecretField.returnKeyType = UIReturnKeyType.Done
    clientSecretField.delegate = self
    clientSecretField.layer.borderColor = Constants.darkGreyColor.CGColor
    
    let secretFieldSpacer = UIView(frame: CGRectMake(0, 0, 5, 5))
    clientSecretField.leftViewMode = UITextFieldViewMode.Always
    clientSecretField.leftView = secretFieldSpacer
    
    if let secret = NSUserDefaults.standardUserDefaults().objectForKey(DefaultsKeys.ClientSecret.rawValue) as? String {
      clientSecretField.text = secret
    } else {
      clientSecretField.text = Constants.clientSecretCashierSample
    }
    
    centerView.addSubview(clientSecretField)
    
    clientSecretField.snp_makeConstraints { (make) -> Void in
      make.left.equalTo(clientSecretLabel.snp_right).offset(20)
      make.top.equalTo(clientSecretLabel)
      make.right.equalTo(-20)
      make.height.equalTo(30)
    }
    
    // uuid

    uuidLabel.text = "UUID"
    uuidLabel.font = Constants.headlineFont
    centerView.addSubview(uuidLabel)
    
    uuidLabel.snp_makeConstraints { (make) -> Void in
      make.left.equalTo(20)
      make.top.equalTo(clientSecretLabel.snp_bottom).offset(20)
      make.width.equalTo(100)
      make.height.equalTo(30)
    }
    
    uuidField.font = Constants.settingFont
    uuidField.layer.borderWidth = 1
    uuidField.returnKeyType = UIReturnKeyType.Done
    uuidField.delegate = self
    uuidField.layer.borderColor = Constants.darkGreyColor.CGColor
    
    let uuidFieldSpacer = UIView(frame: CGRectMake(0, 0, 5, 5))
    uuidField.leftViewMode = UITextFieldViewMode.Always
    uuidField.leftView = uuidFieldSpacer
    
    if let uuid = NSUserDefaults.standardUserDefaults().objectForKey(DefaultsKeys.UUID.rawValue) as? String {
      uuidField.text = uuid
    } else {
      uuidField.text = Constants.deviceIdCashierSample
    }
    
    centerView.addSubview(uuidField)
    
    uuidField.snp_makeConstraints { (make) -> Void in
      make.left.equalTo(uuidLabel.snp_right).offset(20)
      make.top.equalTo(uuidLabel)
      make.right.equalTo(-20)
      make.height.equalTo(30)
    }
    
    // Buttons
    
    cancelButton.setTitle("Abbrechen", forState: UIControlState.Normal)
    cancelButton.addTarget(self, action: "didTapCancel", forControlEvents: UIControlEvents.TouchUpInside)
    cancelButton.backgroundColor = Constants.tintColor
    centerView.addSubview(cancelButton)
    
    cancelButton.snp_makeConstraints { (make) -> Void in
      make.left.equalTo(10)
      make.width.equalTo(100)
      make.height.equalTo(50)
      make.bottom.equalTo(-10)
    }
    
    logoffButton.setTitle("Abmelden", forState: UIControlState.Normal)
    logoffButton.addTarget(self, action: "didTapLogoff", forControlEvents: UIControlEvents.TouchUpInside)
    logoffButton.backgroundColor = Constants.warningColor
    centerView.addSubview(logoffButton)
    
    logoffButton.snp_makeConstraints { (make) -> Void in
      make.left.equalTo(cancelButton.snp_right).offset(10)
      make.width.equalTo(100)
      make.height.equalTo(50)
      make.bottom.equalTo(-10)
    }
    
    logoffButton.enabled = SCConnectClient.sharedInstance().connected
    logoffButton.alpha = SCConnectClient.sharedInstance().connected ? 1.0 : 0.5
    
    okButton.setTitle("Speichern", forState: UIControlState.Normal)
    okButton.addTarget(self, action: "didTapSend", forControlEvents: UIControlEvents.TouchUpInside)
    okButton.backgroundColor = Constants.tintColor
    centerView.addSubview(okButton)
    
    okButton.snp_makeConstraints { (make) -> Void in
      make.right.equalTo(-10)
      make.width.equalTo(100)
      make.height.equalTo(50)
      make.bottom.equalTo(-10)
    }
    
    okButton.enabled = somethingChanged
    okButton.alpha = somethingChanged ? 1 : 0.5
    
    UIView.animateWithDuration(0.4, animations: { () -> Void in
      self.alpha = 1
    })
    
  }
  
  // Button handlers
  
  func didTapSend() {
    
    if (checkFields()) {
      
      NSUserDefaults.standardUserDefaults().setObject(clientIdField.text, forKey: DefaultsKeys.ClientId.rawValue)
      NSUserDefaults.standardUserDefaults().setObject(clientSecretField.text, forKey: DefaultsKeys.ClientSecret.rawValue)
      NSUserDefaults.standardUserDefaults().setObject(uuidField.text, forKey: DefaultsKeys.UUID.rawValue)

      delegate?.didSaveCredentials()
      
      hide()
      
    }
    
  }
  
  func didTapCancel() {
    
    hide()
    
  }
  
  func didTapLogoff() {
    
      SCConnectClient.sharedInstance().logoff() { (success: Bool, error: NSError!) -> Void in
        if (success) {
          NSNotificationCenter.defaultCenter().postNotificationName("clientDidDisconnect", object: nil)
        }
      }
    
  }
  
  func checkFields() -> Bool {
    
    clientIdField.layer.borderColor = UIColor.whiteColor().CGColor
    clientSecretField.layer.borderColor = UIColor.whiteColor().CGColor
    uuidField.layer.borderColor = UIColor.whiteColor().CGColor
    
    var valid = true
    
    if clientIdField.text == "" {
      valid = false
      clientIdField.layer.borderColor = Constants.warningColor.CGColor
    }
    
    if clientSecretField.text == "" {
      valid = false
      clientSecretField.layer.borderColor = Constants.warningColor.CGColor
    }
    
    if uuidField.text == "" {
      valid = false
      uuidField.layer.borderColor = Constants.warningColor.CGColor
    }
    
    return valid
    
  }
  
  func hide() {
    
    UIView.animateWithDuration(0.4, animations: { () -> Void in
      
      self.alpha = 0
      
      }) { (done) -> Void in
        
        self.removeFromSuperview()
        
    }
  }
  
  // MARK: - UITexFieldDelegate
  
  func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
    self.somethingChanged = true
    return true
  }
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
  
  // notification handler
  
  func connectionChanged() {
    logoffButton.enabled = SCConnectClient.sharedInstance().connected
    logoffButton.alpha = SCConnectClient.sharedInstance().connected ? 1.0 : 0.5
  }
  
}
