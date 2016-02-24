//
//  Constants.swift
//  CashierApp
//
//  Created by Jörn Schmidt on 02.06.15.
//  Copyright (c) 2015 secucard. All rights reserved.
//

import UIKit

enum DefaultsKeys : String {
  case ClientId = "clientId"
  case ClientSecret = "clientSecret"
  case UUID = "uuid"
  case Server = "server"
}

class Constants: NSObject {
  
  // API Settings
  static let baseUrl: String = "https://connect.secucard.com/"
  static let apiString: String = "api/v2/"
  
  static let stompHost: String = "connect.secucard.com"
  static let stompVHost: String = "/"
  static let stompPort: Int32 = 61614
  static let replyQueue: String = "/temp-queue/main"
  static let connectionTimeoutSec: Int32 =   30
  static let socketTimeoutSec: Int32 =   30
  static let heartbeatMs: Int32 =   40000
  static let basicDestination: String = "/exchange/connect.api/"
  
  static let usernameAppSample: String = "checkoutsecucard"
  static let passwordAppSample: String = "checkout"
  static let deviceIdAppSample: String = "611c00ec6b2be6c77c2338774f50040b"
  
  static let clientIdAppSample: String = "app.mobile.secucard"
  static let clientSecretAppSample: String = "dc1f422dde755f0b1c4ac04e7efbd6c4c78870691fe783266d7d6c89439925eb"
  
  static let usernameCashierSample: String = "secucard.dresden"
  static let passwordCashierSample: String = "Kasse12345"
  
//  static let clientIdCashierSample: String = ""
//  static let deviceIdCashierSample: String = ""
//  static let clientSecretCashierSample: String = ""
  
    static let clientIdCashierSample: String = "611c00ec6b2be6c77c2338774f50040b"
    static let deviceIdCashierSample: String = "/vendor/vendor_name/cashier/iostest1"
    static let clientSecretCashierSample: String = "dc1f422dde755f0b1c4ac04e7efbd6c4c78870691fe783266d7d6c89439925eb"
  
  static let contactForename: String = "DeviD"
  static let contactSurname: String = "Testermann"
  static let contactSalutation: String = "Herr"
  static let contactEmail: String = "schmidt@devid.net"
  
  static let accountUsername: String = "schmidtdevid.net"
  static let acccountPassword: String = "Secucard123"
  
  static let merchantRef: String = "KundeXY"
  
  static let serverData = [
    "https://connect.secucard.com/",
    "https://connect-dev1.secupay-ag.de/",
    "https://connect-dev2.secupay-ag.de/",
    "https://connect-dev3.secupay-ag.de/",
    "https://connect-dev4.secupay-ag.de/",
    "https://connect-dev5.secupay-ag.de/",
    "https://connect-dev6.secupay-ag.de/",
    "https://connect-dev7.secupay-ag.de/",
    "https://connect-dev8.secupay-ag.de/",
    "https://connect-dev9.secupay-ag.de/",
    "https://connect-dev10.secupay-ag.de/",
    "https://connect-testing.secupay-ag.de/"
  ]
  
  // Colors
  static let tintColor: UIColor = UIColor(red: 63/255, green: 116/255, blue: 164/255, alpha: 1)
  static let tintColorBright: UIColor = UIColor(red: 146/255, green: 186/255, blue: 224/255, alpha: 1)
  static let textColor: UIColor = UIColor.darkGrayColor()
  static let textColorBright: UIColor = UIColor.whiteColor()
  static let paneBgColor: UIColor = UIColor.whiteColor()

  static let paneBorderColor: UIColor = UIColor(red: 190/255, green: 190/255, blue: 190/255, alpha: 1)
  static let brightGreyColor: UIColor = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1)
  static let darkGreyColor: UIColor = UIColor(red: 55/255, green: 55/255, blue: 55/255, alpha: 1)
  
  static let warningColor: UIColor = UIColor.orangeColor()
  static let greenColor: UIColor = UIColor(red: 130/255, green: 202/255, blue: 56/255, alpha: 1)
  static let redColor: UIColor = UIColor(red: 209/255, green: 66/255, blue: 58/255, alpha: 1)
  
  // Fontsizes
  static let regularFont = UIFont.systemFontOfSize(12.0)
  static let headlineFont = UIFont.systemFontOfSize(16.0)
  static let settingFont = UIFont.systemFontOfSize(14.0)
  static let sumFont = UIFont.systemFontOfSize(18.0)
  static let statusFont = UIFont.systemFontOfSize(28.0)
  
//  static let receiptHeadingFont = UIFont.init(name: "HiraKakuProN-W3", size: 16)
//  static let receiptRegularFont = UIFont.init(name: "HiraKakuProN-W3", size: 14)
//  static let receiptBoldFont = UIFont.init(name: "HiraKakuProN-W6", size: 14)
  
  static let receiptHeadingFont = UIFont.systemFontOfSize(16)
  static let receiptRegularFont = UIFont.systemFontOfSize(14)
  static let receiptBoldFont = UIFont.boldSystemFontOfSize(14)
  
}
