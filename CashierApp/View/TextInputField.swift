//
//  TextwInputField.swift
//  CashierApp
//
//  Created by Jörn Schmidt on 03.10.15.
//  Copyright © 2015 secucard. All rights reserved.
//

import UIKit

class TextInputField: UITextField {

  init() {
    
    super.init(frame: CGRectNull)

    font = Constants.settingFont
    layer.borderWidth = 1
    returnKeyType = UIReturnKeyType.Done
    layer.borderColor = Constants.darkGreyColor.CGColor
    
    let secretFieldSpacer = UIView(frame: CGRectMake(0, 0, 5, 5))
    leftViewMode = UITextFieldViewMode.Always
    leftView = secretFieldSpacer
    
  }

  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
  
}
