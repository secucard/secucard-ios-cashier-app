//
//  ReceiptKeyValueCell.swift
//  CashierApp
//
//  Created by Jörn Schmidt on 05.10.15.
//  Copyright © 2015 secucard. All rights reserved.
//

import UIKit
import SecucardConnectSDK

class ReceiptKeyValueCell: ReceiptCell {

  var leftLabel = UILabel()
  var rightLabel = UILabel()
  
  override var data:SCSmartReceiptLine? {
    didSet {
      if let data = data {
        
        leftLabel.text = data.value["name"] as? String
        
        rightLabel.text = data.value["value"] as? String
        
        rightLabel.font = Constants.receiptRegularFont
        
        if let textDecoration = data.value["decoration"] as? [String] {
          
          if textDecoration.contains("important") {
            rightLabel.font = Constants.receiptBoldFont
          }
          
          if textDecoration.contains("align-center") {
            rightLabel.textAlignment = NSTextAlignment.Center
          }
          
          if textDecoration.contains("align-left") {
            rightLabel.textAlignment = NSTextAlignment.Left
          }
        }
        
      }
    }
  }
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    leftLabel.clipsToBounds = false
    leftLabel.textColor = UIColor.blackColor()
    leftLabel.textAlignment = NSTextAlignment.Left
    leftLabel.font = Constants.receiptRegularFont

    addSubview(leftLabel)
    leftLabel.snp_makeConstraints { (make) -> Void in
      make.edges.equalTo(self).inset(5)
    }
    
    rightLabel.clipsToBounds = false
    rightLabel.textColor = UIColor.blackColor()
    rightLabel.textAlignment = NSTextAlignment.Right
    rightLabel.font = Constants.receiptRegularFont
    
    addSubview(rightLabel)
    rightLabel.snp_makeConstraints { (make) -> Void in
      make.edges.equalTo(self).inset(5)
    }
    
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(false, animated: animated)
  }

}
