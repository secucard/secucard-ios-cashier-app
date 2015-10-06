//
//  MainViewController.swift
//  CashierApp
//
//  Created by Jörn Schmidt on 16.05.15.
//  Copyright (c) 2015 secucard. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import SnapKit
import SecucardConnectSDK
import Alamofire

enum CollectionType {
  case Product
  case ProductCategories
  case Basket
  case Checkins
  case Unknown
}

enum PayMethod : String {
  case Unset = "unset"
  case Demo = "demo"
  case Cash = "cash"
  case Auto = "auto"
  case Cashless = "cashless"
  case Loyalty = "loyalty"
  case Paypal = "paypal"
}

class MainViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, BasketProductCellDelegate, ScanViewControllerDelegate, BasketUserCellDelegate, SCLogManagerDelegate, ScanCardViewDelegate, UIGestureRecognizerDelegate, ConnectionButtonDelegate, AddProductViewDelegate, TransactionInfoInputViewDelegate {
  
  let productReuseIdentifier = "ProductCell"
  let categoryReuseIdentifier = "CategoryCell"
  let basketProductReuseIdentifier = "BasketProductCell"
  let basketUserReuseIdentifier = "BasketUserCell"
  let checkinReuseIdentifier = "CheckinCell"
  
  let basketSectionHeaerReuseIdentifier = "HeaderView"
  let productSectionHeaerReuseIdentifier = "ProductsHeaderView"
  
  var productCategoriesCollection: UICollectionView
  var productsCollection: UICollectionView
  var basketCollection: UICollectionView
  var checkinsCollection: UICollectionView
  
  let categoriesLayout = UICollectionViewFlowLayout()
  let productsLayout = UICollectionViewFlowLayout()
  let basketLayout = UICollectionViewFlowLayout()
  let checkinLayout = UICollectionViewFlowLayout()
  
  var longPress:UILongPressGestureRecognizer!
  
  var topBorder = UIView()
  var sumView = UIView()
  let bottomBar = UIView()
  
  var manager: Manager?
  
  var productCategories = [String:[String:[SCSmartProduct]]]()
  var checkins = [SCSmartCheckin]() {
    didSet {
      checkinsCollection.reloadData()
    }
  }
  
  var basket = [BasketItem]() {
    didSet {
      CheckTransactionReady()
      basketCollection.reloadData()
      calcPrice()
      updateTransactionBasket { (success, error) -> Void in
        if let error = error {
          SCLogManager.error(error)
        }
      }
    }
  }
  
  var customerUsed: SCSmartIdent? {
    didSet {
      CheckTransactionReady()
      basketCollection.reloadData()
    }
  }
  
  var scanCardView = ScanCardView()
  
  let connectionButton = ConnectionButton()
  
  let showLogButton: PaymentButton
  let settingsButton: PaymentButton
  
  let payAutoButton = PaymentButton(payMethod: PayMethod.Auto, action: Selector("didTapPayButton:"))
  let payDemoButton = PaymentButton(payMethod: PayMethod.Demo, action: Selector("didTapPayButton:"))
  let payPaypalButton = PaymentButton(payMethod: PayMethod.Paypal, action: Selector("didTapPayButton:"))
  let payLoyaltyButton = PaymentButton(payMethod: PayMethod.Loyalty, action: Selector("didTapPayButton:"))
  let payCashlessButton = PaymentButton(payMethod: PayMethod.Cashless, action: Selector("didTapPayButton:"))
  let payCashButton = PaymentButton(payMethod: PayMethod.Cash, action: Selector("didTapPayButton:"))
  
  let availableButtons: [PaymentButton]
  
  let logView = LogView()
  
  let sumLabel = UILabel()
  
  var sum:Float = 0.0 {
    didSet {
      sumLabel.text = String(format: "%.2f €", sum/100)
    }
  }
  
  let emptyButton = UIButton(type: UIButtonType.Custom)
  
  let transactionInfoButton = UIButton(type: UIButtonType.Custom)
  
  var currentCategory = 0 {
    didSet {
      self.productsCollection.reloadData()
      self.productCategoriesCollection.reloadData()
    }
  }
  
  
  var json: JSON = nil {
    
    didSet {
      
      // create categories
      if let items = self.json["items"].array {
        
        var catArray = [String:[String:[SCSmartProduct]]]()
        
        for item:JSON in items {
          
          var product: SCSmartProduct?
          do {
            product = try MTLJSONAdapter.modelOfClass(SCSmartProduct.self, fromJSONDictionary: item.dictionaryObject!) as? SCSmartProduct
          } catch {
            print("cannot parse product")
          }
          
          if let groupname1 = product?.groups[0].desc, product = product {
            
            if catArray[groupname1] == nil {
              catArray[groupname1] = [String:[SCSmartProduct]]()
            }
            
            if product.groups.count <= 1 {
              
              if catArray[groupname1]!["Normal"] == nil {
                catArray[groupname1]!["Normal"] = [SCSmartProduct]()
              }

              catArray[groupname1]!["Normal"]!.append(product)
              
            } else {
            
              if let groupname2 = product.groups[1].desc {
                if catArray[groupname1]![groupname2] == nil {
                  catArray[groupname1]![groupname2] = [SCSmartProduct]()
                }
                
                catArray[groupname1]![groupname2]!.append(product)
                
              }
              
            }
            
          }
          
        }
        
        // order by key
//        let sortedCats = catArray.sort { $0.0 < $1.0 }
        
        self.productCategories = catArray
        self.productCategoriesCollection.reloadData()
        self.productsCollection.reloadData()
        
      }
      
    }
    
  }
  
  var currentTransaction: SCSmartTransaction = SCSmartTransaction()
  
  init() {
    
    self.checkins = [SCSmartCheckin]()
    self.basket = [BasketItem]()
    
    categoriesLayout.scrollDirection = UICollectionViewScrollDirection.Horizontal
    categoriesLayout.minimumInteritemSpacing = 0
    categoriesLayout.estimatedItemSize = CGSizeMake(100, 50)
    
    productCategoriesCollection = UICollectionView(frame: CGRectMake(0, 0, 10, 10), collectionViewLayout: categoriesLayout)
    productCategoriesCollection.registerClass(ProductCategoryCell.self, forCellWithReuseIdentifier: categoryReuseIdentifier)
    
    productsLayout.scrollDirection = UICollectionViewScrollDirection.Vertical
    productsLayout.itemSize = CGSizeMake(150, 150)
    productsLayout.headerReferenceSize = CGSizeMake(310, 60)
    
    productsCollection = UICollectionView(frame: CGRectMake(0, 0, 10, 10), collectionViewLayout: productsLayout)
    productsCollection.registerClass(ProductCell.self, forCellWithReuseIdentifier: productReuseIdentifier)
    productsCollection.registerClass(ProductsSectionHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: productSectionHeaerReuseIdentifier)
    productsCollection.contentInset = UIEdgeInsetsMake(10, 10, 10, 10)
    
    basketLayout.scrollDirection = UICollectionViewScrollDirection.Vertical
    basketLayout.estimatedItemSize = CGSizeMake(310, 70)
    basketLayout.headerReferenceSize = CGSizeMake(310, 30)
    
    basketCollection = UICollectionView(frame: CGRectMake(0, 0, 10, 10), collectionViewLayout: basketLayout)
    basketCollection.registerClass(CheckinCell.self, forCellWithReuseIdentifier: checkinReuseIdentifier)
    basketCollection.registerClass(BasketUserCell.self, forCellWithReuseIdentifier: basketUserReuseIdentifier)
    basketCollection.registerClass(BasketProductCell.self, forCellWithReuseIdentifier: basketProductReuseIdentifier)
    basketCollection.registerClass(SectionheaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: basketSectionHeaerReuseIdentifier)
    
    checkinLayout.scrollDirection = UICollectionViewScrollDirection.Vertical
    checkinLayout.itemSize = CGSizeMake(224, 50)
    
    checkinsCollection = UICollectionView(frame: CGRectMake(0, 0, 10, 10), collectionViewLayout: checkinLayout)
    checkinsCollection.registerClass(CheckinCell.self, forCellWithReuseIdentifier: checkinReuseIdentifier)
    
    // Payment buttons initialization
    showLogButton = PaymentButton(icon: "Log", action: Selector("didTapShowLog"))
    settingsButton = PaymentButton(icon: "Settings", action: Selector("didTapShowSettings"))
    
    availableButtons = [payDemoButton, payPaypalButton, payLoyaltyButton, payCashlessButton, payAutoButton, payCashButton]
    
    // call super initialization
    super.init(nibName: nil, bundle: nil)
    
    showLogButton.target = self
    settingsButton.target = self
    
    SCLogManager.sharedManager().delegate = self
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("clientDidDisconnect:"), name: "clientDidDisconnect", object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("clientDidConnect:"), name: "clientDidConnect", object: nil)
    
    // add delegates to collections
    self.productCategoriesCollection.delegate = self
    self.productCategoriesCollection.dataSource = self
    
    self.productsCollection.delegate = self
    self.productsCollection.dataSource = self
    
    longPress = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
    longPress.minimumPressDuration = 1.0
    longPress.delegate = self
    longPress.cancelsTouchesInView  = true
    productsCollection.addGestureRecognizer(longPress)
    productsCollection.panGestureRecognizer.requireGestureRecognizerToFail(longPress)
    
    self.basketCollection.delegate = self
    self.basketCollection.dataSource = self
    
    self.checkinsCollection.delegate = self
    self.checkinsCollection.dataSource = self
    
    payAutoButton.target = self
    payCashlessButton.target = self
    payCashButton.target = self
    payLoyaltyButton.target = self
    payPaypalButton.target = self
    payDemoButton.target = self
    
    // security
    
//    let serverTrustPolicies: [String: ServerTrustPolicy] = [
//      "connect.secucard.com": .DisableEvaluation
//    ]
    
//    manager = Manager(
//      serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
//    )
    
  }
  
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    
    super.viewDidLoad()
    
    view.backgroundColor = UIColor.whiteColor()
    
    // top bar
    let topBar:UIView = UIView()
    topBar.backgroundColor = Constants.darkGreyColor
    view.addSubview(topBar)
    
    topBar.snp_makeConstraints { (make) -> Void in
      make.left.top.width.equalTo(view)
      make.height.equalTo(50)
    }
    
    
    bottomBar.backgroundColor = UIColor.whiteColor()
    view.addSubview(bottomBar);
    
    bottomBar.snp_makeConstraints { (make) -> Void in
      make.left.bottom.width.equalTo(view)
      make.height.equalTo(100)
    }
    
    // tabs
    view.addSubview(productCategoriesCollection)
    
    productCategoriesCollection.backgroundColor = UIColor.darkGrayColor()
    
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
    
    let checkinHeader = UILabel()
    checkinHeader.text = "   Check-ins"
    checkinHeader.textColor = Constants.textColorBright
    checkinHeader.backgroundColor = Constants.darkGreyColor
    
    view.addSubview(checkinHeader)
    
    checkinHeader.snp_makeConstraints { (make) -> Void in
      make.top.equalTo(topBar.snp_bottom)
      make.left.equalTo(productCategoriesCollection.snp_right)
      make.width.equalTo(224)
      make.height.equalTo(50)
    }
    
    view.addSubview(checkinsCollection)
    
    checkinsCollection.backgroundColor = UIColor.whiteColor()
    
    checkinsCollection.snp_makeConstraints { (make) -> Void in
      make.left.equalTo(productsCollection.snp_right)
      make.top.equalTo(checkinHeader.snp_bottom)
      make.width.equalTo(224)
      make.bottom.equalTo(bottomBar.snp_top)
    }
    
    let basketHeader = UILabel()
    basketHeader.text = "   Warenkorb"
    basketHeader.textColor = Constants.textColorBright
    basketHeader.backgroundColor = Constants.darkGreyColor
    
    view.addSubview(basketHeader)
    
    basketHeader.snp_makeConstraints { (make) -> Void in
      make.top.equalTo(topBar.snp_bottom)
      make.left.equalTo(checkinHeader.snp_right)
      make.right.equalTo(view)
      make.height.equalTo(50)
    }

    view.addSubview(basketCollection)
    
    basketCollection.backgroundColor = UIColor.whiteColor()
    
    basketCollection.snp_makeConstraints { (make) -> Void in
      make.bottom.equalTo(bottomBar.snp_top).offset(-80)
      make.top.equalTo(basketHeader.snp_bottom)
      make.left.equalTo(checkinsCollection.snp_right)
      make.right.equalTo(view)
    }
    
    // sum field
    sumView.backgroundColor = Constants.brightGreyColor
    
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
    
    emptyButton.setImage(UIImage(named: "Trash"), forState: UIControlState.Normal)
    emptyButton.addTarget(self, action: "didTapEmptyButton", forControlEvents: UIControlEvents.TouchUpInside)
    emptyButton.backgroundColor = Constants.warningColor
    sumView.addSubview(emptyButton)
    
    emptyButton.snp_makeConstraints { (make) -> Void in
      make.right.equalTo(-10)
      make.centerY.equalTo(sumView)
      make.width.height.equalTo(50)
    }
    
    transactionInfoButton.setTitle("i", forState: UIControlState.Normal)
    transactionInfoButton.addTarget(self, action: "didTapTransactionInformation", forControlEvents: UIControlEvents.TouchUpInside)
    transactionInfoButton.backgroundColor = Constants.tintColor
    sumView.addSubview(transactionInfoButton)
    
    transactionInfoButton.snp_makeConstraints { (make) -> Void in
      make.right.equalTo(emptyButton.snp_left).offset(-10)
      make.centerY.equalTo(sumView)
      make.width.height.equalTo(50)
    }
    
    topBorder.backgroundColor = Constants.brightGreyColor
    sumView.addSubview(topBorder)
    topBorder.snp_makeConstraints { (make) -> Void in
      make.left.width.top.equalTo(sumView)
      make.height.equalTo(1)
    }
    // line above bottom bar
    
    let bottomLine:UIView = UIView()
    bottomLine.backgroundColor = Constants.brightGreyColor
    view.addSubview(bottomLine)
    
    bottomLine.snp_makeConstraints { (make) -> Void in
      make.left.width.equalTo(view)
      make.bottom.equalTo(bottomBar.snp_top)
      make.height.equalTo(1)
    }
    
    // line between products and basket
    
    let vLine1:UIView = UIView()
    vLine1.backgroundColor = Constants.brightGreyColor
    view.addSubview(vLine1)
    
    vLine1.snp_makeConstraints { (make) -> Void in
      make.left.equalTo(checkinsCollection)
      make.top.equalTo(topBar.snp_bottom)
      make.bottom.equalTo(bottomBar.snp_top)
      make.width.equalTo(1)
    }
    
    // line between basket and checkins
    
    let vLine2:UIView = UIView()
    vLine2.backgroundColor = Constants.brightGreyColor
    view.addSubview(vLine2)
    
    vLine2.snp_makeConstraints { (make) -> Void in
      make.left.equalTo(basketCollection)
      make.top.equalTo(topBar.snp_bottom)
      make.bottom.equalTo(bottomBar.snp_top)
      make.width.equalTo(1)
    }
    
    self.view.backgroundColor = UIColor.whiteColor()
    
    // Button: Pay with secucard
    
    var lastButton: PaymentButton?
    for button in availableButtons {
      
      bottomBar.addSubview(button)
      
      button.snp_makeConstraints { (make) -> Void in
        if let lastButton = lastButton {
          make.right.equalTo(lastButton.snp_left).offset(-10)
        } else {
          make.right.equalTo(-10)
        }
        
        make.centerY.equalTo(bottomBar)
        make.width.equalTo(100)
        make.height.equalTo(50)
      }
      
      lastButton = button
      
    }
    
    // connection button
    
    bottomBar.addSubview(connectionButton)
    connectionButton.hostConnected = SCConnectClient.sharedInstance().connected
    connectionButton.delegate = self
    
    connectionButton.snp_makeConstraints { (make) -> Void in
      make.left.equalTo(10)
      make.centerY.equalTo(bottomBar)
      make.height.equalTo(50)
      make.width.equalTo(120)
    }
    
    // show log button
    
    bottomBar.addSubview(showLogButton)
    
    showLogButton.snp_makeConstraints { (make) -> Void in
      make.left.equalTo(connectionButton.snp_right).offset(10)
      make.centerY.equalTo(bottomBar)
      make.width.equalTo(50)
      make.height.equalTo(50)
    }
    
    // show log button
    
    bottomBar.addSubview(settingsButton)
    
    settingsButton.snp_makeConstraints { (make) -> Void in
      make.left.equalTo(showLogButton.snp_right).offset(10)
      make.centerY.equalTo(bottomBar)
      make.width.equalTo(50)
      make.height.equalTo(50)
    }
    
    // log view
    
    view.addSubview(logView)
    
    logView.snp_makeConstraints { (make) -> Void in
      make.edges.equalTo(view)
    }
    
    logView.hidden = true
    
    calcPrice()
    CheckTransactionReady()
    
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
  
  func calcPrice() {
    sum = 0.0
    for bi:BasketItem in basket {
      if (bi.type == BasketItemType.Product) {
        let newVal = sum + (Float(bi.price) * bi.discount * Float(bi.amount))
        sum = newVal
      }
    }
  }
  
  func didTapEmptyButton() {
    
    sum = 0.0
    basket = [BasketItem]()
    
  }
  
  func didTapTransactionInformation() {
  
    let infoView = TransactionInfoInputView(transactionRef: currentTransaction.transactionRef, merchantRef: currentTransaction.merchantRef)
    infoView.delegate = self
    infoView.alpha = 0

    view.addSubview(infoView)
    infoView.snp_makeConstraints { (make) -> Void in
      make.edges.equalTo(view)
    }
    
    UIView.animateWithDuration(0.4) { () -> Void in
      infoView.alpha = 1
    }
    
  }
  
  // MARK: - UICollectionViewDelegate, UICollectionViewDataSource
  
  func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    
    switch identifierForCollection(collectionView) {
      
    case CollectionType.Product:
      return Array(Array(productCategories.values)[currentCategory].keys).count
      
    case CollectionType.Basket:
      return 2
      
    default:
      return 1
      
    }
  }
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
    switch identifierForCollection(collectionView) {
      
    case CollectionType.ProductCategories:
      
        return productCategories.count
      
    case CollectionType.Product:
      
      let subCatKey = Array(Array(productCategories.values)[currentCategory].keys)[section]
      
      if let items:[SCSmartProduct] = Array(productCategories.values)[currentCategory][subCatKey] {
        return items.count
      } else {
        return 0
      }
      
    case CollectionType.Basket:
      
      if (section == 0) {
        
        return basket.count
        
      } else {
        
        if let _ = customerUsed {
          return 1
        } else {
          return 0
        }
        
      }
      
    case CollectionType.Checkins:
      
      return checkins.count
      
    default:
      return 0
      
    }
    
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    
    switch identifierForCollection(collectionView) {
      
    case CollectionType.ProductCategories:
      
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(categoryReuseIdentifier, forIndexPath: indexPath) as! ProductCategoryCell
        
        cell.title = Array(productCategories.keys)[indexPath.row]
        cell.data = Array(productCategories.values)[indexPath.row]
        
        cell.backgroundColor = (indexPath.row == currentCategory) ? UIColor.whiteColor() : Constants.brightGreyColor
        
        return cell
      
    case CollectionType.Product:
      
      let subCatKey = Array(Array(productCategories.values)[currentCategory].keys)[indexPath.section]
      
      if let items:[SCSmartProduct] = Array(productCategories.values)[currentCategory][subCatKey] {
        
        if let cell = collectionView.dequeueReusableCellWithReuseIdentifier(productReuseIdentifier, forIndexPath: indexPath) as? ProductCell {
          cell.data = items[indexPath.row]
          return cell
        }
        
      }
      
    case CollectionType.Basket:
      
      if (indexPath.section == 0) {
        
        let item:BasketItem = basket[indexPath.row]
        
        if let cell = collectionView.dequeueReusableCellWithReuseIdentifier(basketProductReuseIdentifier, forIndexPath: indexPath) as? BasketProductCell {
          cell.delegate = self
          cell.data = item
          return cell
        }
        
      } else {
        
        if let cell = collectionView.dequeueReusableCellWithReuseIdentifier(basketUserReuseIdentifier, forIndexPath: indexPath) as? BasketUserCell {
          cell.data = customerUsed
          cell.delegate = self
          return cell
        }
        
      }
      
      
    case CollectionType.Checkins:
      
      let checkin = checkins[indexPath.row]
      
      if let cell = collectionView.dequeueReusableCellWithReuseIdentifier(checkinReuseIdentifier, forIndexPath: indexPath) as? CheckinCell {
        cell.data = checkin
        return cell
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
      
      let subCatKey = Array(Array(productCategories.values)[currentCategory].keys)[indexPath.section]
      
      if let items:[SCSmartProduct] = Array(productCategories.values)[currentCategory][subCatKey] {
        
        let item = items[indexPath.row]
        let basketItem: BasketItem = BasketItem(product: item)
        
        basket.append(basketItem)
        calcPrice()
        
      }
      
    case CollectionType.Checkins:
      
      let checkin = checkins[indexPath.row]
      
      let ident = SCSmartIdent()
      ident.type = "checkin"
      ident.value = checkin.id
      
      customerUsed = ident
      updateTransactionIdent({ (success, error) -> Void in
        
      })
      
    default:
      
      return
      
    }
  }
  
  func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
  
    if collectionView == productsCollection {
      
      if (kind == UICollectionElementKindSectionHeader) {
        
        let headerView: ProductsSectionHeaderView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: productSectionHeaerReuseIdentifier, forIndexPath: indexPath) as! ProductsSectionHeaderView
        let subCatKey = Array(Array(productCategories.values)[currentCategory].keys)[indexPath.section]
        
        headerView.label.text = subCatKey
        
        return headerView

      }
      
    } else if collectionView == basketCollection {
      
      if (kind == UICollectionElementKindSectionHeader) {
        
        let headerView: SectionheaderView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: basketSectionHeaerReuseIdentifier, forIndexPath: indexPath) as! SectionheaderView
        
        let button = UIButton(type: UIButtonType.Custom)
        button.backgroundColor = Constants.tintColor
        button.setTitle("+", forState: UIControlState.Normal)
        
        if indexPath.section == 0 {
          
          headerView.label.text = "Produkte"
          button.addTarget(self, action: Selector("didTapAddProduct"), forControlEvents: UIControlEvents.TouchUpInside)
          
        } else {
          
          headerView.label.text = "Idents"
          button.addTarget(self, action: Selector("didTapAddIdent"), forControlEvents: UIControlEvents.TouchUpInside)
          
        }
        
        headerView.addSubview(button)
        button.snp_makeConstraints(closure: { (make) -> Void in
          make.right.equalTo(headerView)
          make.centerY.equalTo(headerView)
          make.width.height.equalTo(30)
        })
        
        return headerView
        
      }
      
    }
    
    return SectionheaderView()
    
  }
  
  
  
  
  // MARK: - ModifyPriceViewDelegate
  
  func removeBasketItem(basketItem: BasketItem) {
    
    for (index, basketItemTest) in basket.enumerate() {
      if (basketItem == basketItemTest) {
        basket.removeAtIndex(index)
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
  
  // MARK: - Payment actions
  
  // payment actions

  func didTapPayButton(button: PaymentButton) {
    sendTransaction(button.payMethod)
  }

  func showScanCardView() {

    if TARGET_IPHONE_SIMULATOR == 1 {
      scanCardView = ScanCardView()
      scanCardView.delegate = self
      view.addSubview(scanCardView)
      
      scanCardView.snp_makeConstraints { (make) -> Void in
        make.edges.equalTo(view)
      }
    } else {
      let view = ScanViewController()
      view.delegate = self;
      self.presentViewController(view, animated: true, completion: nil)
    }
    
    
  }
  
  func updateTransactionBasket(handler: (success: Bool,error: NSError?) -> Void) {
    
    // create a basket
    let basket = SCSmartBasket()
    
    var productList = [AnyObject]()
    for basketItem:BasketItem in self.basket {
      if let productData = basketItem.product {
        productList.append(productData)
        //productList.append(productData.stringValue)
      }
    }
    
    basket.products = productList
    
    currentTransaction.basket = basket
    
    // create a basket info
    
    let basketInfo = SCSmartBasketInfo()
    basketInfo.sum = Int(sum)
    basketInfo.currency = "EUR"
    currentTransaction.basketInfo = basketInfo
    
    saveTransaction({ (success, error) -> Void in

      if let error = error {
        SCLogManager.error(error)
      }
      
      handler(success: success, error: error)
      
    })
    
  }
  
  func updateTransactionIdent(handler: (success: Bool,error: NSError?) -> Void) {
    
    // create the ident
    if let ident = customerUsed {
      currentTransaction.idents = [ident]
      saveTransaction({ (success, error) -> Void in
        
        if let error = error {
          SCLogManager.error(error)
        }
        
        if let resolvedIdent = self.currentTransaction.idents[0] as? SCSmartIdent {
          
          dispatch_async(dispatch_get_main_queue(), { () -> Void in

            if !resolvedIdent.valid {
              SCLogManager.errorWithDescription("Identifizierung fehlgeschlagen")
              self.customerUsed = nil
            } else {
              self.customerUsed = resolvedIdent
            }
            
            handler(success: success, error: error)
          
          })
        }
        
      })
    }
    
  }
  
  func saveTransaction(handler: (success: Bool,error: NSError?) -> Void) {
    
    currentTransaction.merchantRef = Constants.merchantRef
    currentTransaction.transactionRef = "\(Constants.merchantRef)_\(NSDate().timeIntervalSince1970)"
    
    if currentTransaction.id == nil {
      SCSmartTransactionService.sharedService().createTransaction(currentTransaction, completionHandler: { (createdTransaction: SCSmartTransaction?, error: NSError?) -> Void in
        
        if let error = error {
          
          handler(success: false, error: error)
          return
          
        } else {
        
          if let createdTransaction = createdTransaction {
            self.currentTransaction = createdTransaction
          }
          
        }
        
        self.updateTransactionBasket({ (success, error) -> Void in
        
          if let error = error {
            
            handler(success: false, error: error)
            return
            
          } else {
          
            self.updateTransactionIdent({ (success, error) -> Void in
              
              handler(success: createdTransaction != nil, error: error)
              
            })
            
          }
          
        })
        
      })
      
    } else {
      
      SCSmartTransactionService.sharedService().updateTransaction(currentTransaction, completionHandler: { (updatedTransaction: SCSmartTransaction?, error: NSError?) -> Void in
        
        if let updatedTransaction = updatedTransaction {
          self.currentTransaction = updatedTransaction
        }
        
        handler(success: updatedTransaction != nil, error: error)
        
      })
      
    }
    
  }
  
  func sendTransaction(method: PayMethod) {
    
    // if not created yet, create it and try again
    guard currentTransaction.id != nil else {
      saveTransaction({ (success, error) -> Void in
        if success {
          self.sendTransaction(method)
        }
      })
      return
    }
    
    let statusView = TransactionStatusView();
    view.addSubview(statusView)
    
    statusView.snp_makeConstraints { (make) -> Void in
      make.edges.equalTo(view)
    }
    
    SCSmartTransactionService.sharedService().addEventHandler({ (event: SCGeneralEvent?) -> Void in
      
      if let event = event {
        
        if event.target == SCGeneralNotification.object().lowercaseString {
          
          // TODO: what to do if data is array ???
          if let _ = event.data as? [AnyObject] {
            
          } else if let eventDataDict = event.data as? [NSObject:AnyObject] {
          
            if let notification = try? MTLJSONAdapter.modelOfClass(SCGeneralNotification.self, fromJSONDictionary: eventDataDict) as? SCGeneralNotification {
              statusView.addStatus(notification!.text)
            } else {
              //SCLogManager.error(<#T##error: NSError!##NSError!#>)
            }
            
          }
          
        }
        
      }
      
    })
    
    statusView.addStatus("Transaktion wird durchgeführt")
    
    // start
    SCSmartTransactionService.sharedService().startTransaction(currentTransaction.id, type: method.rawValue, completionHandler: { (transactionResult: SCSmartTransaction?, error: NSError?) -> Void in
      
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
      
        if let error = error {
          
          SCLogManager.error(error)
          statusView.addStatus("\(error.localizedDescription)\nFehler: \(error.domain) \nGrund: \(error.localizedFailureReason!)\nSupport-ID: \(error.localizedRecoverySuggestion!)")
          
        } else {
          
          if let result = transactionResult {
            
            // check results
            if result.status == "ok" {
              
              statusView.addStatus("Transaktion erfolgreich durchgeführt")
              
              self.basket = [BasketItem]()
              self.customerUsed = nil
              
            } else if result.status == "failed" {
              
              statusView.addStatus("Transaktion konnte nicht erfolgreich durchgeführt werden")
              
            }
            
            if let receiptLines = result.receiptLines as? [SCSmartReceiptLine] {
              
              // show receiptView
              let receiptView = ReceiptView()
              statusView.addSubview(receiptView)
              
              var constraint: Constraint?
              
              receiptView.snp_makeConstraints(closure: { (make) -> Void in
                make.centerX.equalTo(statusView)
                make.width.equalTo(300)
                make.bottom.equalTo(statusView)
                constraint = make.height.equalTo(0).offset(0).constraint
              })
              
              receiptView.receiptLines = receiptLines
              
              if let constraint = constraint {
              
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
                dispatch_after(delayTime, dispatch_get_main_queue()) {
                  
                  UIView.animateWithDuration(0.4, animations: { () -> Void in
                    constraint.updateOffset(self.view.frame.size.height-100)
                    self.view.layoutIfNeeded()
                  })
                  
                }
                
              }
              
            }
            
          }
        }
        
        self.currentTransaction = SCSmartTransaction()
        
        
      })
      
    })
  }
  
  func CheckTransactionReady() {
    
    let ready = (basket.count > 0)
    
    for button in availableButtons {
      button.enabled = ready
      button.alpha = ready ? 1 : 0.5
    }
    
  }
  
  func didTapAddIdent() {
    showScanCardView()
  }
  
  func didTapAddProduct() {
    
    let addProductView = AddProductView()
    addProductView.alpha = 0
    addProductView.delegate = self
    
    view.addSubview(addProductView)
    addProductView.snp_makeConstraints { (make) -> Void in
      make.edges.equalTo(self.view)
    }
    
    UIView.animateWithDuration(0.4) { () -> Void in
      addProductView.alpha = 1
    }
    
  }
  
  func didTapShowLog() {
    logView.hidden = false
  }
  
  func didTapShowSettings() {
    
    let initView = InitializationView()
    
    if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
      initView.delegate = appDelegate
    }
    
    view.addSubview(initView)
    initView.snp_makeConstraints { (make) -> Void in
      make.edges.equalTo(view)
    }
    
  }
  
  // MARK: - ConnectButtonDelegate
  func didTapConnect() {    
    if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
      appDelegate.connectCashier({ (success: Bool, error: NSError?) -> Void in
      })
    }
  }
  
  func didTapDisconnect() {
    
    SCConnectClient.sharedInstance().disconnect { (success: Bool, error: NSError!) -> Void in
      if (success) {
        NSNotificationCenter.defaultCenter().postNotificationName("clientDidDisconnect", object: nil)
      }
    }
    
  }
  
  func clientDidDisconnect(notification : NSNotification) {
    
    dispatch_async(dispatch_get_main_queue(), { () -> Void in
      self.connectionButton.hostConnected = false
    })
    
  }
  
  func clientDidConnect(notification : NSNotification) {
    
    dispatch_async(dispatch_get_main_queue(), { () -> Void in
      self.connectionButton.hostConnected = true
    })
    
  }
  
  func identRemoveTapped() {

    customerUsed = nil
    updateTransactionIdent { (success, error) -> Void in
      
    }
    
  }
  
  func scanViewReturnCode(code: String) {
    
    self.dismissViewControllerAnimated(true, completion: nil)
   
    let ident = SCSmartIdent()
    ident.type = "card"
    ident.value = code
    
    customerUsed = ident
    updateTransactionIdent { (success, error) -> Void in
      
    }

  }
  
  // MARK: - Notification handlers
  
  func didReceiveStompResult(notification: NSNotification) {
    if let message = notification.userInfo?["message"] as? String {
      logView.addToLog(message)
    }
  }
  
  func didReceiveStompError(notification: NSNotification) {
    if let message = notification.userInfo?["message"] as? String {
      logView.addToLog(message)
    }
  }
  
  // MARK: - Log Management
  
  func logManagerHandleLogging(message: SCLogMessage!) {
    
    
    
    if (message.level.rawValue == LogLevelError.rawValue) {
    
//      dispatch_async(dispatch_get_main_queue(), { () -> Void in
//        let alert:UIAlertView = UIAlertView(title: "Fehler", message: message.message, delegate: nil, cancelButtonTitle: "OK")
//        alert.show()
//      })
      
      var logString = "< ERROR > \n\(message.message)"
      
      if let error = message.error {
        
        logString += "\nDomain: \(error.domain)"
        
        if let reason = error.localizedFailureReason, suggestion = error.localizedRecoverySuggestion {
        
          logString += "\nReason: \(reason)\nsupport id: \(suggestion)"
          
        }
        
      }
      
      logView.addToLog(logString)
      
    } else {
    
      logView.addToLog(message.message)
      
    }
    
  }
  
  // MARK: - TransactionInfoInputViewDelegate
  func didAddTransactionInput(transactionRef: String, merchantRef: String) {
    
    currentTransaction.transactionRef = transactionRef
    currentTransaction.merchantRef = merchantRef
    
  }
  
  // MARK: - AddProductViewDelegate
  
  func didAddProduct(product: SCSmartProduct) {

    let basketItem: BasketItem = BasketItem(product: product)
    basket.append(basketItem)
    calcPrice()
    
  }
  
  // MARK: - ScanCardViewDelegate
  func scanCardFinished(code: String) {
    scanViewReturnCode(code)
    scanCardView.hide()
  }
  
  func handleLongPress(sender: UILongPressGestureRecognizer) {
    
    let p = sender.locationInView(productsCollection)
    
    let indexPath = productsCollection.indexPathForItemAtPoint(p)
    
    if let indexPath = indexPath {
      
      if sender.state == UIGestureRecognizerState.Began {
        
        let subCatKey = Array(Array(productCategories.values)[currentCategory].keys)[indexPath.section]
        let item = Array(productCategories.values)[currentCategory][subCatKey]![indexPath.row]
        
        let detailView = ProductDetailView()
        view.addSubview(detailView)
        
        detailView.snp_makeConstraints(closure: { (make) -> Void in
          make.edges.equalTo(view)
        })
        
        detailView.product = item
        detailView.alpha = 0
        
        UIView.animateWithDuration(0.4, animations: { () -> Void in
          detailView.alpha = 1
        })
        
      }
    }
    
  }
  
}
