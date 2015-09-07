//
//  TransactionStatusView.swift
//  SecucardConnectClientLib
//
//  Created by Jörn Schmidt on 11.06.15.
//  Copyright (c) 2015 Jörn Schmidt. All rights reserved.
//

import UIKit

class TransactionStatusView: UIView {

  let logView: UITextView = UITextView()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
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
      make.left.equalTo(50)
      make.edges.equalTo(self).inset(UIEdgeInsetsMake(50, 50, 50, 50))
      make.centerY.equalTo(self)
    }
    
    var titleLabel: UILabel = UILabel()
    titleLabel.text = "Transaktionsstatus"
    titleLabel.font = UIFont.systemFontOfSize(24)
    centerView.addSubview(titleLabel)
    
    titleLabel.snp_makeConstraints { (make) -> Void in
      make.top.left.equalTo(20)
      make.right.equalTo(-20)
      make.height.equalTo(30)
    }
    
    logView.editable = false
    logView.scrollEnabled = true
    logView.font = Constants.regularFont
    centerView.addSubview(logView)
    
    logView.snp_makeConstraints { (make) -> Void in
      make.edges.equalTo(centerView).inset(UIEdgeInsetsMake(50, 20, 70, 20))
    }
    
    let cancelButton: UIButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
    cancelButton.setTitle("Schließen", forState: UIControlState.Normal)
    cancelButton.addTarget(self, action: "didTapCancel", forControlEvents: UIControlEvents.TouchUpInside)
    cancelButton.backgroundColor = Constants.brightGreyColor
    cancelButton.setTitleColor(Constants.textColor, forState: UIControlState.Normal)
    centerView.addSubview(cancelButton)
    
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
  
  func addStatus(string: String) {
    
    dispatch_async(dispatch_get_main_queue(), { () -> Void in
      self.logView.text = "\(self.logView.text)\n\(string)"
    })
    
  }
  
  func didTapCancel() {
    hide()
  }
  
  func hide() {
    
    UIView.animateWithDuration(0.4, animations: { () -> Void in
      
      self.alpha = 0
      
      }) { (done) -> Void in
        
        self.removeFromSuperview()
        
    }
  }
  
}
