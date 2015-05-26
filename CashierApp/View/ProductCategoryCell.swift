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
  
  var data:JSON = nil {
    didSet {
      label.text = self.data["name"].stringValue
      //label.sizeToFit()
    }
  }
  
  var imageView: UIImageView
  var label: UILabel
  
  override init(frame: CGRect) {
    
    imageView = UIImageView()
    label = UILabel()
    label.textAlignment = NSTextAlignment.Center
    super.init(frame: frame)
    
    self.addSubview(imageView)
    self.addSubview(label)
    
    label.snp_makeConstraints { (make) -> Void in
      make.edges.equalTo(self)
    }
    
    self.backgroundColor = UIColor.whiteColor()

  }

  required init(coder aDecoder: NSCoder) {
    
    imageView = UIImageView()
    label = UILabel()
    
    super.init(coder: aDecoder)
  }
  
  
}
