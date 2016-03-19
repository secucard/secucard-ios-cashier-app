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

protocol AddProductViewDelegate {
  func didAddProduct(product:SCSmartProduct)
}

class AddProductView: UIView, UITextFieldDelegate {
  
  let centerView: UIView = UIView()
  
  let titleLabel = UILabel()
  
  let descriptionLabel = UILabel()
  let descriptionField = TextInputField()
  
  let articleNumberLabel = UILabel()
  let articleNumberField = TextInputField()
  
  let eanLabel = UILabel()
  let eanField = TextInputField()
  
  let priceLabel = UILabel()
  let priceField = TextInputField()
  
  let taxLabel = UILabel()
  let taxField = TextInputField()
  
  let level1IdLabel = UILabel()
  let level1IdField = TextInputField()
  let level1NameField = TextInputField()
  
  let level2IdLabel = UILabel()
  let level2IdField = TextInputField()
  let level2NameField = TextInputField()
  
  let level3IdLabel = UILabel()
  let level3IdField = TextInputField()
  let level3NameField = TextInputField()
  
  var delegate: AddProductViewDelegate?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }
  
  required init(coder aDecoder: NSCoder) {
    fatalError("This class does not support NSCoding")
  }
  
  func setupView() {
    
    backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.7)
    
    centerView.backgroundColor = UIColor.whiteColor()
    addSubview(centerView)
    
    centerView.snp_makeConstraints { (make) -> Void in
      make.left.equalTo(100)
      make.right.equalTo(-100)
      make.top.equalTo(0)
    }
    
    titleLabel.text = "Produkt hinzufügen"
    titleLabel.font = UIFont.systemFontOfSize(24)
    centerView.addSubview(titleLabel)
    
    titleLabel.snp_makeConstraints { (make) -> Void in
      make.top.left.equalTo(20)
      make.right.equalTo(-20)
      make.height.equalTo(30)
    }
    
    // description field
    
    descriptionLabel.text = "Name / Beschreibung"
    centerView.addSubview(descriptionLabel)
    descriptionLabel.snp_makeConstraints { (make) -> Void in
      make.left.equalTo(20)
      make.width.equalTo(120)
      make.height.equalTo(30)
      make.top.equalTo(titleLabel.snp_bottom).offset(10)
    }
    
    descriptionField.delegate = self
    descriptionField.returnKeyType = UIReturnKeyType.Next
    descriptionField.tag = 1
    
    centerView.addSubview(descriptionField)
    
    descriptionField.snp_makeConstraints { (make) -> Void in
      make.left.equalTo(descriptionLabel.snp_right).offset(20)
      make.right.equalTo(centerView).offset(-20)
      make.height.equalTo(30)
      make.top.equalTo(descriptionLabel)
    }
    
    // article number field
    
    articleNumberLabel.text = "Artikelnummer"
    centerView.addSubview(articleNumberLabel)
    articleNumberLabel.snp_makeConstraints { (make) -> Void in
      make.left.equalTo(20)
      make.width.equalTo(120)
      make.height.equalTo(30)
      make.top.equalTo(descriptionLabel.snp_bottom).offset(10)
    }
    
    articleNumberField.delegate = self
    articleNumberField.returnKeyType = UIReturnKeyType.Next
    articleNumberField.tag = 2
    
    centerView.addSubview(articleNumberField)
    
    articleNumberField.snp_makeConstraints { (make) -> Void in
      make.left.equalTo(articleNumberLabel.snp_right).offset(20)
      make.right.equalTo(centerView).offset(-20)
      make.height.equalTo(30)
      make.top.equalTo(articleNumberLabel)
    }
    
    // ean number field
    
    eanLabel.text = "EAN"
    centerView.addSubview(eanLabel)
    eanLabel.snp_makeConstraints { (make) -> Void in
      make.left.equalTo(20)
      make.width.equalTo(120)
      make.height.equalTo(30)
      make.top.equalTo(articleNumberLabel.snp_bottom).offset(10)
    }
    
    eanField.delegate = self
    eanField.returnKeyType = UIReturnKeyType.Next
    eanField.tag = 3
    
    centerView.addSubview(eanField)
    eanField.snp_makeConstraints { (make) -> Void in
      make.left.equalTo(eanLabel.snp_right).offset(20)
      make.right.equalTo(centerView).offset(-20)
      make.height.equalTo(30)
      make.top.equalTo(eanLabel)
    }
    
    // price field
    
    priceLabel.text = "Preis €"
    centerView.addSubview(priceLabel)
    priceLabel.snp_makeConstraints { (make) -> Void in
      make.left.equalTo(20)
      make.width.equalTo(120)
      make.height.equalTo(30)
      make.top.equalTo(eanLabel.snp_bottom).offset(10)
    }
    
    priceField.delegate = self
    priceField.returnKeyType = UIReturnKeyType.Next
    priceField.tag = 4
    
    centerView.addSubview(priceField)
    priceField.snp_makeConstraints { (make) -> Void in
      make.left.equalTo(priceLabel.snp_right).offset(20)
      make.right.equalTo(centerView).offset(-20)
      make.height.equalTo(30)
      make.top.equalTo(priceLabel)
    }
    
    // tax field
    
    taxLabel.text = "MwSt %"
    centerView.addSubview(taxLabel)
    taxLabel.snp_makeConstraints { (make) -> Void in
      make.left.equalTo(20)
      make.width.equalTo(120)
      make.height.equalTo(30)
      make.top.equalTo(priceLabel.snp_bottom).offset(10)
    }
    
    taxField.delegate = self
    taxField.returnKeyType = UIReturnKeyType.Next
    taxField.tag = 5
    
    centerView.addSubview(taxField)
    taxField.snp_makeConstraints { (make) -> Void in
      make.left.equalTo(taxLabel.snp_right).offset(20)
      make.right.equalTo(centerView).offset(-20)
      make.height.equalTo(30)
      make.top.equalTo(taxLabel)
    }
    
    // level 1 field
    
    level1IdLabel.text = "Warengruppe Level 1"
    centerView.addSubview(level1IdLabel)
    level1IdLabel.snp_makeConstraints { (make) -> Void in
      make.left.equalTo(20)
      make.width.equalTo(120)
      make.height.equalTo(30)
      make.top.equalTo(taxField.snp_bottom).offset(10)
    }
    
    level1IdField.delegate = self
    level1IdField.returnKeyType = UIReturnKeyType.Next
    level1IdField.tag = 6
    
    centerView.addSubview(level1IdField)
    level1IdField.snp_makeConstraints { (make) -> Void in
      make.left.equalTo(level1IdLabel.snp_right).offset(20)
      make.width.equalTo(100)
      make.height.equalTo(30)
      make.top.equalTo(level1IdLabel)
    }
    
    level1NameField.delegate = self
    level1NameField.returnKeyType = UIReturnKeyType.Next
    level1NameField.tag = 7
    
    centerView.addSubview(level1NameField)
    level1NameField.snp_makeConstraints { (make) -> Void in
      make.left.equalTo(level1IdField.snp_right).offset(20)
      make.right.equalTo(centerView).offset(-20)
      make.height.equalTo(30)
      make.top.equalTo(level1IdLabel)
    }
    
    // level 2 field
    
    level2IdLabel.text = "Warengruppe Level 2"
    centerView.addSubview(level2IdLabel)
    level2IdLabel.snp_makeConstraints { (make) -> Void in
      make.left.equalTo(20)
      make.width.equalTo(120)
      make.height.equalTo(30)
      make.top.equalTo(level1IdLabel.snp_bottom).offset(10)
    }
    
    level2IdField.delegate = self
    level2IdField.returnKeyType = UIReturnKeyType.Next
    level2IdField.tag = 8
    
    centerView.addSubview(level2IdField)
    level2IdField.snp_makeConstraints { (make) -> Void in
      make.left.equalTo(level2IdLabel.snp_right).offset(20)
      make.width.equalTo(100)
      make.height.equalTo(30)
      make.top.equalTo(level2IdLabel)
    }
    
    level2NameField.delegate = self
    level2NameField.returnKeyType = UIReturnKeyType.Next
    level2NameField.tag = 9
    
    centerView.addSubview(level2NameField)
    level2NameField.snp_makeConstraints { (make) -> Void in
      make.left.equalTo(level2IdField.snp_right).offset(20)
      make.right.equalTo(centerView).offset(-20)
      make.height.equalTo(30)
      make.top.equalTo(level2IdLabel)
    }
    
    // level 3 field
    
    level3IdLabel.text = "Warengruppe Level 3"
    centerView.addSubview(level3IdLabel)
    level3IdLabel.snp_makeConstraints { (make) -> Void in
      make.left.equalTo(20)
      make.width.equalTo(120)
      make.height.equalTo(30)
      make.top.equalTo(level2IdLabel.snp_bottom).offset(10)
    }
    
    level3IdField.delegate = self
    level3IdField.returnKeyType = UIReturnKeyType.Done
    level3IdField.tag = 10
    
    centerView.addSubview(level3IdField)
    level3IdField.snp_makeConstraints { (make) -> Void in
      make.left.equalTo(level3IdLabel.snp_right).offset(20)
      make.width.equalTo(100)
      make.height.equalTo(30)
      make.top.equalTo(level3IdLabel)
    }
    
    level3NameField.delegate = self
    level3NameField.returnKeyType = UIReturnKeyType.Next
    level3NameField.tag = 11
    
    centerView.addSubview(level3NameField)
    level3NameField.snp_makeConstraints { (make) -> Void in
      make.left.equalTo(level3IdField.snp_right).offset(20)
      make.right.equalTo(centerView).offset(-20)
      make.height.equalTo(30)
      make.top.equalTo(level3IdLabel)
    }
    
    let cancelButton: UIButton = UIButton(type: UIButtonType.Custom)
    cancelButton.setTitle("Abbrechen", forState: UIControlState.Normal)
    cancelButton.addTarget(self, action: "didTapCancel", forControlEvents: UIControlEvents.TouchUpInside)
    cancelButton.backgroundColor = Constants.tintColor
    cancelButton.setTitleColor(Constants.textColorBright, forState: UIControlState.Normal)
    centerView.addSubview(cancelButton)
    
    cancelButton.snp_makeConstraints { (make) -> Void in
      make.left.equalTo(10)
      make.width.equalTo(150)
      make.height.equalTo(30)
      make.top.equalTo(level3IdLabel.snp_bottom).offset(20)
    }
    
    let okButton: UIButton = UIButton(type: UIButtonType.Custom)
    okButton.setTitle("Hinzufügen", forState: UIControlState.Normal)
    okButton.addTarget(self, action: "didTapAdd", forControlEvents: UIControlEvents.TouchUpInside)
    okButton.backgroundColor = Constants.tintColor
    okButton.setTitleColor(Constants.textColorBright, forState: UIControlState.Normal)
    centerView.addSubview(okButton)
    
    okButton.snp_makeConstraints { (make) -> Void in
      make.right.equalTo(-10)
      make.width.equalTo(150)
      make.height.equalTo(30)
      make.top.equalTo(level3IdLabel.snp_bottom).offset(20)
      make.bottom.equalTo(centerView.snp_bottom).offset(-10)
    }
    
    descriptionField.becomeFirstResponder()
    
  }
  
  func hide() {
    UIView.animateWithDuration(0.4, animations: { () -> Void in
      self.alpha = 0
      }) { (done: Bool) -> Void in
        self.removeFromSuperview()
    }
  }
  
  internal func didTapCancel() {
    hide()
  }
  
  func RandomInt(min min: Int, max: Int) -> Int {
    if max < min { return min }
    return Int(arc4random_uniform(UInt32((max - min) + 1))) + min
  }
  
  internal func didTapAdd() {
    
    let product = SCSmartProduct()
    product.ean = eanField.text
    product.articleNumber = articleNumberField.text
    product.desc = descriptionField.text
    product.quantity = 1
    product.productId = RandomInt(min: 10000, max: 99999)
    
    if (priceField.text != "") {
      
      let formatter = NSNumberFormatter()
      formatter.locale = NSLocale(localeIdentifier: "de_DE")
      //formatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
      
      if let priceText = priceField.text {
        if let doub = formatter.numberFromString(priceText) {
          product.priceOne = doub.doubleValue*100
        } else {
          product.priceOne = 0
        }
      }
      
    } else {
      product.priceOne = 0
    }
    
    if (taxField.text != "") {
      product.tax = Float(taxField.text!)!
    } else {
      product.tax = 0
    }
    
    product.groups = [SCSmartProductGroup]()
    
    if level1IdField.text != "" && level1NameField.text != "" {
      let group1 = SCSmartProductGroup()
      group1.id = level1IdField.text
      group1.groupLevel = 1
      group1.desc = level1NameField.text
      product.groups.append(group1)
    }
    
    if level2IdField.text != "" && level2NameField.text != "" {
      let group2 = SCSmartProductGroup()
      group2.id = level2IdField.text
      group2.groupLevel = 2
      group2.desc = level2NameField.text
      product.groups.append(group2)
    }
    
    if level3IdField.text != "" && level3NameField.text != "" {
      let group3 = SCSmartProductGroup()
      group3.id = level3IdField.text
      group3.groupLevel = 3
      group3.desc = level3NameField.text
      product.groups.append(group3)
    }
    
    delegate?.didAddProduct(product)
    
    hide()
    
  }
  
  // MARK: - UITextFieldDelegate
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    let nextTag = textField.tag+1
    if let nextView = centerView.viewWithTag(nextTag) {
      nextView.becomeFirstResponder()
    } else {
      textField.resignFirstResponder()
    }
    
    return true
    
  }
  
}

