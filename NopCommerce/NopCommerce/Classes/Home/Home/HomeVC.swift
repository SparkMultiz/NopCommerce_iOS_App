//
//  HomeVC.swift
//  NopCommerce
//
//  Created by Chirag Patel on 07/03/20.
//  Copyright © 2020 Chirag Patel. All rights reserved.
//

import UIKit

class HomeVC: ParentViewController {

    var welcomeTopic: TopicDetail!
    var arrCategory: [Category]!
    var arrNavSlider: [NavoSlider]!
    var arrFeaturedProduct: [Product]!
    var arrBestSellerProduct: [Product]!
    
    var scrollTimer = Timer()
    
    deinit {
        scrollTimer.invalidate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        getAPIData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.hideShowHomeTabbar(isHidden: false)
        self.scrollTimer.fire()
    }
}

extension HomeVC {
    
    func prepareUI() {
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
    }
    
    func getAPIData() {
        getCategories()
    }
    
    func navigateToProductDetail(product: Product) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "detailSegue", sender: product)
        }
    }
    
    func reloadSection(idx: Int) {
        UIView.performWithoutAnimation {
            self.tableView.reloadSections(IndexSet(integer: idx), with: .automatic)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "productSegue" {
            let destVC = segue.destination as! ProductVC
            destVC.objCategoryId = (sender as! Category).id
            destVC.catName = (sender as! Category).name
        } else if segue.identifier == "detailSegue" {
            let destVC = segue.destination as! ProductDetailVC
            destVC.proName = (sender as! Product).name
            destVC.proId = (sender as! Product).id
        }
    }
}

extension HomeVC {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return arrCategory == nil || arrCategory.isEmpty ? 0 : 1
        } else if section == 1 {
            return arrNavSlider == nil || arrNavSlider.isEmpty ? 0 : 1
        } else if section == 2 {
            return welcomeTopic == nil || welcomeTopic.isTopicEmpty ? 0 : 1
        } else if section == 3 {
            return arrFeaturedProduct == nil || arrFeaturedProduct.isEmpty ? 0 : 1
        } else {
            return arrBestSellerProduct == nil || arrBestSellerProduct.isEmpty ? 0 : 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 2 && welcomeTopic != nil {
            let height = self.welcomeTopic.bodyDesc!.string.heightWithConstrainedWidth(width: _screenSize.width - 40, font: UIFont.systemFont(ofSize: 16.widthRatio)) + 50.0
            return height
        } else {
             return indexPath.section == 0 ? 130.widthRatio : indexPath.section == 1 ? 160.widthRatio : 220.widthRatio
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 3 {
            return arrFeaturedProduct == nil || arrFeaturedProduct.isEmpty ? 0 : 45.widthRatio
        } else if section == 4 {
            return arrBestSellerProduct == nil || arrBestSellerProduct.isEmpty ? 0 : 45.widthRatio
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section == 3 || section == 4 else {return nil}
        let headerView = tableView.dequeueReusableCell(withIdentifier: "headerCell") as! TableHeaderCell
        headerView.lblTitle.text = section == 3 ? getLocalizedKey(str: "homepage.products") : "BEST SELLERS"
        return headerView.contentView
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: HomeTableCell
        let cellId = indexPath.section >= 3 ? "productCell" : "cell\(indexPath.section)"
        cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! HomeTableCell
        cell.parent = self
        cell.tag = indexPath.section
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let homeCell = cell as? HomeTableCell {
            homeCell.prepareHomeUI(with: indexPath.section)
        }
    }
}

extension HomeVC {
    
    func getCategories() {
        showHud()
        let params : [String: Any] = ["ApiSecretKey":secretKey, "CustomerGUID":_user.guid, "StoreId":storeId,"LanguageId":languageId]
        KPWebCall.call.getCategory(param: params) { [weak self] (json, statusCode) in
            guard let weakself = self else {return}
            weakself.arrCategory = []
            if statusCode == 200, let dict = json as? NSDictionary, let status = dict["Status"] as? Bool, status {
                if let arrCategoryData = dict["Data"] as? [NSDictionary] {
                    for catDict in arrCategoryData {
                        let objCat = Category(dict: catDict)
                        weakself.arrCategory.append(objCat)
                    }
                }
                weakself.reloadSection(idx: 0)
                weakself.getHomeSliderData()
            } else {
              //  weakself.showError(data: json, view: weakself.view)
            }
        }
    }
    
    func getHomeSliderData() {
        let params : [String: Any] = ["ApiSecretKey":secretKey, "StoreId":storeId]
        KPWebCall.call.getNivoSlider(param: params) { [weak self] (json, statusCode) in
            guard let weakself = self else {return}
            weakself.arrNavSlider = []
            if statusCode == 200, let dict = json as? NSDictionary, let status = dict["Status"] as? Bool, status {
                if let jsonData = dict["Data"] as? NSDictionary, let arrSliderData = jsonData["NivoSliderList"] as? [NSDictionary] {
                    for slideDict in arrSliderData {
                        let objSlideProduct = NavoSlider(dict: slideDict)
                        weakself.arrNavSlider.append(objSlideProduct)
                    }
                }
                weakself.reloadSection(idx: 1)
                weakself.getWelcomeData()
            } else {
              //  weakself.showError(data: json, view: weakself.view)
            }
        }
    }
    
    func getWelcomeData() {
        let params : [String: Any] = ["ApiSecretKey":secretKey, "CustomerGUID":_user.guid, "StoreId":storeId,"LanguageId":languageId,"SystemName":"HomePageText","IsHtmlL":"false"]
        KPWebCall.call.getHomeWelcomeText(param: params) { [weak self] (json, statusCode) in
            guard let weakself = self else {return}
            if statusCode == 200, let dict = json as? NSDictionary, let status = dict["Status"] as? Bool, status {
                if let jsonData = dict["Data"] as? NSDictionary {
                    weakself.welcomeTopic = TopicDetail(dict: jsonData)
                }
                weakself.reloadSection(idx: 2)
                weakself.getFeaturedProductList()
            } else {
              //  weakself.showError(data: json, view: weakself.view)
            }
        }
    }
    
    func getFeaturedProductList() {
        let params : [String: Any] = ["ApiSecretKey":secretKey,"CustomerGUID": _user.guid, "LanguageId": languageId,"StoreId": storeId, "CurrencyId": currencyId, "ProductThumbPictureSize":"100"]
        KPWebCall.call.getFeaturedList(param: params) { [weak self] (json, statusCode) in
            guard let weakself = self else {return}
            weakself.arrFeaturedProduct = []
            if statusCode == 200, let dict = json as? NSDictionary, let status = dict["Status"] as? Bool, status {
                if let arrProductData = dict["Data"] as? [NSDictionary] {
                    for productDict in arrProductData {
                        let objProduct = Product(dict: productDict)
                        weakself.arrFeaturedProduct.append(objProduct)
                    }
                }
                weakself.reloadSection(idx: 3)
                weakself.getBestSellerProducts()
            } else {
               // weakself.showError(data: json, view: weakself.view)
            }
        }
    }
    
    func getBestSellerProducts() {
        let params : [String: Any] = ["ApiSecretKey":secretKey,"CustomerGUID": _user.guid, "LanguageId": languageId,"StoreId": storeId, "CurrencyId": currencyId, "ProductThumbPictureSize":"100"]
        KPWebCall.call.getBestSellerList(param: params) { [weak self] (json, statusCode) in
            guard let weakself = self else {return}
            weakself.hideHud()
            weakself.arrBestSellerProduct = []
            if statusCode == 200, let dict = json as? NSDictionary, let status = dict["Status"] as? Bool, status {
                if let arrProductData = dict["Data"] as? [NSDictionary] {
                    for productDict in arrProductData {
                        let objProduct = Product(dict: productDict)
                        weakself.arrBestSellerProduct.append(objProduct)
                    }
                }
                weakself.reloadSection(idx: 4)
            } else {
              //  weakself.showError(data: json, view: weakself.view)
            }
        }
    }
    
    func moveToWishList(with id: String, completion: @escaping (Bool) -> ()) {
        let param: [String: Any] = ["ApiSecretKey":secretKey,"CustomerGUID": _user.guid,"StoreId": storeId, "CurrencyId": currencyId, "ShoppingCartTypeId": "2", "Quantity": "1", "ProductId": id]
        showHud()
        KPWebCall.call.addToCartAndWishList(param: param) { [weak self] (json, statusCode) in
            guard let weakself = self else {return}
            weakself.hideHud()
            if statusCode == 200, let dict = json as? NSDictionary, let status = dict["Status"] as? Bool, status {
                if let jsonData = dict["Data"] as? NSDictionary {
                    let isRedirect = jsonData.getBooleanValue(key: "IsRedirect")
                    let redirectPage = jsonData.getStringValue(key: "RedirectionPage")
                    if isRedirect && redirectPage.isEqual(str: "Product") {
                        completion(isRedirect)
                    } else {
                        weakself.showSuccessMsg(data: jsonData, view: weakself.view)
                        weakself.postWishList()
                    }
                }
            } else {
              //  weakself.showError(data: json, view: weakself.view)
            }
        }
    }
}
