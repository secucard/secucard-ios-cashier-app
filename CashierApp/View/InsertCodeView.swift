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
  
  let centerView = UIView()
  let subtitleLabel = UITextView()
  let cancelButton = UIButton(type: UIButtonType.Custom)
  
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
    
    centerView.backgroundColor = UIColor.whiteColor()
    addSubview(centerView)
    
    centerView.snp_makeConstraints { (make) -> Void in
      make.centerX.equalTo(self)
      make.centerY.equalTo(self)
      make.width.equalTo(500)
      make.height.equalTo(220)
    }
    
    let paragraph = NSMutableParagraphStyle()
    paragraph.lineSpacing = 40
    paragraph.alignment = NSTextAlignment.Center
    
    let helpText = NSMutableAttributedString(string: "Bitte verifizieren Sie das Gerät mit dem Code\n", attributes: [NSFontAttributeName: Constants.headlineFont])
    helpText.appendAttributedString(NSAttributedString(string: authCode!.userCode, attributes: [NSFontAttributeName: Constants.pinFont]))
    helpText.appendAttributedString(NSAttributedString(string: "\nunter der Website \(authCode!.verificationUrl)", attributes: [NSFontAttributeName: Constants.headlineFont]))
    helpText.addAttribute(NSParagraphStyleAttributeName, value: paragraph, range: NSMakeRange(0, helpText.length))
    
    subtitleLabel.editable = false
    subtitleLabel.attributedText = helpText
    centerView.addSubview(subtitleLabel)
    
    subtitleLabel.snp_makeConstraints { (make) -> Void in
      make.edges.equalTo(centerView).inset(UIEdgeInsetsMake(10, 10, 10, 10))
    }
    
    cancelButton.setTitle("Schließen", forState: UIControlState.Normal)
    cancelButton.addTarget(self, action: "didTapCancel", forControlEvents: UIControlEvents.TouchUpInside)
    cancelButton.backgroundColor = Constants.brightGreyColor
    cancelButton.setTitleColor(Constants.textColor, forState: UIControlState.Normal)
    self.addSubview(cancelButton)
    
    cancelButton.snp_makeConstraints { (make) -> Void in
      make.left.equalTo(centerView)
      make.width.equalTo(100)
      make.height.equalTo(50)
      make.top.equalTo(centerView.snp_bottom).offset(10)
    }
    
    UIView.animateWithDuration(0.4, animations: { () -> Void in
      self.alpha = 1
    })
    
  }
  
  internal func didTapCancel() {
    
    SCAccountManager.sharedManager().stopPollingToken()
    
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
