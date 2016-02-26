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

protocol TransactionInfoInputViewDelegate {
  func didAddTransactionInput(transactionRef: String, merchantRef:String)
}

class TransactionInfoInputView: UIView, UITextFieldDelegate {
  
  let centerView: UIView = UIView()
  
  let titleLabel = UILabel()
  
  let transactionRefLabel = UILabel()
  let transactionRefField = TextInputField()
  
  let merchantRefLabel = UILabel()
  let merchantRefField = TextInputField()
  
  let transactionIdLabel = UILabel()
  
  var delegate: TransactionInfoInputViewDelegate?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }
  
  required init(coder aDecoder: NSCoder) {
    fatalError("This class does not support NSCoding")
  }
  
  convenience init(transactionRef:String?, merchantRef: String?, transactionId: String?) {
    
    self.init()
    
    if let transactionRef = transactionRef {
      self.transactionRefField.text = transactionRef
    }
    
    if let merchantRef = merchantRef {
      self.merchantRefField.text = merchantRef
    }
    
    if let transactionId = transactionId {
      self.transactionIdLabel.text = "Transaktion: ID \(transactionId)"
    }
    
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
    
    titleLabel.text = "Transaktionsinformationen hinzufügen"
    titleLabel.font = UIFont.systemFontOfSize(24)
    centerView.addSubview(titleLabel)
    
    titleLabel.snp_makeConstraints { (make) -> Void in
      make.top.left.equalTo(20)
      make.right.equalTo(-20)
      make.height.equalTo(30)
    }
    
    // description field
    
    transactionIdLabel.text = "Transaktions-Id"
    centerView.addSubview(transactionIdLabel)
    transactionIdLabel.snp_makeConstraints { (make) -> Void in
      make.left.equalTo(20)
      make.width.equalTo(400)
      make.height.equalTo(30)
      make.top.equalTo(titleLabel.snp_bottom).offset(10)
    }
    
    // description field
    
    transactionRefLabel.text = "Transaktion"
    centerView.addSubview(transactionRefLabel)
    transactionRefLabel.snp_makeConstraints { (make) -> Void in
      make.left.equalTo(20)
      make.width.equalTo(150)
      make.height.equalTo(30)
      make.top.equalTo(transactionIdLabel.snp_bottom).offset(10)
    }
    
    transactionRefField.delegate = self
    transactionRefField.returnKeyType = UIReturnKeyType.Next
    transactionRefField.tag = 1
    
    centerView.addSubview(transactionRefField)
    
    transactionRefField.snp_makeConstraints { (make) -> Void in
      make.left.equalTo(transactionRefLabel.snp_right).offset(20)
      make.right.equalTo(centerView).offset(-20)
      make.height.equalTo(30)
      make.top.equalTo(transactionRefLabel)
    }
    
    
    
    // article number field
    
    merchantRefLabel.text = "Merchant"
    centerView.addSubview(merchantRefLabel)
    merchantRefLabel.snp_makeConstraints { (make) -> Void in
      make.left.equalTo(20)
      make.width.equalTo(150)
      make.height.equalTo(30)
      make.top.equalTo(transactionRefLabel.snp_bottom).offset(10)
    }
    
    merchantRefField.delegate = self
    merchantRefField.returnKeyType = UIReturnKeyType.Next
    merchantRefField.tag = 2
    
    centerView.addSubview(merchantRefField)
    
    merchantRefField.snp_makeConstraints { (make) -> Void in
      make.left.equalTo(merchantRefLabel.snp_right).offset(20)
      make.right.equalTo(centerView).offset(-20)
      make.height.equalTo(30)
      make.top.equalTo(merchantRefLabel)
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
      make.top.equalTo(merchantRefLabel.snp_bottom).offset(20)
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
      make.top.equalTo(merchantRefLabel.snp_bottom).offset(20)
      make.bottom.equalTo(centerView.snp_bottom).offset(-10)
    }
    
    transactionRefField.becomeFirstResponder()
    
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
    
    if let transactionId = transactionRefField.text, merchantId = merchantRefField.text {
      delegate?.didAddTransactionInput(transactionId, merchantRef: merchantId)
    }
    
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

