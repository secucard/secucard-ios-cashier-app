//
//  StringExtension.swift
//  CashierApp
//
//  Created by Jörn Schmidt on 25.02.16.
//  Copyright © 2016 secucard. All rights reserved.
//

import Foundation

extension Float {
  
  func toEuro()->String {
    let formatter = NSNumberFormatter()
    formatter.numberStyle = .CurrencyStyle
    formatter.locale = NSLocale(localeIdentifier: "DE_de")
    return formatter.stringFromNumber(self)!
  }
  
}

extension Int {
  
  func toEuro()->String {
    
    return (Float(self) / 100.0).toEuro()
    
  }
  
}

extension String {
  
  mutating func withCommaToFloat() -> Float {
    
    if self.containsString(",") {
      self = self.stringByReplacingOccurrencesOfString(",", withString: ".")
    }
    
    return Float(self)!
    
  }
  
  mutating func withCommaToInt() -> Int {
    
    if self.containsString(",") {
      self = self.stringByReplacingOccurrencesOfString(",", withString: ".")
    }
    
    return Int(roundf(Float(self)!))
    
  }
  
  mutating func withCommaToCent() -> Int {
    
    if self.containsString(",") {
      self = self.stringByReplacingOccurrencesOfString(",", withString: ".")
    }
    
    return Int(roundf(Float(self)!*100.0))
    
  }
  
}