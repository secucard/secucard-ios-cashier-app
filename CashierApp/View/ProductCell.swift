//
//  ProductCell.swift
//  CashierApp
//
//  Created by Jörn Schmidt on 16.05.15.
//  Copyright (c) 2015 secucard. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import SecucardConnectSDK

class ProductCell: UICollectionViewCell {

  let imageView = UIImageView()
  let label = UILabel()
  
  var data: SCSmartProduct? {
    
    didSet {
      
      imageView.image = UIImage(named: (self.data?.articleNumber)!)
      label.text = self.data?.desc
      
    }
  }
  
  override init(frame: CGRect) {
    
    imageView.contentMode = UIViewContentMode.ScaleAspectFit
  
    label.font = Constants.regularFont
    label.textColor = Constants.textColorBright
    label.textAlignment = NSTextAlignment.Center
    label.numberOfLines = 0
    label.lineBreakMode = NSLineBreakMode.ByWordWrapping
    super.init(frame: frame)
    
    self.addSubview(imageView)
    self.addSubview(label)
    
    imageView.snp_makeConstraints { (make) -> Void in
      make.edges.equalTo(self)
    }
    
    label.snp_makeConstraints { (make) -> Void in
      make.left.equalTo(0)
      make.right.bottom.equalTo(-0)
      make.height.equalTo(50)
    }
    
    label.backgroundColor = Constants.tintColor.colorWithAlphaComponent(0.7)
    
    self.layer.backgroundColor = UIColor.whiteColor().CGColor
    self.layer.borderColor = UIColor.lightGrayColor().CGColor
    self.layer.borderWidth = 1
    
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
}
