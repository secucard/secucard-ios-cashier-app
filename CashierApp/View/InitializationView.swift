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

class InitializationView: UIView, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
  
  let titleLabel = UILabel()
  
  let clientIdLabel = UILabel()
  let clientIdField = TextInputField()
  
  let clientSecretLabel = UILabel()
  let clientSecretField = TextInputField()
  
  let uuidLabel = UILabel()
  let uuidField = TextInputField()
  
  let serverLabel = UILabel()
  let serverField = TextInputField()
  let serverPicker = UIPickerView()
  
  
  
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
  
  var newServer: String? {
    didSet {
      if let newServer = newServer {
        serverField.text = newServer
      }
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
      make.height.equalTo(350)
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
    
    clientIdField.delegate = self
    
    if let clientId = NSUserDefaults.standardUserDefaults().objectForKey(DefaultsKeys.ClientId.rawValue) as? String {
      clientIdField.text = clientId
    } else {
      clientIdField.text = Constants.clientIdCashierSample
    }
    
    centerView.addSubview(clientIdField)
    
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
    
    clientSecretField.delegate = self
    
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
    
    uuidField.delegate = self
    
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
    
    // server picker
    
    serverLabel.font = Constants.headlineFont
    centerView.addSubview(serverLabel)
    
    var server = NSUserDefaults.standardUserDefaults().stringForKey(DefaultsKeys.Server.rawValue)
    if server == nil {
      server = Constants.serverData[0]
      NSUserDefaults.standardUserDefaults().setObject(server, forKey: DefaultsKeys.Server.rawValue)
    }
    
    serverLabel.text = "Server"
    serverLabel.snp_makeConstraints { (make) -> Void in
      make.left.equalTo(20)
      make.top.equalTo(uuidLabel.snp_bottom).offset(20)
      make.width.equalTo(100)
      make.height.equalTo(30)
    }
    
    serverPicker.delegate = self
    serverPicker.dataSource = self
    
    let toolBar = UIToolbar(frame: CGRectMake(0, 0, self.frame.size.width, 50))
    
    let cancelBarButton = UIBarButtonItem(title: "Abbrechen", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("didTapPickerCancel"))
    cancelBarButton.tintColor = UIColor.whiteColor()

    let doneBarButton = UIBarButtonItem(title: "OK", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("didTapPickerOk"))
    doneBarButton.tintColor = UIColor.whiteColor()
    
    let flexibleBarSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)

    toolBar.items = [cancelBarButton, flexibleBarSpace, doneBarButton]
    
    serverField.inputAccessoryView = toolBar
    serverField.inputView = serverPicker
    serverField.text = server
    
    centerView.addSubview(serverField)
    
    serverField.snp_makeConstraints { (make) -> Void in
      make.left.equalTo(serverLabel.snp_right).offset(20)
      make.top.equalTo(serverLabel)
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
  
  func didTapPickerCancel() {
    serverField.resignFirstResponder()
  }
  
  func didTapPickerOk() {
    self.somethingChanged = true
    let row = serverPicker.selectedRowInComponent(0)
    self.newServer = Constants.serverData[row]
    serverField.resignFirstResponder()
  }
  
  func didTapSend() {
    
    if (checkFields()) {
      
      NSUserDefaults.standardUserDefaults().setObject(clientIdField.text, forKey: DefaultsKeys.ClientId.rawValue)
      NSUserDefaults.standardUserDefaults().setObject(clientSecretField.text, forKey: DefaultsKeys.ClientSecret.rawValue)
      NSUserDefaults.standardUserDefaults().setObject(uuidField.text, forKey: DefaultsKeys.UUID.rawValue)
      NSUserDefaults.standardUserDefaults().setObject(newServer, forKey: DefaultsKeys.Server.rawValue)
      
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
  
  // MARK: - UIPickerViewDataSource, UIPickerViewDelegate
  
  func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return Constants.serverData.count
  }
  
  func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return Constants.serverData[row]
  }
  
  func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    
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
