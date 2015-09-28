//
//  BasketItem.swift
//  CashierApp
//
//  Created by Jörn Schmidt on 02.06.15.
//  Copyright (c) 2015 secucard. All rights reserved.
//

import UIKit
import SwiftyJSON
import Mantle
import SecucardConnectSDK

enum BasketItemType {
  case Product
  case Checkin
}

class BasketItem: MTLModel, MTLJSONSerializing {

  var type: BasketItemType!
  dynamic var product: SCSmartProduct!
  
  var amount: Int = 1
  var discount: Float = 1.0
  var price: Float = 0.0
  var expanded: Bool = false
  
  convenience init(product : SCSmartProduct) {
    
    self.init()
    self.type = BasketItemType.Product
    self.product = product
    self.price = Float(product.priceOne)
    
  }
  
  static func JSONKeyPathsByPropertyKey() -> [NSObject : AnyObject]! {
    return NSDictionary.mtl_identityPropertyMapWithModel(self)
  }
  
  class func productJSONTransformer() -> NSValueTransformer {
    return MTLJSONAdapter.dictionaryTransformerWithModelClass(SCSmartProduct.self);
  }

  
}
