//
//  CashierApp_UITests.swift
//  CashierApp UITests
//
//  Created by Jörn Schmidt on 18.01.16.
//  Copyright © 2016 secucard. All rights reserved.
//

import XCTest

class CashierApp_UITests: XCTestCase {
  
  let app = XCUIApplication()
  
  override func setUp() {
    
    super.setUp()
    
    setupSnapshot(app)
    app.launch()
    
  }
  
  override func tearDown() {

    app.terminate()
    
    super.tearDown()
    
  }
  
  func testExample() {
    // Use recording to get started writing UI tests.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
  }
  
}
