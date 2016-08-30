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

/**
 The type of collection
 
 - Product:           The Products within a category
 - ProductCategories: the categories (tabs)
 - Basket:            the basket with its items
 - Checkins:          the checkins nearby
 - Unknown:           unknow
 */
enum CollectionType {
    case Product
    case ProductCategories
    case Basket
    case Checkins
    case Unknown
}

/**
 The Payment Method to use for transaction
 
 - Unset:    the void state
 - Demo:     Demo is just demo
 - Cash:     Customer wants to use cash to pay
 - Auto:     default logic if customer is secucard customer and has a defautl setting in his account
 - Cashless: Card
 - Loyalty:  Localty Card
 - Paypal:   Paypal
 */
enum PayMethod : String {
    case Unset = "unset"
    case Demo = "demo"
    case Cash = "cash"
    case Auto = "auto"
    case Cashless = "cashless"
    case Loyalty = "loyalty"
    case Paypal = "paypal"
}

/// The MainViewController is holding all GUI elements and is processing transaction logic
// TODO: Break into several contollers
class MainViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, BasketProductCellDelegate, ScanViewControllerDelegate, BasketUserCellDelegate, SCLogManagerDelegate, ScanCardViewDelegate, UIGestureRecognizerDelegate, ConnectionButtonDelegate, AddProductViewDelegate, TransactionInfoInputViewDelegate {
    
    // CollectionViews cell idetifiers
    // TODO: convert to string-enum
    
    let productReuseIdentifier = "ProductCell"
    let categoryReuseIdentifier = "CategoryCell"
    let basketProductReuseIdentifier = "BasketProductCell"
    let basketUserReuseIdentifier = "BasketUserCell"
    let checkinReuseIdentifier = "CheckinCell"
    let basketSectionHeaerReuseIdentifier = "HeaderView"
    let productSectionHeaerReuseIdentifier = "ProductsHeaderView"
    
    /// The product categories collection
    var productCategoriesCollection: UICollectionView
    
    /// The layout for the product categories collection
    let categoriesLayout = UICollectionViewFlowLayout()
    
    /// The products colelction
    var productsCollection: UICollectionView
    
    /// The layout for products colelction
    let productsLayout = UICollectionViewFlowLayout()
    
    /// The basket collection
    var basketCollection: UICollectionView
    
    /// The layout for the basket collection
    let basketLayout = UICollectionViewFlowLayout()
    
    /// The checkins collection
    var checkinsCollection: UICollectionView
    
    /// The layout for checkins collection
    let checkinLayout = UICollectionViewFlowLayout()
    
    /// semaphore to check whether card scanning is in progress because the component is firing the event a couple of times
    var cardScanInProgress = false
    
    /// alamofire manager
    var manager: Manager?
    
    /// the categories
    
    var productCategories = [String:[String:[SCSmartProduct]]]()
    
    /// the checkins
    var checkins = [SCSmartCheckin]() {
        didSet {
            checkinsCollection.reloadData()
        }
    }
    
    /// the basket
    var basket = [BasketItem]() {
        didSet {
            
            // update gui
            
            CheckTransactionReady()
            basketCollection.reloadData()
            calcPrice()
            
            // if basket is not empty, update transaction
            
            if basket.count > 0 {
                updateTransactionBasket { (success, error) -> Void in
                    if let error = error {
                        SCLogManager.error(error)
                    }
                }
            }
            
        }
    }
    
    /// the currently used ident
    var customerUsed: SCSmartIdent? {
        didSet {
            
            // update gui
            
            CheckTransactionReady()
            basketCollection.reloadData()
            
        }
    }
    
    /// A view letting the user scan a card
    var scanCardView = ScanCardView()
    
    /// The button showing connection state and letting the user connect or disconnect
    let connectionButton = ConnectionButton()
    
    /// button to show the log
    let showLogButton: PaymentButton
    
    /// button to show the settings
    let settingsButton: PaymentButton
    
    /// auto payment button
    let payAutoButton = PaymentButton(payMethod: PayMethod.Auto, action: #selector(MainViewController.didTapPayButton(_:)))
    
    /// demo payment button
    let payDemoButton = PaymentButton(payMethod: PayMethod.Demo, action: #selector(MainViewController.didTapPayButton(_:)))
    
    /// paypal payment button
    let payPaypalButton = PaymentButton(payMethod: PayMethod.Paypal, action: #selector(MainViewController.didTapPayButton(_:)))
    
    /// localty payment button
    let payLoyaltyButton = PaymentButton(payMethod: PayMethod.Loyalty, action: #selector(MainViewController.didTapPayButton(_:)))
    
    /// cashless payment button
    let payCashlessButton = PaymentButton(payMethod: PayMethod.Cashless, action: #selector(MainViewController.didTapPayButton(_:)))
    
    ///  cash payment button
    let payCashButton = PaymentButton(payMethod: PayMethod.Cash, action: #selector(MainViewController.didTapPayButton(_:)))
    
    /// all buttons available, needed for iterating the buttons
    let availableButtons: [PaymentButton]
    
    /// the view with the log
    let logView = LogView()
    
    /// the label summing up the basket
    let sumLabel = UILabel()
    
    /// the sum of the basket
    var sum:Int = 0 {
        didSet {
            sumLabel.text = sum.toEuro()
        }
    }
    
    /// the button for emptying the basket
    let emptyButton = UIButton(type: UIButtonType.Custom)
    
    /// the button to show the transaction information
    let transactionInfoButton = UIButton(type: UIButtonType.Custom)
    
    ///  the shown category of products
    var currentCategory = 0 {
        didSet {
            self.productsCollection.reloadData()
            self.productCategoriesCollection.reloadData()
        }
    }
    
    /// a json structure to build the categories and products navigation
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
    
    /// the current transaction
    var currentTransaction: SCSmartTransaction?
    
    func abortShopping() {
        self.basket = [BasketItem]()
        self.customerUsed = nil
    }
    
    /**
     initializer
     */
    init() {
        
        // init lists layouts and collections
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
        showLogButton = PaymentButton(icon: "Log", action: #selector(MainViewController.didTapShowLog))
        settingsButton = PaymentButton(icon: "Settings", action: #selector(MainViewController.didTapShowSettings))
        
        availableButtons = [payDemoButton, payPaypalButton, payLoyaltyButton, payCashlessButton, payCashButton]
        
        // call super initialization
        super.init(nibName: nil, bundle: nil)
        
        // initilizing using self
        
        // notification handling
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainViewController.clientDidDisconnect(_:)), name: "clientDidDisconnect", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainViewController.clientDidConnect(_:)), name: "clientDidConnect", object: nil)
        
        // add self as target and delegates
        showLogButton.target = self
        settingsButton.target = self
        SCLogManager.sharedManager().delegate = self
        
        self.productCategoriesCollection.delegate = self
        self.productCategoriesCollection.dataSource = self
        
        self.productsCollection.delegate = self
        self.productsCollection.dataSource = self
        
        // long pressing the product
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(MainViewController.handleLongPress(_:)))
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
        
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     layouting
     */
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.whiteColor()
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
        
        // TOP BAR
        
        let topBar:UIView = UIView()
        topBar.backgroundColor = Constants.darkGreyColor
        view.addSubview(topBar)
        
        topBar.snp_makeConstraints { (make) -> Void in
            make.left.top.width.equalTo(view)
            make.height.equalTo(50)
        }
        
        let topLabel = UILabel()
        topLabel.text = "secuconnect Kasse"
        topLabel.textColor = Constants.textColorBright
        topLabel.font = Constants.headlineFont
        
        topBar.addSubview(topLabel);
        
        topLabel.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(topBar)
            make.centerY.equalTo(topBar).offset(10)
        }
        
        // BOTTOM BAR
        
        let bottomBar = UIView()
        bottomBar.backgroundColor = UIColor.whiteColor()
        view.addSubview(bottomBar);
        
        bottomBar.snp_makeConstraints { (make) -> Void in
            make.left.bottom.width.equalTo(view)
            make.height.equalTo(100)
        }
        
        // TABS FOR PRODUCT CATEGORY
        
        view.addSubview(productCategoriesCollection)
        
        productCategoriesCollection.backgroundColor = UIColor.darkGrayColor()
        
        productCategoriesCollection.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(topBar.snp_bottom)
            make.left.equalTo(view)
            make.width.equalTo(490)
            make.height.equalTo(50)
        }
        
        // COLLECTION VOR PRODUCTS
        
        view.addSubview(productsCollection)
        
        productsCollection.backgroundColor = UIColor.whiteColor()
        
        productsCollection.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(view)
            make.bottom.equalTo(bottomBar.snp_top)
            make.top.equalTo(productCategoriesCollection.snp_bottom)
            make.width.equalTo(productCategoriesCollection)
        }
        
        // CHECKINS
        
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
        
        // BASKET
        
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
        
        // SUM FIELD
        
        let sumView = UIView()
        sumView.backgroundColor = Constants.brightGreyColor
        
        view.addSubview(sumView)
        sumView.snp_makeConstraints { (make) -> Void in
            make.left.width.equalTo(basketCollection)
            make.bottom.equalTo(bottomBar.snp_top)
            make.height.equalTo(80)
        }
        
        // SUM LABEL
        sumLabel.font = Constants.sumFont
        sumView.addSubview(sumLabel)
        
        sumLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(20)
            make.top.height.equalTo(sumView)
            make.width.equalTo(100)
        }
        
        emptyButton.setImage(UIImage(named: "Trash"), forState: UIControlState.Normal)
        emptyButton.addTarget(self, action: #selector(MainViewController.didTapEmptyButton), forControlEvents: UIControlEvents.TouchUpInside)
        emptyButton.backgroundColor = Constants.warningColor
        sumView.addSubview(emptyButton)
        
        emptyButton.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(-10)
            make.centerY.equalTo(sumView)
            make.width.height.equalTo(50)
        }
        
        transactionInfoButton.setTitle("i", forState: UIControlState.Normal)
        transactionInfoButton.addTarget(self, action: #selector(MainViewController.didTapTransactionInformation), forControlEvents: UIControlEvents.TouchUpInside)
        transactionInfoButton.backgroundColor = Constants.tintColor
        sumView.addSubview(transactionInfoButton)
        
        transactionInfoButton.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(emptyButton.snp_left).offset(-10)
            make.centerY.equalTo(sumView)
            make.width.height.equalTo(50)
        }
        
        let topBorder = UIView()
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
        
        // version strings
        
        let versionLabel = UILabel()
        versionLabel.font = UIFont.systemFontOfSize(12)
        let infoStr = "CFBundleShortVersionString"
        versionLabel.text = "APP Version: \(NSBundle.mainBundle().objectForInfoDictionaryKey(infoStr)!) - SDK: \(SCConnectClient.sharedInstance().myApiVersion())"
        
        bottomBar.addSubview(versionLabel)
        
        versionLabel.snp_makeConstraints { (make) -> Void in
            make.bottom.right.equalTo(bottomBar).offset(-3)
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
    
    /**
     retrieve identifiers for a specific collection
     
     - parameter collection: the collection
     
     - returns: the identifier (CollectionType)
     */
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
    
    /**
     calculate the current price of the basket
     */
    func calcPrice() {
        sum = 0
        for bi:BasketItem in basket {
            if (bi.type == BasketItemType.Product) {
                let newVal = sum + Int(roundf((Float(bi.price) * bi.discount * Float(bi.amount))))
                sum = newVal
            }
        }
    }
    
    /**
     Empty the basket (by tapping the trash icon)
     */
    func didTapEmptyButton() {
        
        sum = 0
        self.currentTransaction = nil
        basket = [BasketItem]()
        
    }
    
    /**
     show transaction information (by tapping i icon)
     */
    func didTapTransactionInformation() {
        
        guard let currentTransaction = currentTransaction else {
            SCLogManager.errorWithDescription("Transaction Info: There is no current transaction")
            return
        }
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            
            let infoView = TransactionInfoInputView(transactionRef: currentTransaction.transactionRef, merchantRef: currentTransaction.merchantRef, transactionId:currentTransaction.id)
            infoView.delegate = self
            infoView.alpha = 0
            
            self.view.addSubview(infoView)
            infoView.snp_makeConstraints { (make) -> Void in
                make.edges.equalTo(self.view)
            }
            
            UIView.animateWithDuration(0.4) { () -> Void in
                infoView.alpha = 1
            }
            
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
                
                // check if in basket already
                for itemInBasket in basket {
                    if itemInBasket.product.id == basketItem.product.id {
                        
                        itemInBasket.amount += 1
                        basketItemChanged(itemInBasket)
                        
                        return
                    }
                }
                
                basket.append(basketItem)
                
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
                    button.addTarget(self, action: #selector(MainViewController.didTapAddProduct), forControlEvents: UIControlEvents.TouchUpInside)
                    
                } else {
                    
                    headerView.label.text = "Idents"
                    button.addTarget(self, action: #selector(MainViewController.didTapAddIdent), forControlEvents: UIControlEvents.TouchUpInside)
                    
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
    
    /**
     removes a basket item from the basket
     
     - parameter basketItem: the item
     */
    func removeBasketItem(basketItem: BasketItem) {
        
        for (index, basketItemTest) in basket.enumerate() {
            if (basketItem == basketItemTest) {
                basket.removeAtIndex(index)
                return
            }
        }
        
    }
    
    /**
     basketitem tells collection to change its layout (expand/collapse)
     
     - parameter basketItem: the item
     */
    func basketItemLayoutChanged(basketItem: BasketItem) {
        basketCollection.collectionViewLayout.invalidateLayout()
    }
    
    /**
     the delegate method of the basket item telling the collection that it changed
     
     - parameter basketItem: the item
     */
    func basketItemChanged(basketItem: BasketItem) {
        calcPrice()
        basketCollection.reloadData()
        updateTransactionBasket { (success, error) -> Void in
            
        }
    }
    
    // MARK: - Payment actions
    
    // payment actions
    
    /**
     did tap a payment button
     
     - parameter button: the button used
     */
    internal func didTapPayButton(button: PaymentButton) {
        sendTransaction(button.payMethod)
    }
    
    /**
     show the view to scan a card
     */
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
    
    /**
     tell the app to update the transaction's basket
     
     - parameter handler: completion handler
     */
    func updateTransactionBasket(handler: (success: Bool,error: SecuError?) -> Void) {
        
        checkTransaction { (success, error) -> Void in
            
            if let error = error {
                SCLogManager.errorWithDescription("Update Transaction Basket: There is no current transaction")
                SCLogManager.error(error)
            } else if success {
                
                // create a basket
                let basket = SCSmartBasket()
                
                var productList = [AnyObject]()
                for basketItem:BasketItem in self.basket {
                    if let productData = basketItem.product {
                        productData.priceOne = basketItem.price
                        productList.append(productData)
                    }
                }
                
                basket.products = productList
                
                self.currentTransaction!.basket = basket
                
                // create a basket info
                
                let basketInfo = SCSmartBasketInfo()
                basketInfo.sum = Int(self.sum)
                basketInfo.currency = "EUR"
                self.currentTransaction!.basketInfo = basketInfo
                
                self.updateTransaction({ (success, error) -> Void in
                    
                    if let error = error {
                        SCLogManager.error(error)
                    }
                    
                    handler(success: success, error: error)
                    
                })
                
            } else {
                
                SCLogManager.errorWithDescription("Update Transaction Basket: something went wrong")
                
            }
            
        }
        
    }
    
    /**
     <#Description#>
     
     - parameter handler: <#handler description#>
     */
    func updateTransactionIdent(handler: (success: Bool,error: SecuError?) -> Void) {
        
        checkTransaction { (success, error) -> Void in
            
            if let error = error {
                
                SCLogManager.errorWithDescription("Update Transaction Ident: There is no current transaction")
                SCLogManager.error(error)
                handler(success: false, error: nil)
                
            } else if success {
                
                // create the ident
                if let ident = self.customerUsed {
                    self.currentTransaction!.idents = [ident]
                    self.updateTransaction({ (success, error) -> Void in
                        
                        if let error = error {
                            SCLogManager.error(error)
                        }
                        
                        if let resolvedIdent = self.currentTransaction!.idents[0] as? SCSmartIdent {
                            
                            if !resolvedIdent.valid {
                                
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                    
                                    SCLogManager.errorWithDescription("Identifizierung fehlgeschlagen")
                                    
                                })
                                
                                self.customerUsed = nil
                            } else {
                                self.customerUsed = resolvedIdent
                            }
                            
                            handler(success: success, error: error)
                            
                        }
                        
                    })
                } else {
                    
                    handler(success: false, error: nil)
                    
                }
                
            } else {
                
                SCLogManager.errorWithDescription("Update Transaction Ident: somthing went wrong")
                handler(success: false, error: nil)
                
            }
        }
        
    }
    
    func checkTransaction(handler: (success: Bool,error: SecuError?) -> Void) {
        
        if currentTransaction == nil {
            createTransaction(handler)
            return
        }
        
        handler(success: true, error: nil)
        
    }
    
    func createTransaction(handler: (success: Bool,error: SecuError?) -> Void) {
        
        currentTransaction = SCSmartTransaction()
        
        currentTransaction!.merchantRef = Constants.merchantRef
        currentTransaction!.transactionRef = "\(Constants.merchantRef)_\(NSDate().timeIntervalSince1970)"
        
        SCSmartTransactionService.sharedService().createTransaction(currentTransaction!, completionHandler: { (createdTransaction: SCSmartTransaction?, error: SecuError?) -> Void in
            
            if let error = error {
                
                handler(success: false, error: error)
                return
                
            } else {
                
                if let createdTransaction = createdTransaction {
                    self.currentTransaction = createdTransaction
                    handler(success: true, error: nil)
                }
                
            }
            
        })
        
    }
    
    func updateTransaction(handler: (success: Bool,error: SecuError?) -> Void) {
        
        checkTransaction { (success, error) -> Void in
            
            SCSmartTransactionService.sharedService().updateTransaction(self.currentTransaction, completionHandler: { (updatedTransaction: SCSmartTransaction?, error: SecuError?) -> Void in
                
                if let updatedTransaction = updatedTransaction {
                    self.currentTransaction = updatedTransaction
                }
                
                handler(success: updatedTransaction != nil, error: error)
                
            })
            
        }
        
    }
    
    func sendTransaction(method: PayMethod) {
        
        checkTransaction { (success, error) -> Void in
            
            if let error = error {
                
                SCLogManager.errorWithDescription("Update Transaction Ident: There is no current transaction")
                SCLogManager.error(error)
                
            } else if success {
                
                let statusView = TransactionStatusView();
                self.view.addSubview(statusView)
                
                statusView.snp_makeConstraints { (make) -> Void in
                    make.edges.equalTo(self.view)
                }
                
                statusView.addStatus("Transaktion wird durchgeführt")
                
                SCSmartTransactionService.sharedService().addEventHandler({ (event: SCGeneralEvent?) -> Void in
                    
                    if let event = event {
                        
                        if event.target == SCGeneralNotification.object().lowercaseString {
                            
                            // TODO: what to do if data is array ???
                            if let _ = event.data as? [AnyObject] {
                                
                            } else if let eventDataDict = event.data as? [NSObject:AnyObject] {
                                
                                do {
                                    let notification = try MTLJSONAdapter.modelOfClass(SCGeneralNotification.self, fromJSONDictionary: eventDataDict) as? SCGeneralNotification
                                    statusView.addStatus(notification!.text)
                                } catch let error as NSError {
                                    SCLogManager.error(SecuError.withError(error))
                                }
                                
                            }
                            
                        }
                        
                    }
                    
                })
                
                // start
                SCSmartTransactionService.sharedService().startTransaction(self.currentTransaction!.id, type: method.rawValue, completionHandler: { (transactionResult: SCSmartTransaction?, error: SecuError?) -> Void in
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        if let error = error {
                            
                            SCLogManager.error(error)
                            statusView.addStatus("Transaktion nicht erfolgreich:\n\(error.localizedDescription)")
                            statusView.showLogButton(true)
                            self.currentTransaction = nil
                            
                            // recreate transaction
                            self.updateTransaction({ (success, error) in
                                
                                self.updateTransactionBasket({ (success, error) in
                                    
                                    self.updateTransactionIdent({ (success, error) in
                                        
                                        print("recreated transaction after failure")
                                        print(self.currentTransaction)
                                    })
                                    
                                })
                                
                            })
                            
                        } else {
                            
                            if let result = transactionResult {
                                
                                // check results
                                if result.status == "ok" {
                                    
                                    statusView.addStatus("Transaktion erfolgreich durchgeführt")
                                    
                                } else if result.status == "failed" {
                                    
                                    statusView.addStatus("Transaktion konnte nicht erfolgreich durchgeführt werden")
                                    statusView.showLogButton(true)
                                    
                                }
                                
                                // receiptView to show
                                let receiptView = ReceiptView(title: "Kundenbeleg", print: false)
                                
                                var receiptCenterX: Constraint!
                                var merchReceiptCenterX: Constraint!
                                var receiptHeight: Constraint!
                                var merchReceiptHeight: Constraint!
                                
                                if let receiptLines = result.receiptLines as? [SCSmartReceiptLine] {
                                    
                                    statusView.addSubview(receiptView)
                                    
                                    receiptView.snp_makeConstraints(closure: { (make) -> Void in
                                        receiptCenterX = make.centerX.equalTo(statusView).offset(0).constraint
                                        make.width.equalTo(300)
                                        make.bottom.equalTo(statusView)
                                        receiptHeight = make.height.equalTo(0).offset(0).constraint
                                    })
                                    
                                    receiptView.receiptLines = receiptLines
                                    
                                    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
                                    dispatch_after(delayTime, dispatch_get_main_queue()) {
                                        
                                        UIView.animateWithDuration(0.4, animations: { () -> Void in
                                            receiptHeight.updateOffset(self.view.frame.size.height-100)
                                            self.view.layoutIfNeeded()
                                        })
                                        
                                    }
                                    
                                }
                                
                                // merch receiptView to show
                                if let receiptLinesMerchant = result.receiptLinesMerchant as? [SCSmartReceiptLine] {
                                    
                                    // show receiptView
                                    let receiptViewMerchant = ReceiptView(title: "Händlerbeleg", print: result.receiptLinesMerchantPrint)
                                    statusView.addSubview(receiptViewMerchant)
                                    
                                    receiptViewMerchant.snp_makeConstraints(closure: { (make) -> Void in
                                        merchReceiptCenterX = make.centerX.equalTo(statusView).offset(0).constraint
                                        make.width.equalTo(300)
                                        make.bottom.equalTo(statusView)
                                        merchReceiptHeight = make.height.equalTo(0).offset(0).constraint
                                    })
                                    
                                    receiptViewMerchant.receiptLines = receiptLinesMerchant
                                    
                                    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
                                    dispatch_after(delayTime, dispatch_get_main_queue()) {
                                        
                                        UIView.animateWithDuration(0.4, animations: { () -> Void in
                                            merchReceiptHeight.updateOffset(self.view.frame.size.height-100)
                                            if let receiptCenterX = receiptCenterX {
                                                receiptCenterX.updateOffset(-200)
                                                merchReceiptCenterX.updateOffset(200)
                                            }
                                            self.view.layoutIfNeeded()
                                        })
                                        
                                    }
                                    
                                }
                                
                            }
                            
                            self.didTapEmptyButton()
                            
                        }
                        
                        
                    })
                    
                })
                
            } else {
                SCLogManager.errorWithDescription("Update Transaction Ident: Something went wrong")
                self.currentTransaction = nil
            }
        }
        
        
    }
    
    func CheckTransactionReady() {
        
        let ready = basket.count > 0 && SCConnectClient.sharedInstance().connected
        
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
        
        if !cardScanInProgress {
            
            cardScanInProgress = true
            
            self.dismissViewControllerAnimated(true, completion: nil)
            
            let ident = SCSmartIdent()
            ident.type = "card"
            ident.value = code
            
            customerUsed = ident
            updateTransactionIdent { (success, error) -> Void in
                self.cardScanInProgress = false
            }
            
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
            
            var logString = "< ERROR > \n\(message.message)"
            
            logString += "Original Error: \(message.error.localizedDescription)\n"
            
            if let status = message.error.scStatus {
                logString += "Status: \(status)\n"
            }
            
            if let code = message.error.scCode {
                logString += "Code: \(code)\n"
            }
            
            if let type = message.error.scError {
                logString += "Type: \(type)\n"
            }
            
            if let erroruser = message.error.scErrorUser {
                logString += "Error: \(erroruser)\n"
            }
            
            if let details = message.error.scErrorDetails {
                logString += "Details: \(details)\n"
            }
            
            if let supportId = message.error.scSupportId {
                logString += "SupportId: \(supportId)\n"
            }
            
            logView.addToLog(logString)
            
        } else {
            
            print(message.message)
            logView.addToLog(message.message)
            
        }
        
    }
    
    // MARK: - TransactionInfoInputViewDelegate
    func didAddTransactionInput(transactionRef: String, merchantRef: String) {
        
        guard let currentTransaction = currentTransaction else {
            SCLogManager.errorWithDescription("Add TRansaction Input: There is no current transaction")
            return
        }
        
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
