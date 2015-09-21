//
//  ReceiptView.swift
//  CashierApp
//
//  Created by Jörn Schmidt on 21.09.15.
//  Copyright (c) 2015 secucard. All rights reserved.
//

import UIKit
import SecucardConnectSDK

class ReceiptView: UIView {

  let textView = UITextView()
  
  init() {
    super.init(frame: CGRectNull)
    
    backgroundColor = UIColor.whiteColor()
    
    layer.masksToBounds = false;
    layer.shadowColor = UIColor.blackColor().CGColor
    layer.shadowOffset = CGSizeMake(0.0, 20.0)
    layer.shadowOpacity = 1
    
    addSubview(textView)
    textView.font = UIFont(name:"Courier" , size: 16.0)
    textView.snp_makeConstraints { (make) -> Void in
      make.edges.equalTo(self).inset(10)
    }
    
  }

  required init(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    let shadowPath = UIBezierPath(rect: bounds)
    layer.shadowPath = shadowPath.CGPath
    
  }
  
  func addReceiptLine(line: SCSmartReceiptLine) {
    
    if line.type == "separator" {
      
      if let caption = line.value["caption"] as? String {
        
        textView.text = ("\(textView.text)\(caption)\n")
        
      }
      
    } else if line.type == "name-value" {
      
      if let name = line.value["name"] as? String, value = line.value["value"] as? String {
        
        textView.text = ("\(textView.text)\(name): \(value)\n")
        
      }
      
    } else if line.type == "space" {
      
      textView.text = "\(textView.text)\n"
      
    } else {
      
      if let lineText = line.value["text"] as? String {
      
        textView.text = ("\(textView.text)\(lineText)\n")
        
      }
      
    }
    
  }

}
