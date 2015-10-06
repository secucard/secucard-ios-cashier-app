//
//  ReceiptHeadingCellTableViewCell.swift
//  CashierApp
//
//  Created by Jörn Schmidt on 05.10.15.
//  Copyright © 2015 secucard. All rights reserved.
//

import UIKit
import SecucardConnectSDK

class ReceiptHeadingCell: ReceiptCell {
  
  var label = UILabel()
  
  override var data:SCSmartReceiptLine? {
    didSet {
      if let data = data {
        label.text = data.value["caption"] as? String
      }
    }
  }
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    let line = UIView()
    line.backgroundColor = UIColor.blackColor()
    
    addSubview(line)
    line.snp_makeConstraints { (make) -> Void in
      make.left.width.centerY.equalTo(self)
      make.height.equalTo(1)
    }
    
    let titleBGView = UIView()
    titleBGView.backgroundColor = UIColor.whiteColor()
    addSubview(titleBGView)
    
    label.textColor = UIColor.blackColor()
    label.font = Constants.receiptHeadingFont
    label.backgroundColor = UIColor.whiteColor()
    
    addSubview(label)
    label.snp_makeConstraints { (make) -> Void in
      make.top.equalTo(self).offset(10)
      make.bottom.equalTo(self).offset(-10)
      make.centerX.equalTo(self)
      make.width.greaterThanOrEqualTo(20)
      make.height.equalTo(20)
    }
    
    titleBGView.snp_makeConstraints { (make) -> Void in
      make.left.equalTo(label).offset(-10)
      make.right.equalTo(label).offset(10)
      make.top.height.equalTo(label)
    }
    
  }

  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(false, animated: animated)
  }
  
}
