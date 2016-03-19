//
//  TransactionStatusView.swift
//  SecucardConnectClientLib
//
//  Created by Jörn Schmidt on 11.06.15.
//  Copyright (c) 2015 Jörn Schmidt. All rights reserved.
//

import UIKit

class TransactionStatusView: UIView {

  let logView = UILabel()
  let cancelButton = UIButton(type: UIButtonType.Custom)
  let logButton = UIButton(type: UIButtonType.Custom)
  
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
    
    logView.font = Constants.statusFont
    logView.textColor = UIColor.whiteColor()
    logView.numberOfLines = 0
    logView.lineBreakMode = NSLineBreakMode.ByWordWrapping
    logView.textAlignment = NSTextAlignment.Center
    
    self.addSubview(logView)
    
    logView.snp_makeConstraints { (make) -> Void in
      make.width.equalTo(self)
      make.centerY.equalTo(self)
    }
    
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
    
    logButton.hidden = true
    logButton.setTitle("Log", forState: UIControlState.Normal)
    logButton.addTarget(self, action: "didTapLog", forControlEvents: UIControlEvents.TouchUpInside)
    logButton.backgroundColor = Constants.brightGreyColor
    logButton.setTitleColor(Constants.textColor, forState: UIControlState.Normal)
    self.addSubview(logButton)
    
    logButton.snp_makeConstraints { (make) -> Void in
      make.left.equalTo(cancelButton.snp_right).offset(10)
      make.width.equalTo(100)
      make.height.equalTo(50)
      make.bottom.equalTo(-10)
    }
    
    UIView.animateWithDuration(0.2, animations: { () -> Void in
      self.alpha = 1
    })
    
  }
  
  func showLogButton(show:Bool) {
    logButton.hidden = !show
  }
  
  func didTapLog() {
    if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
      hide()
      appDelegate.mainController.didTapShowLog()
    }
  }
  
  func addStatus(string: String) {
    
    dispatch_async(dispatch_get_main_queue(), { () -> Void in
      
      UIView.animateWithDuration(0.2, animations: { () -> Void in
        
        self.logView.alpha = 0
        
      }, completion: { (done) -> Void in
        
        self.logView.text = "\(string)"
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
          
          self.logView.alpha = 1
          
        })
        
      })
      
      
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
