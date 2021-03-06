//
//  CheckinCell.swift
//  CashierApp
//
//  Created by Jörn Schmidt on 26.05.15.
//  Copyright (c) 2015 secucard. All rights reserved.
//

import UIKit
import SecucardConnectSDK

class CheckinCell: UICollectionViewCell {

  var data:SCSmartCheckin? {
    
    didSet {
      
      if let data = data {
        
        label.text = data.customerName
        
        if let pictureUrl = data.picture {
          imageView.setImageWithURL(NSURL(string: pictureUrl)!, placeholderImage: UIImage())
        }
        
      }
      
    }
  }
  
  var imageView = UIImageView()
  var label = UILabel()
  var controls = UIView()
  let removeButton = UIButton(type: UIButtonType.Custom)
  
  var showsControls: Bool = false {
    didSet {
      controls.hidden = !showsControls
    }
  }
  
  override init(frame: CGRect) {
    
    imageView.contentMode = UIViewContentMode.ScaleAspectFit
    
    label.font = Constants.headlineFont
    label.textColor = Constants.textColor
    label.numberOfLines = 0
    label.lineBreakMode
      = NSLineBreakMode.ByWordWrapping
    
    controls.hidden = true;
    
    super.init(frame: frame)
    
    self.addSubview(imageView)
    self.addSubview(label)
    self.addSubview(controls)
    
    imageView.snp_makeConstraints { (make) -> Void in
      make.left.top.equalTo(self)
      make.width.height.equalTo(self.snp_height)
    }
    
    label.snp_makeConstraints { (make) -> Void in
      make.left.equalTo(imageView.snp_right).offset(20)
      make.right.equalTo(-10)
      make.top.height.equalTo(self)
    }
    
    controls.snp_makeConstraints { (make) -> Void in
      make.top.height.equalTo(self)
      make.right.equalTo(self).offset(-10)
      make.width.equalTo(50)
    }
    
    removeButton.backgroundColor = Constants.warningColor
    removeButton.addTarget(self, action: #selector(CheckinCell.didTapRemove), forControlEvents: UIControlEvents.TouchUpInside)
    controls.addSubview(removeButton)
    
    removeButton.snp_makeConstraints { (make) -> Void in
      make.left.centerY.equalTo(controls)
      make.width.height.equalTo(50)
    }
    
  }
  
  func didTapRemove() {
    print("needs implementation")
  }

  required init(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
  
  override func preferredLayoutAttributesFittingAttributes(layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
    
      let newFrame: CGRect = layoutAttributes.frame
      layoutAttributes.frame = newFrame
    
    return layoutAttributes
  }
  
}
