//
//  Product.swift
//  CashierApp
//
//  Created by Jörn Schmidt on 02.06.15.
//  Copyright (c) 2015 secucard. All rights reserved.
//

import UIKit
import SwiftyJSON

class Product: NSObject {

  var data: JSON = [] {
    didSet {
      amount = 1
    }
  }
  
  var amount: Int = 1
  
  var name: String {
    get {
      return self.data["title"].stringValue
    }
  }
  
  var articleNumber: String {
    get {
      return self.data["object"]["number"].stringValue
    }
  }
  
  var price: Float {
    get {
      return self.data["object"]["sale"][0]["price"].floatValue
    }
  }
  
  var imageName: String {
    get {
      return self.data["object"]["images"][0]["file"].stringValue+".jpg"
    }
  }
  
  convenience init(product : JSON) {
    
    self.init()
    self.data = product
    
  }
  
}
