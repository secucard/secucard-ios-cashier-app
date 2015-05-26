//
//  MainViewController.swift
//  CashierApp
//
//  Created by Jörn Schmidt on 16.05.15.
//  Copyright (c) 2015 secucard. All rights reserved.
//

import UIKit
import SwiftyJSON
import SnapKit

enum CollectionType {
  case Product
  case ProductCategories
  case Basket
  case Checkins
  case Unknown
}

class MainViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
  
  var productReuseIdentifier = "ProductCell"
  var categoryReuseIdentifier = "CategoryCell"
  var basketProductReuseIdentifier = "BasketProductCell"
  var basketUserReuseIdentifier = "BasketUserCell"
  var checkinReuseIdentifier = "CheckinCell"
  
  var layout = UICollectionViewLayout()
  
  var productCategoriesCollection:UICollectionView!
  var productsCollection:UICollectionView!
  var basketCollection:UICollectionView!
  var checkinsCollection:UICollectionView!

  var productCategories: [JSON]?
  var basket = [AnyObject]()
  var checkins = [AnyObject]()

  
  var json: JSON {
    set {
      if let cats = newValue["groups"].array {
        self.productCategories = cats
        
        self.productCategoriesCollection.reloadData()
        self.productsCollection.reloadData()
        
      }
    }
    get {
      return self.json
    }
  }
  
  convenience init() {
    
    var categoriesLayout = UICollectionViewFlowLayout()
    categoriesLayout.scrollDirection = UICollectionViewScrollDirection.Horizontal
    categoriesLayout.itemSize = CGSizeMake(100, 50)
    
    var productsLayout = UICollectionViewFlowLayout()
    productsLayout.scrollDirection = UICollectionViewScrollDirection.Horizontal
    productsLayout.itemSize = CGSizeMake(100, 100)
    
    var basketLayout = UICollectionViewFlowLayout()
    basketLayout.scrollDirection = UICollectionViewScrollDirection.Vertical
    basketLayout.itemSize = CGSizeMake(100, 100)
    
    var checkinLayout = UICollectionViewFlowLayout()
    checkinLayout.scrollDirection = UICollectionViewScrollDirection.Vertical
    checkinLayout.itemSize = CGSizeMake(100, 100)
    
    self.init(nibName:nil,bundle:nil)
    
    self.productCategoriesCollection = UICollectionView(frame: CGRectNull, collectionViewLayout: categoriesLayout)
    self.productCategoriesCollection.registerClass(ProductCategoryCell.self, forCellWithReuseIdentifier: categoryReuseIdentifier)
    self.productCategoriesCollection.delegate = self
    self.productCategoriesCollection.dataSource = self
    
    self.productsCollection = UICollectionView(frame: CGRectNull, collectionViewLayout: productsLayout)
    self.productsCollection.registerClass(ProductCell.self, forCellWithReuseIdentifier: productReuseIdentifier)
    self.productsCollection.delegate = self
    self.productsCollection.dataSource = self
    
    self.basketCollection = UICollectionView(frame: CGRectNull, collectionViewLayout: basketLayout)
    self.basketCollection.registerClass(BasketUserCell.self, forCellWithReuseIdentifier: basketUserReuseIdentifier)
    self.basketCollection.registerClass(BasketProductCell.self, forCellWithReuseIdentifier: basketProductReuseIdentifier)
    self.basketCollection.delegate = self
    self.basketCollection.dataSource = self
    
    self.checkinsCollection = UICollectionView(frame: CGRectNull, collectionViewLayout: checkinLayout)
    self.checkinsCollection.registerClass(CheckinCell.self, forCellWithReuseIdentifier: checkinReuseIdentifier)
    self.checkinsCollection.delegate = self
    self.checkinsCollection.dataSource = self
    
  }
  
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
    super.init(nibName: nibNameOrNil , bundle: nibBundleOrNil)
  }

  required init(coder:NSCoder) {
    super.init(coder:coder)
  }
  
  override func viewDidLoad() {
    
    super.viewDidLoad()
    
    view.backgroundColor = UIColor.whiteColor()
    
    // top bar
    let topBar:UIView = UIView()
    topBar.backgroundColor = UIColor.darkGrayColor()
    view.addSubview(topBar)
    
    topBar.snp_makeConstraints { (make) -> Void in
      make.left.top.width.equalTo(view)
      make.height.equalTo(50)
    }
    
    var bottomBar:UIView = UIView()
    bottomBar.backgroundColor = UIColor.darkGrayColor()
    view.addSubview(bottomBar);
    
    bottomBar.snp_makeConstraints { (make) -> Void in
      make.left.bottom.width.equalTo(view)
      make.height.equalTo(100)
    }


    // tabs
    view.addSubview(productCategoriesCollection)
    
    productCategoriesCollection.backgroundColor = UIColor.redColor().colorWithAlphaComponent(0.7)
    
    productCategoriesCollection.snp_makeConstraints { (make) -> Void in
      make.top.equalTo(topBar.snp_bottom)
      make.left.equalTo(view)
      make.right.equalTo(view.snp_centerX)
      make.height.equalTo(50)
    }
    
    view.addSubview(productsCollection)
    
    productsCollection.backgroundColor = UIColor.greenColor().colorWithAlphaComponent(0.7)
    
    productsCollection.snp_makeConstraints { (make) -> Void in
      make.left.equalTo(view)
      make.bottom.equalTo(bottomBar.snp_top)
      make.top.equalTo(productCategoriesCollection.snp_bottom)
      make.width.equalTo(productCategoriesCollection)
    }
    
    view.addSubview(basketCollection)
    
    basketCollection.backgroundColor = UIColor.yellowColor().colorWithAlphaComponent(0.7)
  
    basketCollection.snp_makeConstraints { (make) -> Void in
      make.top.equalTo(topBar.snp_bottom)
      make.left.equalTo(view.snp_centerX)
      make.right.equalTo(view)
      make.bottom.equalTo(view.snp_centerY)
    }
    
    view.addSubview(checkinsCollection)
    
    checkinsCollection.backgroundColor = UIColor.blueColor().colorWithAlphaComponent(0.7)
    
    checkinsCollection.snp_makeConstraints { (make) -> Void in
      make.left.equalTo(view.snp_centerX)
      make.right.equalTo(view)
      make.bottom.equalTo(bottomBar.snp_top)
      make.top.equalTo(view.snp_centerY)
    }
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  func identifierForCollection(collection: UICollectionView) -> CollectionType {
    if collection == productCategoriesCollection {
      return CollectionType.ProductCategories
    } else if collection == productsCollection {
      return CollectionType.Product
    } else if collection == basketCollection {
      return CollectionType.Basket
    } else if collection == checkinsCollection {
      return CollectionType.Checkins
    } else {
      return CollectionType.Unknown
    }
  }
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
    switch identifierForCollection(collectionView) {
    
    case CollectionType.ProductCategories:
      if let numCategories = productCategories?.count {
        return numCategories
      } else {
        return 0
      }
      
    default:
      return 0
      
    }
    
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    
    
    
    switch identifierForCollection(collectionView) {
      
    case CollectionType.ProductCategories:
      
      if let categories = productCategories {
        
        var cell:ProductCategoryCell = collectionView.dequeueReusableCellWithReuseIdentifier(categoryReuseIdentifier, forIndexPath: indexPath) as! ProductCategoryCell
        cell.data = categories[indexPath.row]
        return cell
        
      }
      
    default:
      
      return UICollectionViewCell()
      
    }
    
    return UICollectionViewCell()
    
  }
  

  
  /*
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
  // Get the new view controller using segue.destinationViewController.
  // Pass the selected object to the new view controller.
  }
  */
  
}
