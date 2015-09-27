//
//  ProductCategoryCell.swift
//  CashierApp
//
//  Created by Jörn Schmidt on 17.05.15.
//  Copyright (c) 2015 secucard. All rights reserved.
//

import UIKit
import SwiftyJSON
import SnapKit

class ProductCategoryCell: UICollectionViewCell {
  
  let imageView = UIImageView()
  let label = UILabel()
  
  var title:String? {
    didSet {
      
      label.text = title
      label.sizeToFit()
      var f = label.frame
      f.size.height = self.frame.size.height
      f.size.width += 40
      label.frame = f
      
    }
  }
  
  var data:[JSON]?
  
  override init(frame: CGRect) {
    
    label.textAlignment = NSTextAlignment.Center
    super.init(frame: frame)
    
    self.addSubview(imageView)
    self.addSubview(label)
  
  }

  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
  
  override func preferredLayoutAttributesFittingAttributes(layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
    
    let attr = layoutAttributes.copy() as! UICollectionViewLayoutAttributes
    
    var newFrame = attr.frame
    self.frame = newFrame
    
    self.setNeedsLayout()
    self.layoutIfNeeded()
    
    newFrame.size.width = self.label.frame.size.width
    attr.frame = newFrame
    return attr
    
  }
  
}
