//
//  WishListVC.swift
//  NopCommerce
//
//  Created by Chirag Patel on 07/03/20.
//  Copyright © 2020 Chirag Patel. All rights reserved.
//

import UIKit

class WishListVC: ParentViewController {

    var arrWishList: [WishList]!
    
    var toolBar: ToolBarView!
    var dropDown = DropDown()

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        getWishListItems()
    }
}

extension WishListVC {
    
    func prepareUI() {
        lblHeaderTitle?.text = getLocalizedKey(str: "pagetitle.wishlist")
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        refresh.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.addSubview(refresh)
        prepareToolbar()
        getNoDataCell()
        addWishListObserver()
        setKeyboardNotifications()
    }
     
    func addWishListObserver() {
        _defaultCenter.addObserver(self, selector: #selector(refreshData), name: .addToWishList, object: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "proDetailSegue" {
            let destVC = segue.destination as! ProductDetailVC
            destVC.isFromWishList = true
            destVC.wishOrCartId = (sender as! WishList).id
            destVC.proName = (sender as! WishList).proName
            destVC.proId = (sender as! WishList).proId
        }
    }
    
    func prepareToolbar(){
        toolBar = ToolBarView.instantiateViewFromNib()
        toolBar.handleTappedAction { [weak self] (tapped, toolbar) in
            self?.view.endEditing(true)
        }
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
    
    @objc func refreshData() {
        getWishListItems()
    }
}

extension WishListVC {
    
    @IBAction func btnUpdateWishListTapped(_ sender: UIButton) {
        updateWishList()
    }
    
    @IBAction func btnSelectQuantityTapped(_ sender: UIButton) {
        self.configureDropDown(sender: sender)
        dropDown.dataSource.removeAll()
        dropDown.dataSource = self.arrWishList[sender.tag].arrQuantity.map{$0.value}
        dropDown.selectionAction = { [weak self] (index: Int, item: String) in
            guard let weakself = self else {return}
            weakself.arrWishList[sender.tag].quantity = item.integerValue ?? 0
            weakself.tableView.reloadRows(at: [IndexPath(row: sender.tag, section: 0)], with: .none)
        }
        dropDown.show()
    }
}

extension WishListVC {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrWishList == nil ? 0 : arrWishList.isEmpty ? 1 : 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard !arrWishList.isEmpty else {return 1}
        return section == 0 ? arrWishList.count : 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard !arrWishList.isEmpty else {return tableView.frame.size.height - _tabBarHeight}
        return indexPath.section == 1 ? 55.widthRatio : UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard !arrWishList.isEmpty else {
            let cell: NoDataTableCell
            cell = tableView.dequeueReusableCell(withIdentifier: "noDataCell", for: indexPath) as! NoDataTableCell
            cell.setText(str: "No Products in WishList")
            return cell
        }
        if indexPath.section == 0 {
            let cell: WishlistTableCell
            cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! WishlistTableCell
            cell.parent = self
            cell.tag = indexPath.row
            cell.prepareWishListUI(data: arrWishList[indexPath.row])
            return cell
        } else if indexPath.section == 1 {
            let cell: WishListFooterCell
            cell = tableView.dequeueReusableCell(withIdentifier: "updateCell", for: indexPath) as! WishListFooterCell
            cell.prepareWishlistBtnUI()
            return cell
        } else {
            let cell: WishListFooterCell
            cell = tableView.dequeueReusableCell(withIdentifier: "shareCell", for: indexPath) as! WishListFooterCell
            cell.prepareFooter()
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !arrWishList.isEmpty else {return}
        if indexPath.section == tableView.numberOfSections - 1 {
            let urlStr = "http://demo.nopcommerce.com/wishlist/\(_user.guid)"
            guard urlStr.isValidURL() else {return}
            UIApplication.shared.open(URL(string: urlStr)!, options: [:], completionHandler: nil)
        } else {
            DispatchQueue.main.async {
                let objItem = self.arrWishList[indexPath.row]
                self.performSegue(withIdentifier: "proDetailSegue", sender: objItem)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            let objProduct = self.arrWishList[indexPath.row]
            self.removeFromList(productId: objProduct.id) { (completion) in
                self.arrWishList.remove(at: indexPath.row)
                self.tableView.reloadData()
            }
        })
        deleteAction.image = UIImage(named:"ic_delete")
        deleteAction.backgroundColor = .red
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let cartAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            let objProduct = self.arrWishList[indexPath.row]
            if objProduct.quantity < 0 {
               JTValidationToast.show(message: "Minimum Quantity must be 1")
            } else {
                self.moveToCart(productId: objProduct.id) { (completion) in
                    self.arrWishList.remove(at: indexPath.row)
                    self.tableView.reloadData()
                }
            }
        })
       cartAction.image = UIImage(named:"ic_Cart")
       cartAction.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
       return UISwipeActionsConfiguration(actions: [cartAction])
    }
}

extension WishListVC {
    
    func getWishListItems() {
        let params : [String: Any] = ["ApiSecretKey":secretKey,"CustomerGUID": _user.guid, "LanguageId": languageId,"StoreId": storeId, "CurrencyId": currencyId]
        if !refresh.isRefreshing {
            showHud()
        }
        KPWebCall.call.getWishListData(param: params) { [weak self] (json, statusCode) in
            guard let weakself = self else {return}
            weakself.hideHud()
            weakself.refresh.endRefreshing()
            weakself.arrWishList = []
            if statusCode == 200, let dict = json as? NSDictionary, let status = dict["Status"] as? Bool, status {
                if let jsonData = dict["Data"] as? NSDictionary, let arrWishData = jsonData["Items"] as? [NSDictionary] {
                    for wishDict in arrWishData {
                        let objWishList = WishList(dict: wishDict)
                        weakself.arrWishList.append(objWishList)
                    }
                }
            }
            weakself.tableView.reloadData()
        }
    }
    
    func getSelectedDict() -> [NSDictionary] {
        var cartItems: [NSDictionary] = []
        let arrAllowEditProducts = self.arrWishList.filter{$0.allowItemEditing}
        for (_,item) in arrAllowEditProducts.enumerated() {
            cartItems.append(["ItemId": item.id, "Quantity": item.quantity])
        }
        return cartItems
    }
    
    func updateWishList() {
        showHud()
        let param: [String: Any] = ["ApiSecretKey":secretKey, "CustomerGUID":_user.guid, "StoreId": storeId, "CurrencyId": currencyId, "LanguageId": languageId, "RemoveFromCart":"1", "CartItems": self.getSelectedDict()]
        KPWebCall.call.updateWishListData(param: param) { [weak self] (json, statusCode) in
            guard let weakself = self else {return}
            weakself.hideHud()
            weakself.arrWishList = []
            if statusCode == 200, let dict = json as? NSDictionary, let status = dict["Status"] as? Bool, status {
                if let jsonData = dict["Data"] as? NSDictionary, let arrWishData = jsonData["Items"] as? [NSDictionary] {
                    for wishDict in arrWishData {
                        let objWishList = WishList(dict: wishDict)
                        weakself.arrWishList.append(objWishList)
                    }
                }
                weakself.tableView.reloadData()
            } else {
                weakself.showError(data: json, view: weakself.view)
            }
        }
    }
    
    func moveToCart(productId: String, completion: @escaping (Bool) -> ()) {
        showHud()
        let param: [String: Any] = ["ApiSecretKey":secretKey, "CustomerGUID":_user.guid, "StoreId": storeId, "WishListItems": [productId]]
        KPWebCall.call.moveToCart(param: param) { [weak self] (json, statusCode) in
            guard let weakself = self else {return}
            weakself.hideHud()
            if statusCode == 200, let dict = json as? NSDictionary, let status = dict["Status"] as? Bool, status {
                weakself.showSuccessMsg(data: dict, view: weakself.view)
                weakself.postCart()
                completion(true)
            } else {
                weakself.showError(data: json, view: weakself.view)
            }
        }
    }
    
    func removeFromList(productId: String, completion: @escaping (Bool) -> ()) {
        showHud()
        let param: [String: Any] = ["ApiSecretKey":secretKey, "CustomerGUID":_user.guid, "StoreId": storeId, "CurrencyId": currencyId, "LanguageId": languageId, "ItemIds": productId]
        KPWebCall.call.removeFromWishList(param: param) { [weak self] (json, statusCode) in
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
