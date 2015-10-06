//
//  ReceiptView.swift
//  CashierApp
//
//  Created by Jörn Schmidt on 21.09.15.
//  Copyright (c) 2015 secucard. All rights reserved.
//

import UIKit
import SecucardConnectSDK

class ReceiptView: UIView, UITableViewDelegate, UITableViewDataSource {

  var receiptLines: [SCSmartReceiptLine]? {
    didSet {
      if let receiptLines = receiptLines {
        tableView.reloadData()
      }
    }
  }
  
  let tableView = UITableView()
  
  init() {
    super.init(frame: CGRectNull)
    
    backgroundColor = UIColor.whiteColor()
    
    layer.masksToBounds = false;
    layer.shadowColor = UIColor.blackColor().CGColor
    layer.shadowOffset = CGSizeMake(0.0, 20.0)
    layer.shadowOpacity = 1
    
    tableView.dataSource = self
    tableView.delegate = self
    tableView.separatorStyle = UITableViewCellSeparatorStyle.None
    tableView.estimatedRowHeight = 10
    tableView.registerClass(ReceiptHeadingCell.self, forCellReuseIdentifier: "headingCell")
    tableView.registerClass(ReceiptTextCell.self, forCellReuseIdentifier: "textCell")
    tableView.registerClass(ReceiptKeyValueCell.self, forCellReuseIdentifier: "keyValueCell")
    tableView.registerClass(ReceiptSpaceCell.self, forCellReuseIdentifier: "emptyCell")
    
    addSubview(tableView)
    tableView.snp_makeConstraints { (make) -> Void in
      make.edges.equalTo(self).inset(10)
    }
    
  }

  required init(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    let shadowPath = UIBezierPath(rect: bounds)
    layer.shadowPath = shadowPath.CGPath
    
  }
  
  func addReceiptLine(line: SCSmartReceiptLine) {
    
    
  }
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

    guard receiptLines != nil else {
     return 0
    }
    
    return receiptLines!.count
    
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    guard receiptLines != nil else {
      return UITableViewCell()
    }
    
    let line = receiptLines![indexPath.row]
    var cell: ReceiptCell?
    
    if line.type == "separator" {
      
      cell = tableView.dequeueReusableCellWithIdentifier("headingCell", forIndexPath: indexPath) as! ReceiptHeadingCell

    } else if line.type == "name-value" {
      
      cell = tableView.dequeueReusableCellWithIdentifier("keyValueCell", forIndexPath: indexPath) as! ReceiptKeyValueCell
      
    } else if line.type == "textline" {
      
      cell = tableView.dequeueReusableCellWithIdentifier("textCell", forIndexPath: indexPath) as! ReceiptTextCell
      
    } else {
      
      cell = tableView.dequeueReusableCellWithIdentifier("emptyCell", forIndexPath: indexPath) as! ReceiptSpaceCell
    }

    cell!.data = line
    return cell!
    
  }
  

}
