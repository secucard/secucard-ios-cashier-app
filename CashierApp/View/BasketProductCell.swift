//
//  BasketProductCell.swift
//  CashierApp
//
//  Created by Jörn Schmidt on 26.05.15.
//  Copyright (c) 2015 secucard. All rights reserved.
//

import UIKit
import SwiftyJSON

class BasketProductCell: UICollectionViewCell {

  var data:Product = Product() {
    didSet {
      
      // properties
      amount = 1
      discount = 1.0
      price = data.price
      
      // text
      nameLabel.text = data.name
      infoLabel.text = "\(data.articleNumber) \(price*discount)€"
      
    }
  }
  
  var discount: Float = 0.0 {
    didSet {
      infoLabel.text = "\(data.articleNumber) \(price*discount)€"
    }
  }
  
  var price: Float = 0.0 {
    didSet {
      infoLabel.text = "\(data.articleNumber) \(price*discount)€"
    }
  }
  
  var amount: Int = 1 {
    didSet {
      countLabel.text = "\(amount)"
    }
  }
  
  // regular controls
  var countLabel: UILabel
  var nameLabel: UILabel
  var infoLabel: UILabel
  var actionsButton : UIButton
  
  // actions
  var increaseButton : UIButton = UIButton()
  var decreaseButton : UIButton = UIButton()
  var changePrice : UIButton = UIButton()
  var addDiscount : UIButton = UIButton()
  
  override init(frame: CGRect) {
    
    // control initialization
    countLabel = UILabel()
    countLabel.textColor = Constants.textColorBright
    countLabel.font = Constants.regularFont
    countLabel.backgroundColor = Constants.tintColor
    countLabel.textAlignment = NSTextAlignment.Center
    
    nameLabel = UILabel()
    nameLabel.textColor = Constants.textColor
    nameLabel.font = Constants.headlineFont
    
    infoLabel = UILabel()
    infoLabel.textColor = Constants.textColor
    infoLabel.font = Constants.regularFont
    
    actionsButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
    actionsButton.setTitle("...", forState: UIControlState.Normal)
    actionsButton.backgroundColor = Constants.brightGreyColor
    
    var bottomLine: UIView = UIView()
    bottomLine.backgroundColor = Constants.paneBorderColor
    
    // call super
    super.init(frame: frame)
    
    // add items
    self.addSubview(countLabel)
    self.addSubview(nameLabel)
    self.addSubview(infoLabel)
    self.addSubview(actionsButton)
    self.addSubview(bottomLine)
    
    // layouting
    countLabel.snp_makeConstraints { (make) -> Void in
      make.left.equalTo(10)
      make.top.equalTo(10)
      make.width.height.equalTo(50)
    }
    
    nameLabel.snp_makeConstraints { (make) -> Void in
      make.left.equalTo(countLabel.snp_right).offset(10)
      make.right.equalTo(actionsButton.snp_left).offset(-10)
      make.top.equalTo(countLabel)
      make.bottom.equalTo(countLabel.snp_centerY)
    }
    
    infoLabel.snp_makeConstraints { (make) -> Void in
      make.left.equalTo(countLabel.snp_right).offset(10)
      make.right.equalTo(actionsButton.snp_left).offset(-10)
      make.top.equalTo(countLabel.snp_centerY)
      make.bottom.equalTo(countLabel)
    }
    
    actionsButton.addTarget(self, action: "actionsButtonTouched", forControlEvents: UIControlEvents.TouchUpInside)
    actionsButton.snp_makeConstraints { (make) -> Void in
      make.right.equalTo(-10)
      make.top.equalTo(10)
      make.width.height.equalTo(50)
    }
    
    bottomLine.snp_makeConstraints { (make) -> Void in
      make.left.width.bottom.equalTo(self)
      make.height.equalTo(1)
    }
    
  }
  
  required init(coder aDecoder: NSCoder) {
    
    countLabel = UILabel()
    nameLabel = UILabel()
    infoLabel = UILabel()
    actionsButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
    
    super.init(coder: aDecoder)
    
  }
  
  func actionsButtonTouched() {
    
    NSLog("touched")
    
  }
  
}
