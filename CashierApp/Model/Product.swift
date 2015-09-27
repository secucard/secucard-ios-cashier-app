//
//  Product.swift
//  CashierApp
//
//  Created by Jörn Schmidt on 02.06.15.
//  Copyright (c) 2015 secucard. All rights reserved.
//

import UIKit
import SwiftyJSON
import Mantle

class Product: MTLModel, MTLJSONSerializing {

  var data: JSON?
  
  var name: String {
    get {
      
      if let d = data {
        return d["desc"].stringValue
      } else {
        return ""
      }
      
    }
  }
  
  var articleNumber: String {
    get {
      if let d = data {
        return d["articleNumber"].stringValue
      } else {
        return ""
      }
    }
  }
  
  var price: Float {
    get {
      if let d = data {
        return d["priceOne"].floatValue
      } else {
        return 0.0
      }
    }
  }
  
  var imageName: String {
    get {
      if let d = data {
        return d["file"].stringValue+".jpg"
      } else {
        return ""
      }
    }
  }
  
  convenience init(product : JSON) {
    
    self.init()
    data = product
    
  }
  
  static func JSONKeyPathsByPropertyKey() -> [NSObject : AnyObject]! {
    return NSDictionary.mtl_identityPropertyMapWithModel(self)
  }
  
}
