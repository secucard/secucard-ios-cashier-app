//
//  ProductsSectionHeaderView.swift
//  CashierApp
//
//  Created by Jörn Schmidt on 06.10.15.
//  Copyright © 2015 secucard. All rights reserved.
//

import UIKit

class ProductsSectionHeaderView: UICollectionReusableView {
  
  let label: UILabel = UILabel()
  
  override init(frame: CGRect) {
    
    super.init(frame: frame)
    
    let bgView = UIView()
    addSubview(bgView)
    bgView.snp_makeConstraints { (make) -> Void in
      make.left.width.equalTo(self)
      make.top.equalTo(10)
      make.bottom.equalTo(-10)
    }
    
    label.textColor = Constants.textColorBright
    bgView.addSubview(label)
    label.snp_makeConstraints { (make) -> Void in
      make.top.height.right.equalTo(self)
      make.left.equalTo(10)
    }
    
    bgView.backgroundColor = Constants.tintColor
    
  }
  
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  
}
