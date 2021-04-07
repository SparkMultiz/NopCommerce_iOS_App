//
//  CheckOutVC.swift
//  NopCommerce
//
//  Created by Chirag Patel on 11/03/20.
//  Copyright © 2020 Chirag Patel. All rights reserved.
//

import UIKit

class CheckOutStages {
    
    var name: String = ""
    var stage: EnumCheckOutStages = .billingAddress
    var isSelected = false
    var constant: CGFloat = 0
    var arrStages: [CheckOutStages] = []
    
    func setCheckOutStages() {
        let f1 = CheckOutStages()
        f1.name = "Billing address"
        f1.stage = .billingAddress
        arrStages.append(f1)
        
        let f2 = CheckOutStages()
        f2.name = "Shipping address"
        f2.stage = .shippingAddress
        arrStages.append(f2)
        
        let f3 = CheckOutStages()
        f3.name = "Shipping method"
        f3.stage = .shippingMethod
        arrStages.append(f3)
        
        let f4 = CheckOutStages()
        f4.name = "Payment method"
        f4.stage = .paymentMethod
        arrStages.append(f4)
        
        let f5 = CheckOutStages()
        f5.name = "Confirm order"
        f5.stage = .confirmOrder
        arrStages.append(f5)
    }
}

enum EnumCheckOutStages {
    case billingAddress
    case shippingAddress
    case shippingMethod
    case paymentMethod
    case confirmOrder
    
    init(currPage: Int) {
        if currPage == 0 {
            self = .billingAddress
        } else if currPage == 1 {
            self = .shippingAddress
        } else if currPage == 2 {
            self = .shippingMethod
        } else if currPage == 3 {
            self = .paymentMethod
        } else {
            self = .confirmOrder
        }
    }
}

class CheckOutVC: ParentViewController {
    
    @IBOutlet weak var btnStackHeight: NSLayoutConstraint!
    @IBOutlet weak var btnStackView: UIStackView!
    @IBOutlet var btnStack: [UIButton]!
    
    var arrPaymentMethod: [PaymentMethod]!
    var arrShippingMethod: [ShippingMethod]!
    var arrCountry: [Country]!
    var arrProvince: [Province]!
    var arrAddress: [Address]!
    
    var objFinalCheckOut: ConfirmOrder!
    var objConfirmOrder: CheckOutOrder!
    var objAddressData: NewAddress!
    
    var toolBar: ToolBarView!
    var dropDown = DropDown()
    var checkOut = CheckOutStages()
    
    var isDeliverShippingSame = true
    var isTermsSelected = false
        
    var selectedAddress: Address {
        return arrAddress.filter{$0.isSelected}.first ?? arrAddress[0]
    }
    
    var selectedMethod: ShippingMethod {
        return arrShippingMethod.filter{$0.isSelected}.first ?? arrShippingMethod[0]
    }
    
    var selectedPayment: PaymentMethod {
        return arrPaymentMethod.filter{$0.isSelected}.first ?? arrPaymentMethod[0]
    }
        
    var payPalConfig = PayPalConfiguration()

    
    var environment:String = PayPalEnvironmentSandbox {
        willSet(newEnvironment) {
            if (newEnvironment != environment) {
                PayPalMobile.preconnect(withEnvironment: newEnvironment)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        getAddress()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        PayPalMobile.preconnect(withEnvironment: environment)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "successSegue" {
            let destVC = segue.destination as! OrderSuccessVC
            if let objOrder = objFinalCheckOut.orderDetail {
                destVC.strOrderId = objOrder.orderId
            }
        }
    }
}

extension CheckOutVC {
    
    func payPalInitializationMethods() {
        payPalConfig.acceptCreditCards = true
        payPalConfig.payPalShippingAddressOption = .payPal;
        payPalConfig.languageOrLocale = Locale.preferredLanguages[0]
        payPalConfig.merchantPrivacyPolicyURL = URL(string: "https://www.paypal.com/webapps/mpp/ua/privacy-full")
        payPalConfig.merchantUserAgreementURL = URL(string: "https://www.paypal.com/webapps/mpp/ua/useragreement-full")
    }
    
    func configureDropDown(sender: UIButton) {
        dropDown.anchorView = sender
        dropDown.textFont = UIFont.systemFont(ofSize: 15.widthRatio)
        dropDown.bottomOffset = CGPoint(x: 0, y: sender.bounds.height)
        dropDown.direction = .bottom
        dropDown.width = sender.frame.size.width
        dropDown.cellHeight = 50.widthRatio
        dropDown.backgroundColor = #colorLiteral(red: 0.9725490196, green: 0.9725490196, blue: 0.9725490196, alpha: 1)
        dropDown.textColor = UIColor.black
        dropDown.selectionBackgroundColor = UIColor.clear
    }
    
    func prepareUI() {
        checkOut.setCheckOutStages()
        prepareBtnUI()
        prepareToolbar()
        payPalInitializationMethods()
    }
    
    func prepareFieldAddress() {
        let contIdx = objAddressData.arrAddressField.firstIndex{$0.title == "Country"}
        let stateIdx = objAddressData.arrAddressField.firstIndex{$0.title == "State/Province"}
        objAddressData.arrAddressField[contIdx!].text = arrCountry[0].id
        objAddressData.arrAddressField[stateIdx!].text = arrProvince[0].id
    }
    
    func prepareBtnUI() {
        if _bottomAreaSpacing.isZero {
            btnStackHeight.constant = 50.widthRatio
        } else {
            btnStackHeight.constant = 30.widthRatio + _bottomAreaSpacing
        }
        if checkOut.stage == .billingAddress {
            btnStackView.subviews.first?.isHidden = true
            btnStack.last?.setTitle("DELIVER HERE", for: .normal)
        } else {
            btnStackView.subviews.first?.isHidden = false
            btnStack.first?.setTitle("BACK", for: .normal)
            btnStack.last?.setTitle("CONTINUE", for: .normal)
        }
        collectionView.reloadData()
    }
    
    func preparePayPalPayment() {
        var itemObject = [PayPalItem]()
        for item in objConfirmOrder.arrItems {
            let currencyString = item.unitPrice
            let amount = currencyString.removeFormatAmount()
            let item = PayPalItem(name: item.proName, withQuantity: UInt(item.quantity), withPrice: NSDecimalNumber(value: amount), withCurrency: "USD", withSku: item.sku)
            itemObject.append(item)
        }
        
        let subtotal = PayPalItem.totalPrice(forItems: itemObject)
        let shipping = NSDecimalNumber(value: 0.0)
        let tax = NSDecimalNumber(value: objConfirmOrder.orderDetail!.totalAmountOrderTax)
                
        let paymentDetails = PayPalPaymentDetails(subtotal: subtotal, withShipping: shipping, withTax: tax)
        let total = subtotal.adding(shipping).adding(tax)

        let payment = PayPalPayment(amount: total, currencyCode: "USD", shortDescription: "NopCommerce", intent: .authorize)
        payment.items = itemObject
        payment.paymentDetails = paymentDetails

        if (payment.processable) {
            let paymentViewController = PayPalPaymentViewController(payment: payment, configuration: payPalConfig, delegate: self)
            present(paymentViewController!, animated: true, completion: nil)
        }
        else {
            JTValidationToast.show(message: "Payment not processalbe: \(payment)")
        }
    }
    
    func prepareToolbar() {
        toolBar = ToolBarView.instantiateViewFromNib()
        toolBar.handleTappedAction { [weak self] (tapped, toolbar) in
            self?.view.endEditing(true)
        }
    }
    
    func navigateToNext(isAddressSame: Bool = false) {
        let idx = collectionView.currentPage + (isAddressSame ? 2 : 1)
        let scrollPage = collectionView.frame.size.width * CGFloat(idx)
        collectionView.scrollRectToVisible(CGRect(x: scrollPage, y: 0, width: _screenSize.width, height: collectionView.frame.size.height), animated: true)
       // collectionView.scrollToItem(at: IndexPath(item: idx, section: 0), at: .centeredHorizontally, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.setIndexSelected(ind: idx)
        }
    }
    
    func navigateToPrev() {
        let idx = collectionView.currentPage - 1
        let scrollPage = collectionView.frame.size.width * CGFloat(idx)
        collectionView.scrollRectToVisible(CGRect(x: scrollPage, y: 0, width: _screenSize.width, height: collectionView.frame.size.height), animated: true)

       // collectionView.scrollToItem(at: IndexPath(item: idx, section: 0), at: .centeredHorizontally, animated: true)
    }
    
    func navigateToThankYou() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "successSegue", sender: nil)
        }
    }
    
    func reloadTable() {
        if let cell = collectionView.cellForItem(at: IndexPath(item: collectionView.currentPage, section: 0)) as? CheckOutCollCell {
            cell.tblView.reloadData()
        }
    }
}

extension CheckOutVC: PayPalPaymentDelegate {
   
    func payPalPaymentDidCancel(_ paymentViewController: PayPalPaymentViewController) {
        JTValidationToast.show(message: "PayPal Payment Cancelled")
        paymentViewController.dismiss(animated: true, completion: nil)
    }
    
    func payPalPaymentViewController(_ paymentViewController: PayPalPaymentViewController, didComplete completedPayment: PayPalPayment) {
        paymentViewController.dismiss(animated: true, completion: nil)
        if let cnfrmDict = completedPayment.confirmation["response"] as? NSDictionary {
            let id = cnfrmDict.getStringValue(key: "id")
            let status = cnfrmDict.getStringValue(key: "state")
            let intent = cnfrmDict.getStringValue(key: "intent")
            if status.isEqual(str: "approved") {
                 kprint(items: "Transcation success with id \(id)")
                self.getPaymentConfirmation(transactionId: id, intent: intent, state: status)
            } else {
                JTValidationToast.show(message: "PayPal Payment Failed")
            }
        }
    }
}

extension CheckOutVC {
    
    @IBAction func btnDropDownTapped(_ sender: UIButton) {
        configureDropDown(sender: sender)
        dropDown.dataSource.removeAll()
        if sender.tag == 4 {
            dropDown.dataSource = self.arrCountry.map{$0.name}
            self.arrCountry.forEach{$0.isSelected = false}
            dropDown.selectionAction = { [weak self] (index: Int, item: String) in
                guard let weakself = self else {return}
                weakself.arrCountry[index].isSelected = true
                let contId = weakself.arrCountry[index].id
                weakself.objAddressData.arrAddressField[sender.tag].text = contId
                weakself.reloadTable()
                weakself.getProvinceList(contId: contId)
            }
        } else {
            dropDown.dataSource = self.arrProvince.map{$0.name}
            self.arrProvince.forEach{$0.isSelected = false}
            dropDown.selectionAction = { [weak self] (index: Int, item: String) in
                guard let weakself = self else {return}
                weakself.arrProvince[index].isSelected = true
                let stateId = weakself.arrProvince[index].id
                weakself.objAddressData.arrAddressField[sender.tag].text = stateId
                weakself.reloadTable()
            }
        }
        dropDown.show()
    }
        
    @IBAction func btnStackTapped(_ sender: UIButton) {
        if sender.tag == 1 {
            switch checkOut.stage {
            case .billingAddress, .shippingAddress:
                guard let cell = collectionView.cellForItem(at: IndexPath(item: collectionView.currentPage, section: 0)) as? CheckOutCollCell else {return}
                if cell.addressType == .addAddress {
                    let validate = objAddressData.validatetData()
                    if validate.isValid {
                        self.addAddress()
                    } else {
                        JTValidationToast.show(message: validate.error)
                    }
                } else {
                    if self.isDeliverShippingSame {
                        self.selectBillingAddress(with: selectedAddress.id) { (completion) in
                            self.selectShippingAddress(with: self.selectedAddress.id) { (completion) in
                                self.navigateToNext(isAddressSame: true)
                            }
                        }
                    } else {
                        if checkOut.stage == .billingAddress {
                            self.selectBillingAddress(with: self.selectedAddress.id) { (completion) in
                                self.navigateToNext()
                            }
                        } else {
                            self.selectShippingAddress(with: self.selectedAddress.id) { (completion) in
                                self.navigateToNext()
                            }
                        }
                    }
                }
            case .shippingMethod:
                self.selectShippingMethod { (completion) in
                    self.navigateToNext()
                }
            case .paymentMethod:
                self.selectPaymentMethod { (success) in
                    if success {
                        self.navigateToNext()
                    }
                }
            case .confirmOrder:
                self.getConfirmOrder { (completion) in
                    self.preparePayPalPayment()
                }
            }
        } else {
            self.navigateToPrev()
        }
    }
}

extension CheckOutVC: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: CheckOutCollCell
        cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collCell", for: indexPath) as! CheckOutCollCell
        cell.parent = self
        cell.tblView.reloadData()
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == collectionView {
            let currPage = scrollView.currentPage
            self.checkOut.stage = EnumCheckOutStages(currPage: currPage)
            self.prepareBtnUI()
        }
    }
    
    func setIndexSelected(ind: Int) {
        for(idx,stage) in self.checkOut.arrStages.enumerated() {
            if ind > idx {
                stage.isSelected = true
            } else {
                stage.isSelected = false
            }
        }
        if let collCell = collectionView.cellForItem(at: IndexPath(row: ind, section: 0)) as? CheckOutCollCell {
            if let tblCell = collCell.tblView.cellForRow(at: IndexPath(row: 0, section: 0)) as? CheckOutTableCell {
                tblCell.collView.reloadData()
                tblCell.collView.scrollToItem(at: IndexPath(row: collectionView.currentPage, section: 0), at: .centeredHorizontally, animated: true)
            }
        }
    }
}

extension CheckOutVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: _screenSize.width, height: collectionView.frame.size.height)
    }
}

extension CheckOutVC {
    
    func getAddress() {
        showHud()
        let param : [String: Any] = ["ApiSecretKey":secretKey,"CustomerGUID": _user.guid, "LanguageId": languageId,"StoreId": storeId]
        KPWebCall.call.getBillingAddress(param: param) { [weak self] (json, statusCode) in
            guard let weakself = self else {return}
            weakself.hideHud()
            weakself.arrAddress = []
            if statusCode == 200, let dict = json as? NSDictionary, let status = dict["Status"] as? Bool, status {
                if let jsonData = dict["Data"] as? NSDictionary {
                    if let arrExistingAddresses = jsonData["ExistingAddresses"] as? [NSDictionary] {
                        for existingDict in arrExistingAddresses {
                            let objAddress = Address(dict: existingDict)
                            weakself.arrAddress.append(objAddress)
                        }
                    }
                    if !weakself.arrAddress.isEmpty {
                        weakself.arrAddress[0].isSelected = true
                    }
                    if let objNewAddress = jsonData["NewAddress"] as? NSDictionary {
                        weakself.objAddressData = NewAddress(dict: objNewAddress)
                        weakself.prepareFieldAddress()
                    }
                }
                weakself.collectionView.reloadData()
            } else {
                weakself.hideHud()
                weakself.showError(data: json, view: weakself.view)
            }
        }
    }
    
    func selectBillingAddress(with id: String, completion: @escaping(Bool) -> ()) {
        showHud()
        let param : [String: Any] = ["ApiSecretKey":secretKey,"CustomerGUID": _user.guid,"StoreId": storeId, "CurrencyId": currencyId, "AddressId": id]
        let relPath = "SelectBillingAddress"//self.checkOut.stage == .billingAddress ? "SelectBillingAddress" : "SelectShippingAddress"
        KPWebCall.call.selectAddress(relPath: relPath, param: param) { [weak self] (json, statusCode) in
            guard let weakself = self else {return}
            weakself.arrShippingMethod = []
            weakself.hideHud()
            if statusCode == 200, let dict = json as? NSDictionary, let status = dict["Status"] as? Bool, status {
                if let jsonData = dict["Data"] as? NSDictionary, let arrMethodsDict =  jsonData["ShippingMethods"] as? [NSDictionary] {
                    for shippingDict in arrMethodsDict {
                        weakself.arrShippingMethod.append(ShippingMethod(dict: shippingDict))
                    }
                }
                completion(true)
            } else {
                weakself.showError(data: json, view: weakself.view)
            }
        }
    }
    
    func selectShippingAddress(with id: String, completion: @escaping(Bool) -> ()) {
        showHud()
        let param : [String: Any] = ["ApiSecretKey":secretKey,"CustomerGUID": _user.guid,"StoreId": storeId, "CurrencyId": currencyId, "AddressId": id]
        let relPath = "SelectShippingAddress"//self.checkOut.stage == .billingAddress ? "SelectBillingAddress" : "SelectShippingAddress"
        KPWebCall.call.selectAddress(relPath: relPath, param: param) { [weak self] (json, statusCode) in
            guard let weakself = self else {return}
            weakself.arrShippingMethod = []
            weakself.hideHud()
            if statusCode == 200, let dict = json as? NSDictionary, let status = dict["Status"] as? Bool, status {
                if let jsonData = dict["Data"] as? NSDictionary, let arrMethodsDict =  jsonData["ShippingMethods"] as? [NSDictionary] {
                    for shippingDict in arrMethodsDict {
                        weakself.arrShippingMethod.append(ShippingMethod(dict: shippingDict))
                    }
                }
                completion(true)
            } else {
                weakself.showError(data: json, view: weakself.view)
            }
        }
    }
    
    func selectShippingMethod(completion: @escaping(Bool) -> ()) {
        showHud()
        let param : [String: Any] = ["ApiSecretKey":secretKey,"CustomerGUID": _user.guid, "LanguageId": languageId,"StoreId": storeId, "CurrencyId": currencyId, "Shippingoption": selectedMethod.methodSelected]
        KPWebCall.call.selectShippingMethod(param: param) { [weak self] (json, statusCode) in
            guard let weakself = self else {return}
            weakself.arrPaymentMethod = []
            weakself.hideHud()
            if statusCode == 200, let dict = json as? NSDictionary, let status = dict["Status"] as? Bool, status {
                if let jsonData = dict["Data"] as? NSDictionary, let arrMethod = jsonData["PaymentMethods"] as? [NSDictionary] {
                    for paymentDict in arrMethod {
                        weakself.arrPaymentMethod.append(PaymentMethod(dict: paymentDict))
                    }
                }
                completion(true)
            } else {
                weakself.showError(data: json, view: weakself.view)
            }
        }
    }
    
    func selectPaymentMethod(completion: @escaping(Bool) -> ()) {
        showHud()
        let param : [String: Any] = ["ApiSecretKey":secretKey,"CustomerGUID": _user.guid,"StoreId": storeId, "Paymentmethod": selectedPayment.systemName, "UseRewardPoints": true]
        KPWebCall.call.selectPaymentMethod(param: param) { [weak self] (json, statusCode) in
            guard let weakself = self else {return}
            weakself.hideHud()
            if statusCode == 200, let dict = json as? NSDictionary, let status = dict["Status"] as? Bool, status {
                weakself.getOrderSummary()
                completion(true)
            } else {
                completion(false)
                weakself.showError(data: json, view: weakself.view)
            }
        }
    }
    
    func addAddress() {
        showHud()
        let relPath = self.checkOut.stage == .billingAddress ? "AddNewBillingAddress" : "AddNewShippingAddress"
        KPWebCall.call.addBillingAddress(relPath: relPath, param: objAddressData.paramDict()) { [weak self] (json, statusCode) in
            guard let weakself = self else {return}
            weakself.hideHud()
            if statusCode == 200, let dict = json as? NSDictionary, let status = dict["Status"] as? Bool, status {
                if let jsonData = dict["Data"] as? NSDictionary, let arrExistingAddresses = jsonData["ExistingAddresses"] as? [NSDictionary], arrExistingAddresses.count > 0 {
                    weakself.arrAddress = []
                    for existingDict in arrExistingAddresses {
                        let objAddress = Address(dict: existingDict)
                        weakself.arrAddress.append(objAddress)
                    }
                }
                weakself.collectionView.reloadData()
                weakself.showSuccessMsg(data: dict, view: weakself.view)
            } else {
                weakself.showError(data: json, view: weakself.view)
            }
        }
    }
    
    func getPaymentConfirmation(transactionId: String, intent: String, state: String) {
        showHud()
        
        let parmOrder:[String:Any] = ["OrderId":objFinalCheckOut.orderDetail!.orderId,
                                      "OrderGuid": objFinalCheckOut.orderDetail!.orderGuid,
                                      "OrderTotal":objFinalCheckOut.orderTotal!.orderTotal]
        
        let parmPayment: [String:Any] = ["PaymentMethodSystemName":objFinalCheckOut.payMethod!.systemName,
                                          "CreditCardType":"",
                                          "CreditCardName":"",
                                          "CreditCardNumber":"",
                                          "CreditCardCvv2":"",
                                          "CreditCardExpireYear":0,
                                          "CreditCardExpireMonth":0]
        
        let parmCustomer:[String:Any] = ["CustomerGUID": objFinalCheckOut.objCustomer!.guid,
                                         "CustomerId": objFinalCheckOut.objCustomer!.id,
                                         "IpAddress": objFinalCheckOut.orderDetail!.customerIp]
        
        let parmTransaction:[String:Any] = ["AuthorizationTransactionId":"\(transactionId)",
                                                "AuthorizationTransactionCode":"\(intent)",
                                                "AuthorizationTransactionResult":"\(state)",
                                                "CaptureTransactionId":"",
                                                "CaptureTransactionResult":"",
                                                "SubscriptionTransactionId":""]
        
        let params : [String: Any] = ["ApiSecretKey":secretKey,"CustomerGUID": _user.guid, "LanguageId": languageId,"StoreId": storeId, "CurrencyId": currencyId, "PaymentStatus": "Paid", "Order":parmOrder, "Payment":parmPayment, "Customer":parmCustomer, "Transaction":parmTransaction]

        KPWebCall.call.getOrderPaymentDetail(param: params) { [weak self] (json, statusCode) in
            guard let weakself = self else {return}
            weakself.hideHud()
            if statusCode == 200 {
                weakself.postCart()
                weakself.navigateToThankYou()
            } else {
                weakself.showError(data: json, view: weakself.view)
            }
        }
    }
    
    func getOrderSummary() {
        showHud()
        let params : [String: Any] = ["ApiSecretKey":secretKey,"CustomerGUID": _user.guid, "LanguageId": languageId,"StoreId": storeId, "CurrencyId": currencyId]
        KPWebCall.call.getOrderSummary(param: params) { [weak self] (json, statusCode) in
            guard let weakself = self else {return}
            weakself.hideHud()
            if statusCode == 200, let dict = json as? NSDictionary, let status = dict["Status"] as? Bool, status {
                if let jsonData = dict["Data"] as? NSDictionary {
                    weakself.objConfirmOrder = CheckOutOrder(dict: jsonData)
                }
                weakself.getItemImages()
            } else {
                weakself.showError(data: json, view: weakself.view)
            }
        }
    }
    
    func getConfirmOrder(completion: @escaping(Bool) -> ()) {
        showHud()
        let params : [String: Any] = ["ApiSecretKey":secretKey,"CustomerGUID": _user.guid, "LanguageId": languageId,"StoreId": storeId, "CurrencyId": currencyId]
        KPWebCall.call.getConfirmOrderList(param: params) { [weak self] (json, statusCode) in
            guard let weakself = self else {return}
            weakself.hideHud()
            if statusCode == 200, let dict = json as? NSDictionary, let status = dict["Status"] as? Bool, status {
                if let jsonData = dict["Data"] as? NSDictionary {
                    weakself.objFinalCheckOut = ConfirmOrder(dict: jsonData)
                    completion(true)
                }
            } else {
                weakself.showError(data: json, view: weakself.view)
            }
        }
    }
    
    func getItemImages() {
        showHud()
        let allProductsId = objConfirmOrder.arrItems.map{$0.proId}
        let param: [String: Any] = ["ApiSecretKey":secretKey,"LanguageId": languageId, "ThumbSize": "240", "ProductIds": allProductsId]
        KPWebCall.call.getOrderProductImages(param: param) { [weak self] (json, statusCode) in
            guard let weakself = self else {return}
            weakself.hideHud()
            if statusCode == 200, let dict = json as? NSDictionary, let status = dict["Status"] as? Bool, status {
                if let arrImagesDict = dict["Data"] as? [NSDictionary] {
                    for (idx,objImgDict) in arrImagesDict.enumerated() {
                        if let objPictureDict = objImgDict["DefaultPictureModel"] as? NSDictionary {
                            let objPictureModel = PictureModel(dict: objPictureDict)
                            weakself.objConfirmOrder.arrItems[idx].pictureModel = objPictureModel
                        }
                    }
                }
                weakself.collectionView.reloadData()
            } else {
                weakself.showError(data: json, view: weakself.view)
            }
        }
    }
    
    func getProvinceList(contId: String) {
        showHud()
        let params : [String: Any] = ["ApiSecretKey":secretKey,"CustomerGUID": _user.guid, "LanguageId": languageId,"StoreId": storeId, "CurrencyId": currencyId, "CountryId": contId]
        KPWebCall.call.getProvinceList(param: params) { [weak self] (json, statusCode) in
            guard let weakself = self else {return}
            weakself.hideHud()
            weakself.refresh.endRefreshing()
            weakself.arrProvince = []
            if statusCode == 200, let dict = json as? NSDictionary, let status = dict["Status"] as? Bool, status {
                if let arrProvinceList = dict["Data"] as? [NSDictionary] {
                    for provinceDict in arrProvinceList {
                        let objProvince = Province(dict: provinceDict)
                        weakself.arrProvince.append(objProvince)
                    }
                }
                weakself.reloadTable()
            } else {
                weakself.showError(data: json, view: weakself.view)
            }
        }
    }
}
