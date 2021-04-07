//
//  CartVC.swift
//  NopCommerce
//
//  Created by Chirag Patel on 07/03/20.
//  Copyright © 2020 Chirag Patel. All rights reserved.
//

import UIKit

class CartVC: ParentViewController {
        
    @IBOutlet weak var lblOrderTotal: UILabel!
    @IBOutlet weak var placeOrderView: UIView!
    @IBOutlet weak var btnPlaceOrder: UIButton!
    
    var objCart: Cart!
    var objOrderTotal: OrderTotal!
    
    var toolBar: ToolBarView!
    
    var arrShippingOptions: [ShippingOption]!
    var arrCountry: [Country]!
    var arrProvince: [Province]!
    var dropDown = DropDown()
    
    var selectedCountry: Country {
        return arrCountry.filter{$0.isSelected}.first ?? arrCountry[0]
    }
    var selectedProvince: Province? {
        return arrProvince.isEmpty ? nil : arrProvince.filter{$0.isSelected}.first ?? arrProvince.first
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        getCartItems()
    }
}

extension CartVC {
    
    func prepareUI() {
        lblHeaderTitle?.text = getLocalizedKey(str: "shoppingcart")
        btnPlaceOrder.setTitle(getLocalizedKey(str: "checkout.button"), for: .normal)
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 70.widthRatio, right: 0)
        refresh.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.addSubview(refresh)
        prepareToolbar()
        getNoDataCell()
        addKeyboardNotifications()
        addCartObserver()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "proDetailSegue" {
            let destVC = segue.destination as! ProductDetailVC
            destVC.isFromCart = true
            destVC.wishOrCartId = (sender as! WishList).id
            destVC.proName = (sender as! WishList).proName
            destVC.proId = (sender as! WishList).proId
        } else if segue.identifier == "checkOutSegue" {
            let destVC = segue.destination as! CheckOutVC
            destVC.arrCountry = self.arrCountry
            destVC.arrProvince = self.arrProvince
        }
    }
    
    func addCartObserver() {
        _defaultCenter.addObserver(self, selector: #selector(refreshData), name: .addToCart, object: nil)
    }
    
    func addKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboarShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboarShow(_ notification: Notification) {
        if let kbSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: kbSize.height + 10, right: 0)
        }
    }
    
    @objc func keyboardHide(_ notification: Notification) {
        tableView.contentInset = UIEdgeInsets(top:0, left: 0, bottom: 70.widthRatio, right: 0)
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
    
    func prepareToolbar(){
        toolBar = ToolBarView.instantiateViewFromNib()
        toolBar.handleTappedAction { [weak self] (tapped, toolbar) in
            self?.view.endEditing(true)
        }
    }
    
    func openTermsAlert() {
        let alertController = UIAlertController(title: getLocalizedKey(str: "checkout.termsofservice"), message: "Put your privacy policy information here. You can edit this in the admin site.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func getAttributeCell(row: Int, section: Int = 3) -> ProductAttributeCell? {
        let cell = tableView.cellForRow(at: IndexPath(row: row, section: section)) as? ProductAttributeCell
        return cell
    }
    
    @objc func refreshData() {
        getCartItems()
    }
    
    func alertForLogin() {
        let alertController = UIAlertController(title: "Login", message: "Do you want to Login", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: getLocalizedKey(str: "common.ok"), style: .default, handler: { (action) in
            if let tabBar = self.tabBarController as? JTTabBarController {
                tabBar.openLoginPage()
            }
        }))
        alertController.addAction(UIAlertAction(title: getLocalizedKey(str: "common.cancel"), style: .destructive, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}

extension CartVC {
    
    @IBAction func btnMoveToWishListTapped(_ sender: UIButton) {
        guard let indexPath = IndexPath.indexPathForCellContainingView(view: sender, inTableView: tableView) else {return}
        let objProduct = self.objCart.arrItems[indexPath.row]
        if objProduct.quantity < 0 {
           JTValidationToast.show(message: "Minimum Quantity must be 1")
        } else {
            self.moveToWishList(productId: objProduct.id) { (completion) in
                self.objCart.arrItems.remove(at: indexPath.row)
                self.getOrderTotal()
            }
        }
    }
    
    @IBAction func btnRemoveItemTapped(_ sender: UIButton) {
        guard let indexPath = IndexPath.indexPathForCellContainingView(view: sender, inTableView: tableView) else {return}
        let objProduct = self.objCart.arrItems[indexPath.row]
        self.removeFromCart(productId: objProduct.id) { (completion) in
            self.objCart.arrItems.remove(at: indexPath.row)
            self.getOrderTotal()
        }
    }
    
    @IBAction func btnUpdateCartListTapped(_ sender: UIButton) {
        updateCart()
    }
    
    @IBAction func btnPlaceOrderTapped(_ sender: UIButton) {
        if _user.isGuestLogin {
            alertForLogin()
        } else {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "checkOutSegue", sender: nil)
            }
        }
    }
    
    @IBAction func btnSelectCountryStateTapped(_ sender: UIButton) {
        self.configureDropDown(sender: sender)
        dropDown.dataSource.removeAll()
        if sender.tag == 0 {
            dropDown.dataSource = self.arrCountry.map{$0.name}
            self.arrCountry.forEach{$0.isSelected = false}
            dropDown.selectionAction = { [weak self] (index: Int, item: String) in
                guard let weakself = self else {return}
                weakself.arrCountry[index].isSelected = true
                weakself.showHud()
                weakself.getProvinceList()
            }
        } else {
            dropDown.dataSource = self.arrProvince.map{$0.name}
            self.arrProvince.forEach{$0.isSelected = false}
            dropDown.selectionAction = { [weak self] (index: Int, item: String) in
                guard let weakself = self else {return}
                weakself.arrProvince[index].isSelected = true
                UIView.performWithoutAnimation {
                    weakself.tableView.reloadSections(IndexSet(integer: 5), with: .none)
                }
            }
        }
        dropDown.show()
    }
    
    @IBAction func btnSelectQuantityTapped(_ sender: UIButton) {
        self.configureDropDown(sender: sender)
        dropDown.dataSource.removeAll()
        dropDown.dataSource = self.objCart.arrItems[sender.tag].arrQuantity.map{$0.value}
        dropDown.selectionAction = { [weak self] (index: Int, item: String) in
            guard let weakself = self else {return}
            weakself.objCart.arrItems[sender.tag].quantity = item.integerValue ?? 0
            weakself.tableView.reloadRows(at: [IndexPath(row: sender.tag, section: 0)], with: .none)
        }
        dropDown.show()
    }
    
    @IBAction func btnAcceptTermsTapped(_ sender: UIButton) {
        let isSelected = sender.isSelected
        sender.isSelected = !isSelected
        if let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 6)) as? CartTableCell {
            cell.tickImgView.image = sender.isSelected ? #imageLiteral(resourceName: "checkMark") : #imageLiteral(resourceName: "uncheckmark")
        }
        UIView.performWithoutAnimation {
            self.tableView.reloadSections(IndexSet(integer: 5), with: .none)
        }
    }
    
    @IBAction func btnTapped(_ sender: UIButton) {
        guard let idx = IndexPath.indexPathForCellContainingView(view: sender, inTableView: tableView) else {return}
        if idx.section == 2 {
            if objCart.isApplyCoupanShown && idx.row == 0 {
                guard !objCart.arrOffersFields[idx.row].text.isEmpty else {
                   JTValidationToast.show(message: objCart.arrOffersFields[idx.row].placeholder)
                    return
                }
                let isSelected = objCart.arrOffersFields[idx.row].isSelected
                self.applyRemoveDiscount(isApply: !isSelected, code: objCart.arrOffersFields[idx.row].text) { (completion) in
                    if completion {
                        self.objCart.arrOffersFields[idx.row].isSelected = !isSelected
                    } else {
                        self.objCart.arrOffersFields[idx.row].text.removeAll()
                    }
                    UIView.performWithoutAnimation {
                        self.tableView.reloadSections(IndexSet(integer: idx.section), with: .automatic)
                    }
                }
            } else {
                guard !objCart.arrOffersFields[idx.row].text.isEmpty else {
                   JTValidationToast.show(message: objCart.arrOffersFields[idx.row].placeholder)
                    return
                }
                let isSelected = objCart.arrOffersFields[idx.row].isSelected
                self.applyRemoveGiftCard(isApply: !isSelected, code: objCart.arrOffersFields[idx.row].text) { (completion) in
                    if completion {
                        self.objCart.arrOffersFields[idx.row].isSelected = !isSelected
                    } else {
                        self.objCart.arrOffersFields[idx.row].text.removeAll()
                    }
                    UIView.performWithoutAnimation {
                        self.tableView.reloadSections(IndexSet(integer: idx.section), with: .automatic)
                    }
                }
            }
        } else if idx.section == 3 {
            let validate = objCart.validatetData()
            if validate.isValid {
                self.setCheckOutAttributes()
            } else {
                JTValidationToast.show(message: validate.error)
            }
        } else {
            if selectedProvince == nil {
                JTValidationToast.show(message: "Please select differnt Country")
            } else if objCart.zipCode.isEmpty {
               JTValidationToast.show(message: "Please enter zipcode")
            } else {
                self.getEstimateShipping()
            }
        }
    }
}

extension CartVC {
    
    @IBAction func btnDropDownTapped(_ sender: UIButton) {
        configureDropDown(sender: sender)
        dropDown.dataSource.removeAll()
        dropDown.dataSource = objCart.arrAttribues[sender.tag].arrAttributesValues.map{$0.name}
        objCart.arrAttribues[sender.tag].arrAttributesValues.forEach{$0.isPreSelected = false}
        dropDown.selectionAction = { [weak self] (index: Int, item: String) in
            guard let weakself = self else {return}
            weakself.objCart.arrAttribues[sender.tag].arrAttributesValues[index].isPreSelected = true
            weakself.tableView.reloadData()
        }
        dropDown.show()
    }
    
    @IBAction func btnOpenDatePicker(_ sender: UIButton) {
        self.view.endEditing(true)
        guard let idx = IndexPath.indexPathForCellContainingView(view: sender, inTableView: tableView) else {return}
       let picker = KPDatePicker.instantiateViewFromNib(withView: self.view)
        picker.datePicker.datePickerMode = .date
        picker.datePicker.minimumDate = Date()
        picker.selectionBlock = { [weak self] (date) -> () in
            guard let weakself = self else {return}
            let strDate = Date.localDateString(from: date, format: "yyyy/MMM/dd")
            weakself.objCart.arrAttribues[idx.row].value = strDate
            weakself.tableView.reloadData()
        }
    }
    
    @IBAction func tfEditingChange(_ textField: UITextField) {
        let str = textField.text!.trimmedString()
        objCart.arrAttribues[textField.tag].value = str
    }
}

extension CartVC {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard objCart != nil else {return 0}
        guard !objCart.arrItems.isEmpty else {return 1}
        return objOrderTotal == nil ? 0 : arrProvince == nil ? 6 : 7
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard !objCart.arrItems.isEmpty else {return 1}
        if section == 0 {
            return objCart.arrItems.count
        } else if section == 1 {
            return 1
        } else if section == 2 {
            return objCart.arrOffersFields.count
        } else if section == 3 {
            return objCart.arrAttribues.count + 1
        } else if section == 4 {
            return objCart.checkOutAttriInfo.isEmpty ? 0 : 1
        } else if section == 5 && (arrCountry != nil && arrProvince != nil) {
            return arrShippingOptions == nil ? 2 : 2 + arrShippingOptions.count
        } else {
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard !objCart.arrItems.isEmpty else {return tableView.frame.size.height}
        if indexPath.section == 0 {
            return UITableView.automaticDimension
        } else if indexPath.section == 1 {
            return 70.widthRatio
        } else if indexPath.section == 2 {
            return 160.widthRatio
        } else if indexPath.section == 3 {
            if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
                return 55.widthRatio
            } else {
                let objAttri = self.objCart.arrAttribues
                let objSubAttri = objAttri[indexPath.row].arrAttributesValues
                return objSubAttri == nil || !objSubAttri!.isEmpty ?
                objAttri[indexPath.row].controlType.cellHeight : 0
            }
        } else if indexPath.section == 4 {
            return objCart.checkOutAttriInfo.isEmpty ? 0 : UITableView.automaticDimension
        } else if indexPath.section == 5 && (arrCountry != nil && arrProvince != nil) {
            return indexPath.row == 0 ? 180.widthRatio : indexPath.row == 1 ? 55.widthRatio : UITableView.automaticDimension
        } else {
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard !objCart.arrItems.isEmpty else {return 0}
        if section == 2 || section == 3 || section == 5 || section == 6 {
            return 45.widthRatio
        } else {
            return 0
        }
    }
    
     func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard !objCart.arrItems.isEmpty else {return nil}
        if section == 2 || section == 3 || section == 5 || section == 6 {
            let headerView = tableView.dequeueReusableCell(withIdentifier: "headerCell") as! TableHeaderCell
            headerView.lblTitle.text = section == 2 ? "OFFERS" : section == 3 ? "Checkout Attribute" : section == 5 ? getLocalizedKey(str: "shoppingcart.estimateshipping.button") : "PRICE DETAILS"
            return headerView.contentView
        } else {
            return nil
        }
     }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard !objCart.arrItems.isEmpty else {
            let cell: NoDataTableCell
            cell = tableView.dequeueReusableCell(withIdentifier: "noDataCell", for: indexPath) as! NoDataTableCell
            cell.setText(str: "No Product in Cart...")
            return cell
        }
        if indexPath.section == 0 {
            let cell: WishlistTableCell
            cell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath) as! WishlistTableCell
            cell.parent = self
            cell.tag = indexPath.row
            cell.prepareWishListUI(data: objCart.arrItems[indexPath.row])
            return cell
        } else if indexPath.section == 1 {
            let cell: WishListFooterCell
            cell = tableView.dequeueReusableCell(withIdentifier: "updateCell", for: indexPath) as! WishListFooterCell
            cell.prepareBtnUI()
            return cell
        } else if indexPath.section == 2 {
            let cell: CartTableCell
            cell = tableView.dequeueReusableCell(withIdentifier: "offerCell", for: indexPath) as! CartTableCell
            cell.parent = self
            cell.currSection = indexPath.section
            cell.tag = indexPath.row
            cell.prepareOffersUI(field: objCart.arrOffersFields[indexPath.row])
            return cell
        } else if indexPath.section == 3 {
            if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
                let cell: CartTableCell
                cell = tableView.dequeueReusableCell(withIdentifier: "btnCell", for: indexPath) as! CartTableCell
                cell.btn.setTitle("APPLY CHECKOUT ATTRIBUTE", for: .normal)
                return cell
            } else {
                let cell: ProductAttributeCell
                let cellId = objCart.arrAttribues[indexPath.row].controlType.cellIdentifier
                guard !cellId.isEmpty else { return UITableViewCell() }
                cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ProductAttributeCell
                cell.parent = self
                cell.currSection = indexPath.section
                cell.tag = indexPath.row
                cell.objAttribute = objCart.arrAttribues[indexPath.row]
                cell.prepareProductAttributeUI()
                return cell
            }
        } else if indexPath.section == 4 {
            let cell: CartTableCell
            cell = tableView.dequeueReusableCell(withIdentifier: "infoCell", for: indexPath) as! CartTableCell
            cell.lblTitle.text = objCart.attributeInfo
            return cell
        } else if indexPath.section == 5 && (arrCountry != nil && arrProvince != nil) {
            if indexPath.row == 0 {
                let cell: CartTableCell
                cell = tableView.dequeueReusableCell(withIdentifier: "addressCell", for: indexPath) as! CartTableCell
                cell.parent = self
                cell.currSection = indexPath.section
                cell.prepareEstimateShipping(country: selectedCountry, province: selectedProvince)
                return cell
            } else if indexPath.row == 1 {
                let cell: CartTableCell
                cell = tableView.dequeueReusableCell(withIdentifier: "btnCell", for: indexPath) as! CartTableCell
                cell.btn.setTitle(getLocalizedKey(str: "shoppingcart.estimateshipping.button"), for: .normal)
                return cell
            } else {
               let cell: CartTableCell
               cell = tableView.dequeueReusableCell(withIdentifier: "shippingCell", for: indexPath) as! CartTableCell
               cell.prepareShippingUI(data: arrShippingOptions[indexPath.row - 2])
               return cell
            }
        } else {
            if indexPath.row == 0 {
                let cell: CartTableCell
                cell = tableView.dequeueReusableCell(withIdentifier: "priceCell", for: indexPath) as! CartTableCell
                cell.preparePaymentSumary(data: objOrderTotal)
                return cell
            } else {
                let cell: CartTableCell
                cell = tableView.dequeueReusableCell(withIdentifier: "termsCell", for: indexPath) as! CartTableCell
                cell.configureTermsAndCondition()
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !objCart.arrItems.isEmpty else {return}
        if indexPath.section == 0 {
            DispatchQueue.main.async {
                let objItem = self.objCart.arrItems[indexPath.row]
                self.performSegue(withIdentifier: "proDetailSegue", sender: objItem)
            }
        } else if indexPath.section == 6 && indexPath.row == 1 {
            openTermsAlert()
        }
    }
}

extension CartVC {
    
    func getCartItems() {
        if !refresh.isRefreshing {
            showHud()
        }
        let params : [String: Any] = ["ApiSecretKey":secretKey,"CustomerGUID": _user.guid, "LanguageId": languageId,"StoreId": storeId, "CurrencyId": currencyId]
        KPWebCall.call.getCartItemData(param: params) { [weak self] (json, statusCode) in
            guard let weakself = self else {return}
            if statusCode == 200, let dict = json as? NSDictionary, let status = dict["Status"] as? Bool, status {
                if let jsonData = dict["Data"] as? NSDictionary {
                    weakself.objCart = Cart(dict: jsonData)
                }
                if weakself.objCart.arrItems.isEmpty {
                    weakself.tableView.reloadData()
                } else {
                    weakself.setCheckOutAttributes(needToShowPopup: false)
                }
            } else {
                weakself.hideHud()
                weakself.refresh.endRefreshing()
                weakself.objCart = Cart(dict: [:])
                weakself.placeOrderView.isHidden = weakself.objCart.arrItems.isEmpty
                weakself.tableView.reloadData()
            }
        }
    }
    
    func getOrderTotal() {
        let params : [String: Any] = ["ApiSecretKey":secretKey,"CustomerGUID": _user.guid, "LanguageId": languageId,"StoreId": storeId, "CurrencyId": currencyId, "IsEditable": true]
        KPWebCall.call.getOrderAmount(param: params) { [weak self] (json, statusCode) in
            guard let weakself = self else {return}
            weakself.hideHud()
            weakself.refresh.endRefreshing()
            if statusCode == 200, let dict = json as? NSDictionary, let status = dict["Status"] as? Bool, status {
                if let jsonData = dict["Data"] as? NSDictionary {
                    weakself.objOrderTotal = OrderTotal(dict: jsonData)
                    weakself.placeOrderView.isHidden = weakself.objOrderTotal == nil
                    weakself.lblOrderTotal.text = weakself.objOrderTotal.orderTotal
                }
                weakself.tableView.reloadData()
                if weakself.arrCountry == nil {
                    weakself.getCountryList()
                }
            } else {
                weakself.placeOrderView.isHidden = weakself.objCart.arrItems.isEmpty
                weakself.tableView.reloadData()
            }
        }
    }
    
    func getCountryList() {
        let params : [String: Any] = ["ApiSecretKey":secretKey,"CustomerGUID": _user.guid, "LanguageId": languageId,"StoreId": storeId, "CurrencyId": currencyId]
        KPWebCall.call.getCountryList(param: params) { [weak self] (json, statusCode) in
            guard let weakself = self else {return}
            weakself.arrCountry = []
            if statusCode == 200, let dict = json as? NSDictionary, let status = dict["Status"] as? Bool, status {
                if let arrCountryList = dict["Data"] as? [NSDictionary] {
                    for countryDict in arrCountryList {
                        let objCountry = Country(dict: countryDict)
                        weakself.arrCountry.append(objCountry)
                    }
                }
                weakself.getProvinceList()
            } else {
                weakself.showError(data: json, view: weakself.view)
            }
        }
    }
    
    func getProvinceList() {
        let params : [String: Any] = ["ApiSecretKey":secretKey,"CustomerGUID": _user.guid, "LanguageId": languageId,"StoreId": storeId, "CurrencyId": currencyId, "CountryId": selectedCountry.id]
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
                weakself.tableView.reloadData()
            } else {
                weakself.showError(data: json, view: weakself.view)
            }
        }
    }
    
    func applyRemoveGiftCard(isApply: Bool, code: String, completion: @escaping(Bool) -> ()) {
        showHud()
        let params : [String: Any] = ["ApiSecretKey":secretKey,"CustomerGUID": _user.guid,"StoreId": storeId, "code": code]
        let relPath = isApply ? "ApplyGiftCard" : "RemoveGiftCard"
        KPWebCall.call.applyRemoveGiftCard(relPath: relPath, param: params) { [weak self] (json, statusCode) in
            guard let weakself = self else {return}
            weakself.hideHud()
            if statusCode == 200, let dict = json as? NSDictionary, let status = dict["Status"] as? Bool, status {
                if let jsonData = dict["Data"] as? NSDictionary {
                    weakself.showSuccessMsg(data: jsonData, view: weakself.view)
                }
                completion(true)
            } else {
                completion(false)
                weakself.hideHud()
                weakself.showError(data: json, view: weakself.view)
            }
        }
    }
    
    func applyRemoveDiscount(isApply: Bool, code: String, completion: @escaping(Bool) -> ()) {
        showHud()
        let params : [String: Any] = ["ApiSecretKey":secretKey,"CustomerGUID": _user.guid,"StoreId": storeId, "code": code]
        let relPath = isApply ? "ApplyDiscount" : "RemoveDiscount"
        KPWebCall.call.applyRemoveDiscount(relPath: relPath, param: params) { [weak self] (json, statusCode) in
            guard let weakself = self else {return}
            weakself.hideHud()
            if statusCode == 200, let dict = json as? NSDictionary, let status = dict["Status"] as? Bool, status {
                if let jsonData = dict["Data"] as? NSDictionary {
                    weakself.showSuccessMsg(data: jsonData, view: weakself.view)
                }
                completion(true)
            } else {
                completion(false)
                weakself.hideHud()
                weakself.showError(data: json, view: weakself.view)
            }
        }
    }
    
    func getEstimateShipping() {
        showHud()
        let params : [String: Any] = ["ApiSecretKey":secretKey,"CustomerGUID": _user.guid,"StoreId": storeId, "CurrencyId": currencyId, "CountryId": selectedCountry.id, "StateProvinceId": selectedProvince!.id, "ZipPostalCode": objCart.zipCode]
        KPWebCall.call.getEstimateShipping(param: params) { [weak self] (json, statusCode) in
            guard let weakself = self else {return}
            weakself.hideHud()
            weakself.arrShippingOptions = []
            if statusCode == 200, let dict = json as? NSDictionary, let status = dict["Status"] as? Bool, status {
                if let jsonData = dict["Data"] as? NSDictionary, let arrShippingDict = jsonData["ShippingOptions"] as? [NSDictionary] {
                    for shippingDict in arrShippingDict {
                        let objShipping = ShippingOption(dict: shippingDict)
                        weakself.arrShippingOptions.append(objShipping)
                    }
                }
                weakself.tableView.reloadData()
            } else {
                weakself.hideHud()
                weakself.showError(data: json, view: weakself.view)
            }
        }
    }
    
    func getAttributeDict() -> [NSDictionary] {
        var arrAttriDict: [NSDictionary] = []
        for attri in self.objCart.arrAttribues {
            if attri.controlType == .txtField || attri.controlType == .txtView || attri.controlType == .datePicker {
                arrAttriDict.append(["AttributeId": attri.id, "AttributeValue": attri.value])
            } else {
                if attri.arrAttributesValues != nil && !attri.arrAttributesValues.isEmpty {
                    let arrSelectedVal = attri.arrAttributesValues.filter{$0.isPreSelected}
                    let strSelectedId = arrSelectedVal.map{"\($0.id)"}.joined(separator: ",")
                    let strSubAttriVal = arrSelectedVal.isEmpty ? "\(attri.arrAttributesValues[0].id)" : strSelectedId
                    arrAttriDict.append(["AttributeId": attri.id, "AttributeValue": strSubAttriVal])
                }
            }
        }
        return arrAttriDict
    }
    
    func setCheckOutAttributes(needToShowPopup: Bool = true) {
        showHud()
        let params : [String: Any] = ["ApiSecretKey":secretKey,"CustomerGUID": _user.guid, "LanguageId": languageId,"StoreId": storeId, "CurrencyId": currencyId, "CheckoutAttributeResponse": getAttributeDict()]
        KPWebCall.call.applyCheckOutAttribute(param: params) { [weak self] (json, statusCode) in
            guard let weakself = self else {return}
            weakself.hideHud()
            if statusCode == 200, let dict = json as? NSDictionary, let status = dict["Status"] as? Bool, status {
                if let jsonData = dict["Data"] as? NSDictionary {
                    weakself.objCart.checkOutAttriInfo = jsonData.getStringValue(key: "CheckoutAttributeInfo")
                    if needToShowPopup {
                        weakself.showSuccessMsg(data: jsonData, view: weakself.view)
                    }
                }
                weakself.getOrderTotal()
            } else {
                weakself.hideHud()
                weakself.showError(data: json, view: weakself.view)
            }
        }
    }
    
    func getSelectedDict() -> [NSDictionary] {
        var cartItems: [NSDictionary] = []
        let arrAllowEditProducts = self.objCart.arrItems.filter{$0.allowItemEditing}
        for (_,item) in arrAllowEditProducts.enumerated() {
            cartItems.append(["ItemId": item.id, "Quantity": item.quantity])
        }
        return cartItems
    }
    
    func updateCart() {
        showHud()
        let param: [String: Any] = ["ApiSecretKey":secretKey, "CustomerGUID":_user.guid, "StoreId": storeId, "CurrencyId": currencyId, "LanguageId": languageId, "RemoveFromCart":"1", "CartItems": self.getSelectedDict()]
        KPWebCall.call.updateCartData(param: param) { [weak self] (json, statusCode) in
            guard let weakself = self else {return}
            weakself.hideHud()
            if statusCode == 200, let dict = json as? NSDictionary, let status = dict["Status"] as? Bool, status {
                if let jsonData = dict["Data"] as? NSDictionary {
                    weakself.objCart = Cart(dict: jsonData)
                }
                weakself.getOrderTotal()
            } else {
                weakself.showError(data: json, view: weakself.view)
            }
        }
    }
    
    func moveToWishList(productId: String, completion: @escaping (Bool) -> ()) {
        showHud()
        let param: [String: Any] = ["ApiSecretKey":secretKey, "CustomerGUID":_user.guid, "StoreId": storeId, "WishListItems": [productId]]
        KPWebCall.call.moveToWishList(param: param) { [weak self] (json, statusCode) in
            guard let weakself = self else {return}
            weakself.hideHud()
            if statusCode == 200, let dict = json as? NSDictionary, let status = dict["Status"] as? Bool, status {
                weakself.showSuccessMsg(data: dict, view: weakself.view)
                weakself.postWishList()
                completion(true)
            } else {
                
                JTValidationToast.show(message: "")
                
                weakself.showError(data: json, view: weakself.view)
            }
        }
    }
    
    func removeFromCart(productId: String, completion: @escaping (Bool) -> ()) {
        showHud()
        let param: [String: Any] = ["ApiSecretKey":secretKey, "CustomerGUID":_user.guid, "StoreId": storeId, "CurrencyId": currencyId, "LanguageId": languageId, "ItemIds": productId]
        KPWebCall.call.removeFromCart(param: param) { [weak self] (json, statusCode) in
            guard let weakself = self else {return}
            weakself.hideHud()
            if statusCode == 200, let dict = json as? NSDictionary, let status = dict["Status"] as? Bool, status {
                if let jsonData = dict["Data"] as? NSDictionary {
                    weakself.showSuccessMsg(data: jsonData, view: weakself.view)
                    completion(true)
                }
            } else {
                weakself.showError(data: json, view: weakself.view)
            }
        }
    }
}
