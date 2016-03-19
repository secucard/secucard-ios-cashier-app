//
//  ReceiptLabel.swift
//  CashierApp
//
//  Created by Jörn Schmidt on 05.10.15.
//  Copyright © 2015 secucard. All rights reserved.
//

import UIKit

class ReceiptLabel: UILabel {

  override func drawTextInRect(rect: CGRect) {
    let insets = UIEdgeInsetsMake(5, 0, 5, 0)
    super.drawTextInRect(UIEdgeInsetsInsetRect(rect, insets))
  }

}
