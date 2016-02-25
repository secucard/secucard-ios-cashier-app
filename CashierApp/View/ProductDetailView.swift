//
//  ProductDetailView.swift
//  CashierApp
//
//  Created by Jörn Schmidt on 29.09.15.
//  Copyright © 2015 secucard. All rights reserved.
//

import UIKit
import SecucardConnectSDK
import SnapKit

class ProductDetailView: UIView {

  let titleLabel = UILabel()
  let imageView = UIImageView()
  let informationView = UITextView()
  
  var product:SCSmartProduct? {
    didSet {
      if let product = product {
        
        titleLabel.text = "\(product.desc)"
        
        imageView.image = UIImage(named: product.articleNumber)
        
        informationView.text = ""
        informationView.text = informationView.text.stringByAppendingString("Artikelnummer: \(product.articleNumber)\n")
        informationView.text = informationView.text.stringByAppendingString("EAN: \(product.ean)\n")
        informationView.text = informationView.text.stringByAppendingString("Preis: \(Int(product.priceOne).toEuro())\n")
        informationView.text = informationView.text.stringByAppendingString("MwSt: \(product.tax) %\n")
        
        informationView.text = informationView.text.stringByAppendingString("\nWarengruppen\n")
        
        for group in product.groups {
            informationView.text = informationView.text.stringByAppendingString("GAP \(group.id) - Level \(group.groupLevel) : \(group.desc)\n")
        }
        
        /*

        productId;

        @property (nonatomic, copy) NSNumber *quantity;
        @property (nonatomic, copy) NSNumber *priceOne;
        @property (nonatomic, copy) NSNumber *tax;
        @property (nonatomic, copy) NSArray *groups;
        
*/
        
      }
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }
  
  required init(coder aDecoder: NSCoder) {
    fatalError("This class does not support NSCoding")
  }
  
  func setupView() {
    
    backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.7)
    
    let centerView: UIView = UIView()
    centerView.backgroundColor = UIColor.whiteColor()
    addSubview(centerView)
    
    centerView.snp_makeConstraints { (make) -> Void in
      make.edges.equalTo(self).inset(UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100))
      make.centerY.equalTo(self)
    }
    
    titleLabel.font = UIFont.systemFontOfSize(24)
    centerView.addSubview(titleLabel)
    
    titleLabel.snp_makeConstraints { (make) -> Void in
      make.top.left.equalTo(20)
      make.right.equalTo(-20)
      make.height.equalTo(30)
    }
    
    imageView.contentMode = UIViewContentMode.ScaleAspectFit
    addSubview(imageView)
    imageView.snp_makeConstraints { (make) -> Void in
      make.top.equalTo(titleLabel.snp_bottom).offset(20)
      make.left.equalTo(50)
      make.right.equalTo(-50)
      make.height.equalTo(200)
    }
    
    informationView.editable = false
    informationView.scrollEnabled = true
    informationView.font = Constants.headlineFont
    centerView.addSubview(informationView)
    
    informationView.snp_makeConstraints { (make) -> Void in
      make.top.equalTo(imageView.snp_bottom).offset(20)
      make.left.equalTo(50)
      make.right.equalTo(-50)
      make.bottom.equalTo(-20)
    }
    
    let cancelButton: UIButton = UIButton(type: UIButtonType.Custom)
    cancelButton.setTitle("Schließen", forState: UIControlState.Normal)
    cancelButton.addTarget(self, action: "didTapCancel", forControlEvents: UIControlEvents.TouchUpInside)
    cancelButton.backgroundColor = Constants.brightGreyColor
    cancelButton.setTitleColor(Constants.textColor, forState: UIControlState.Normal)
    centerView.addSubview(cancelButton)
    
    cancelButton.snp_makeConstraints { (make) -> Void in
      make.left.equalTo(10)
      make.width.equalTo(100)
      make.height.equalTo(50)
      make.bottom.equalTo(-10)
    }
    
  }

  internal func didTapCancel() {
    self.hidden = true
  }
  
}

