//
//  InsertCodeView.swift
//  SecucardConnectClientLib
//
//  Created by Jörn Schmidt on 08.06.15.
//  Copyright (c) 2015 Jörn Schmidt. All rights reserved.
//

import UIKit
import SecucardConnectSDK

class InsertCodeView: UIView {

  let priceField: UITextField = UITextField()
  var authCode: SCAuthDeviceAuthCode?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  convenience init(authCode: SCAuthDeviceAuthCode) {
    self.init(frame: CGRectNull)
    self.authCode = authCode
    setupView()
  }
  
  required init(coder aDecoder: NSCoder) {
    fatalError("This class does not support NSCoding")
  }
  
  func setupView() {
    
    alpha = 0;
    
    backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.7)
    
    let centerView: UIView = UIView()
    centerView.backgroundColor = UIColor.whiteColor()
    addSubview(centerView)
    
    centerView.snp_makeConstraints { (make) -> Void in
      make.centerX.equalTo(self)
      make.centerY.equalTo(self)
      make.width.equalTo(500)
      make.height.equalTo(250)
    }
    
    var titleLabel: UILabel = UILabel()
    titleLabel.text = "Geräteverifikation"
    titleLabel.font = UIFont.systemFontOfSize(24)
    centerView.addSubview(titleLabel)
    
    titleLabel.snp_makeConstraints { (make) -> Void in
      make.top.left.equalTo(10)
      make.right.equalTo(-10)
      make.height.equalTo(30)
    }
    
    var subtitleLabel: UITextView = UITextView()
    subtitleLabel.editable = false
    subtitleLabel.text = "Bitte verifizieren Sie das Gerät mit dem Code \(authCode!.userCode) unter der Website \(authCode!.verificationUrl)"
    subtitleLabel.font = Constants.headlineFont
    centerView.addSubview(subtitleLabel)
    
    subtitleLabel.snp_makeConstraints { (make) -> Void in
      make.left.equalTo(10)
      make.top.equalTo(titleLabel.snp_bottom).offset(20)
      make.right.equalTo(-10)
      make.height.equalTo(100)
    }
    
    let cancelButton: UIButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
    cancelButton.setTitle("Schließen", forState: UIControlState.Normal)
    cancelButton.addTarget(self, action: "didTapCancel", forControlEvents: UIControlEvents.TouchUpInside)
    cancelButton.backgroundColor = Constants.brightGreyColor
    cancelButton.setTitleColor(Constants.textColor, forState: UIControlState.Normal)
    self.addSubview(cancelButton)
    
    cancelButton.snp_makeConstraints { (make) -> Void in
      make.left.equalTo(10)
      make.width.equalTo(100)
      make.height.equalTo(50)
      make.bottom.equalTo(-10)
    }

    
    UIView.animateWithDuration(0.4, animations: { () -> Void in
      self.alpha = 1
    })
    
  }
  
  internal func didTapCancel() {
    
    hide()
  }
  
  internal func hide() {
    
    UIView.animateWithDuration(0.4, animations: { () -> Void in
      
      self.alpha = 0
      
      }) { (done) -> Void in
        
        self.removeFromSuperview()
        
    }
  }
  
}
