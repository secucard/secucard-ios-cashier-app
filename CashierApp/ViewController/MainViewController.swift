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

class MainViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, BasketProductCellDelegate {
  
  let productReuseIdentifier = "ProductCell"
  let categoryReuseIdentifier = "CategoryCell"
  let basketProductReuseIdentifier = "BasketProductCell"
  let basketUserReuseIdentifier = "BasketUserCell"
  let checkinReuseIdentifier = "CheckinCell"
  
  var productCategoriesCollection:UICollectionView!
  var productsCollection:UICollectionView!
  var basketCollection:UICollectionView!
  var checkinsCollection:UICollectionView!
  
  var productCategories: [JSON]?
  var basket = [BasketItem]()
  var checkins = [Checkin]()
  
  var sumLabel: UILabel = UILabel()
  
  var sum: Float = 0.0 {
    didSet {
      sumLabel.text = "\(sum) €"
    }
  }
  
  var emptyButton: UIButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
  
  var currentCategory = 0 {
    didSet {
      self.productsCollection.reloadData()
      self.productCategoriesCollection.reloadData()
    }
  }
  
  
  var json: JSON = nil {
    didSet {
      if let cats = self.json["groups"].array {

        self.productCategories = cats
        self.productCategoriesCollection.reloadData()
        self.productsCollection.reloadData()
        
      }
    }
  }
  
  convenience init() {
    
    var categoriesLayout = UICollectionViewFlowLayout()
    categoriesLayout.scrollDirection = UICollectionViewScrollDirection.Horizontal
    categoriesLayout.minimumInteritemSpacing = 0
    categoriesLayout.estimatedItemSize = CGSizeMake(100, 50)
    
    var productsLayout = UICollectionViewFlowLayout()
    productsLayout.scrollDirection = UICollectionViewScrollDirection.Vertical
    productsLayout.itemSize = CGSizeMake(150, 150)
    
    var basketLayout = BasketFlowLayout()
    basketLayout.scrollDirection = UICollectionViewScrollDirection.Vertical
    basketLayout.estimatedItemSize = CGSizeMake(310, 70)
    
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
    self.productsCollection.contentInset = UIEdgeInsetsMake(10, 10, 10, 10)
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
    bottomBar.backgroundColor = UIColor.whiteColor()
    view.addSubview(bottomBar);
    
    bottomBar.snp_makeConstraints { (make) -> Void in
      make.left.bottom.width.equalTo(view)
      make.height.equalTo(100)
    }
    
    // tabs
    view.addSubview(productCategoriesCollection)
    
    productCategoriesCollection.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.7)
    
    productCategoriesCollection.snp_makeConstraints { (make) -> Void in
      make.top.equalTo(topBar.snp_bottom)
      make.left.equalTo(view)
      make.width.equalTo(490)
      make.height.equalTo(50)
    }
    
    view.addSubview(productsCollection)
    
    productsCollection.backgroundColor = UIColor.whiteColor()
    
    productsCollection.snp_makeConstraints { (make) -> Void in
      make.left.equalTo(view)
      make.bottom.equalTo(bottomBar.snp_top)
      make.top.equalTo(productCategoriesCollection.snp_bottom)
      make.width.equalTo(productCategoriesCollection)
    }
    
    view.addSubview(basketCollection)
    
    basketCollection.backgroundColor = UIColor.whiteColor()
    
    basketCollection.snp_makeConstraints { (make) -> Void in
      make.top.equalTo(topBar.snp_bottom)
      make.left.equalTo(productsCollection.snp_right)
      make.width.equalTo(310)
      make.bottom.equalTo(bottomBar.snp_top).offset(-100)
    }
    
    // sum field
    var sumView: UIView = UIView()
    view.addSubview(sumView)
    sumView.snp_makeConstraints { (make) -> Void in
      make.left.width.equalTo(basketCollection)
      make.bottom.equalTo(bottomBar.snp_top)
      make.height.equalTo(80)
    }
    
    // sum label
    sumLabel.font = Constants.sumFont
    sumView.addSubview(sumLabel)
    
    sumLabel.snp_makeConstraints { (make) -> Void in
      make.left.equalTo(20)
      make.top.height.equalTo(sumView)
      make.width.equalTo(100)
    }
    
    emptyButton.addTarget(self, action: "didTapEmptyButton", forControlEvents: UIControlEvents.TouchUpInside)
    emptyButton.backgroundColor = Constants.tintColor
    sumView.addSubview(emptyButton)
    
    emptyButton.snp_makeConstraints { (make) -> Void in
      make.right.equalTo(-10)
      make.centerY.equalTo(sumView)
      make.width.height.equalTo(50)
    }
    
    var topBorder: UIView = UIView()
    topBorder.backgroundColor = Constants.paneBorderColor
    sumView.addSubview(topBorder)
    topBorder.snp_makeConstraints { (make) -> Void in
      make.left.width.top.equalTo(sumView)
      make.height.equalTo(1)
    }
    
    view.addSubview(checkinsCollection)
    
    checkinsCollection.backgroundColor = UIColor.whiteColor()
    
    checkinsCollection.snp_makeConstraints { (make) -> Void in
      make.left.equalTo(basketCollection.snp_right)
      make.right.equalTo(view)
      make.bottom.equalTo(bottomBar.snp_top)
      make.top.equalTo(topBar.snp_bottom)
    }
    
    // line above bottom bar
    let bottomLine:UIView = UIView()
    bottomLine.backgroundColor = UIColor.darkGrayColor()
    view.addSubview(bottomLine)
    
    bottomLine.snp_makeConstraints { (make) -> Void in
      make.left.width.equalTo(view)
      make.bottom.equalTo(bottomBar.snp_top)
      make.height.equalTo(1)
    }
    
    // line between products and basket
    let vLine1:UIView = UIView()
    vLine1.backgroundColor = UIColor.darkGrayColor()
    view.addSubview(vLine1)
    
    vLine1.snp_makeConstraints { (make) -> Void in
      make.left.equalTo(basketCollection)
      make.top.equalTo(topBar.snp_bottom)
      make.bottom.equalTo(bottomBar.snp_top)
      make.width.equalTo(1)
    }
    
    // line between products and basket
    let vLine2:UIView = UIView()
    vLine2.backgroundColor = UIColor.darkGrayColor()
    view.addSubview(vLine2)
    
    vLine2.snp_makeConstraints { (make) -> Void in
      make.right.equalTo(basketCollection)
      make.top.equalTo(topBar.snp_bottom)
      make.bottom.equalTo(bottomBar.snp_top)
      make.width.equalTo(1)
    }
    
    self.view.backgroundColor = UIColor.whiteColor()
    
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
      
    case CollectionType.Product:
      
      if let items:[JSON] = json["groups"][currentCategory]["items"].array {
        return items.count
      } else {
        return 0
      }
      
    case CollectionType.Basket:
      
      return basket.count

    case CollectionType.Checkins:
      
      return checkins.count
      
      
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
        cell.backgroundColor = (indexPath.row == currentCategory) ? UIColor.whiteColor() : UIColor.lightGrayColor().colorWithAlphaComponent(0.2)
        
        return cell
        
      }
      
    case CollectionType.Product:
      
      if let items:[JSON] = json["groups"][currentCategory]["items"].array {
        
        var cell:ProductCell = collectionView.dequeueReusableCellWithReuseIdentifier(productReuseIdentifier, forIndexPath: indexPath) as! ProductCell
        cell.data = Product(product: items[indexPath.row])
        return cell
        
      }

    case CollectionType.Basket:
      
      let item:BasketItem = basket[indexPath.row]
        
        switch item.type {
          
        case BasketItemType.Checkin:
          
          var cell:BasketUserCell = collectionView.dequeueReusableCellWithReuseIdentifier(basketUserReuseIdentifier, forIndexPath: indexPath) as! BasketUserCell
          cell.data = item
          
          return cell
          
        case BasketItemType.Product:
          
          var cell:BasketProductCell = collectionView.dequeueReusableCellWithReuseIdentifier(basketProductReuseIdentifier, forIndexPath: indexPath) as! BasketProductCell
          cell.delegate = self
          cell.data = item
          
          return cell
          
        default:
          
          return UICollectionViewCell()
          
        }
      

    default:
      
      return UICollectionViewCell()
      
    }
    
    return UICollectionViewCell()
    
  }
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    
    switch identifierForCollection(collectionView) {
      
    case CollectionType.ProductCategories:
      
      currentCategory = indexPath.row
    
    case CollectionType.Product:
      
      if let items:[JSON] = json["groups"][currentCategory]["items"].array {
        
        var item:JSON = items[indexPath.row]
        let basketItem: BasketItem = BasketItem(product: Product(product: item))
        
        basket.append(basketItem)
        basketCollection.reloadData()
        
        calcPrice()
        
      }
      
    default:
      
      return
      
    }
  }
  
  func calcPrice() {
    sum = 0.0
    for bi:BasketItem in basket {
      if (bi.type == BasketItemType.Product) {
        sum += bi.price * bi.discount * Float(bi.amount)
      }
    }
  }
  
  func didTapEmptyButton() {
    
    basket = [BasketItem]()
    sum = 0.0
    basketCollection.reloadData()
    
  }
  
  func removeBasketItem(basketItem: BasketItem) {
    
    for (index:Int, basketItemTest:BasketItem) in enumerate(basket) {
      if (basketItem == basketItemTest) {
        basket.removeAtIndex(index)
        basketCollection.reloadData()
        calcPrice()
        return
      }
    }
    
  }
  
  func basketItemLayoutChanged(basketItem: BasketItem) {
    basketCollection.collectionViewLayout.invalidateLayout()
  }
  
  func basketItemChanged(basketItem: BasketItem) {
    calcPrice()
  }
  
}
