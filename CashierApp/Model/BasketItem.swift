//
//  BasketItem.swift
//  CashierApp
//
//  Created by Jörn Schmidt on 02.06.15.
//  Copyright (c) 2015 secucard. All rights reserved.
//

import UIKit
import SwiftyJSON

enum BasketItemType {
  case Product
  case Checkin
  case Unknown
}

class BasketItem: NSObject {

  var type: BasketItemType = BasketItemType.Unknown
  var checkin: Checkin = Checkin()
  var product: Product = Product()
  
  convenience init(checkin : Checkin) {
    
    self.init()
    self.type = BasketItemType.Checkin
    self.checkin = checkin
    
  }
  
  convenience init(product : Product) {
    
    self.init()
    self.type = BasketItemType.Product
    self.product = product
    
  }
  
}
