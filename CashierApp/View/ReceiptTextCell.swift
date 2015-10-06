//
//  ReceiptTextCell.swift
//  CashierApp
//
//  Created by Jörn Schmidt on 05.10.15.
//  Copyright © 2015 secucard. All rights reserved.
//

import UIKit
import SecucardConnectSDK

class ReceiptTextCell: ReceiptCell {

  var label = UILabel()
  
  override var data:SCSmartReceiptLine? {
    didSet {
      if let data = data {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 16
        let attrString = NSMutableAttributedString(string: data.value["text"] as! String)
        attrString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
        
        label.attributedText = attrString

        label.font = Constants.receiptRegularFont
        
        if let textDecoration = data.value["decoration"] as? [String] {
          
          if textDecoration.contains("important") {
            label.font = Constants.receiptBoldFont
          }
          
          if textDecoration.contains("align-center") {
            label.textAlignment = NSTextAlignment.Center
          }
          
          if textDecoration.contains("align-left") {
            label.textAlignment = NSTextAlignment.Left
          }
        }
        
      }
    }
  }
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    label.clipsToBounds = false
    label.textColor = UIColor.blackColor()
    label.font = Constants.receiptHeadingFont
    label.backgroundColor = UIColor.whiteColor()
    label.numberOfLines = 0
    label.lineBreakMode = NSLineBreakMode.ByWordWrapping
    addSubview(label)
    label.snp_makeConstraints { (make) -> Void in
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
