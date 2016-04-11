//
//  ConnectionButton.swift
//  CashierApp
//
//  Created by Jörn Schmidt on 03.10.15.
//  Copyright © 2015 secucard. All rights reserved.
//

import UIKit

protocol ConnectionButtonDelegate {
  
  func didTapDisconnect()
  func didTapConnect()
  
}

class ConnectionButton: UIView {

  let label = UILabel()
  let connectionIndicator = UIView()
  
  var hostConnected = false {
    didSet {
      
      if hostConnected {
        label.text = "disconnect"
        connectionIndicator.backgroundColor = Constants.greenColor
      } else {
        label.text = "connect"
        connectionIndicator.backgroundColor = Constants.redColor
      }
      
    }
  }
  
  var delegate: ConnectionButtonDelegate?
  
  init() {
    
    super.init(frame: CGRectNull)
    
    backgroundColor = Constants.tintColor
    
    connectionIndicator.layer.cornerRadius = 5
    connectionIndicator.layer.backgroundColor = UIColor.grayColor().CGColor
    
    addSubview(connectionIndicator)
    connectionIndicator.snp_makeConstraints { (make) -> Void in
      make.centerY.equalTo(self)
      make.width.height.equalTo(10)
      make.left.equalTo(10)
    }
    
    label.text = "unknown"
    label.textColor = UIColor.whiteColor()

    addSubview(label)
    label.snp_makeConstraints { (make) -> Void in
      make.left.equalTo(connectionIndicator.snp_right).offset(10)
      make.centerY.equalTo(self)
    }
    
    let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ConnectionButton.didTap))
    userInteractionEnabled = true
    addGestureRecognizer(tapRecognizer)
    
  }

  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
  
  // handlers
  func didTap() {
    
    if hostConnected {
      delegate?.didTapDisconnect()
    } else {
      delegate?.didTapConnect()
    }
    
  }
  
  func didDisconnect() {
    hostConnected = false
  }
  
  func didConnect() {
    hostConnected = true
  }
  
  
}
