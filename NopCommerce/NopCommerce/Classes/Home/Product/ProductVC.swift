//
//  ProductVC.swift
//  NopCommerce
//
//  Created by Chirag Patel on 07/03/20.
//  Copyright © 2020 Chirag Patel. All rights reserved.
//

import UIKit

class ProductVC: ParentViewController {
    
    @IBOutlet var btnTopMenu: UIButton!
    @IBOutlet var btnTopBack: UIButton!
    
    @IBOutlet weak var btnSort: UIButton!
    @IBOutlet weak var btnFilter: UIButton!
    
    @IBOutlet weak var tblConst: NSLayoutConstraint!
    
    @IBOutlet weak var btnSectionDropDown: UIButton!
    
    var isLayoutList = false
    var isFromSlideMenu = false
    
    var isSliderOpen = false
    var objCategoryId: String?
    var catName: String!
    
    var objCategory: MainCategory!
    
//    var objCategory: MainCategory {
//        let objCat = arrCategories.filter{$0.id.isEqual(str: objCategoryId!)}.first ?? arrCategories[0]
//        return objCat
//    }
    
    
    var arrProducts: [Product]!
    var loadMore = LoadMore()
    
    deinit {
        _filterData = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        getAPIData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.hideShowHomeTabbar(isHidden: !isFromSlideMenu)
    }
}

extension ProductVC {
    
    func prepareUI() {
        lblHeaderTitle?.text = catName
        btnTopBack.isHidden = isFromSlideMenu
        btnTopMenu.isHidden = !isFromSlideMenu
        btnSectionDropDown.isHidden = objCategory.subCategories.isEmpty
       // btnFilter.setTitle(getLocalizedKey(str: "filtering.pricerangefilter"), for: .normal)
        btnSort.setTitle(" \(getLocalizedKey(str: "catalog.orderby")) ", for: .normal)
        getCollNoDataCell()
    }
    
    func getTblHeight() -> CGFloat {
        var height: CGFloat = 0.0
        for innerSub in objCategory.subCategories {
            if innerSub.isRowSelected {
                height += 45.widthRatio
            }
        }
        let sectionHeight = CGFloat(objCategory.subCategories.count) * (45.widthRatio)
        height += sectionHeight
        return height
    }
    
    func toggleTblSlider() {
        isSliderOpen = !isSliderOpen
        btnSectionDropDown.transform = isSliderOpen ? CGAffineTransform.identity : CGAffineTransform(rotationAngle: .pi)
        let totalSection = isSliderOpen ? getTblHeight() : 0
        UIView.animate(withDuration: 0.3, delay: 0, options: .transitionCurlDown) {
            self.tblConst.constant = totalSection
            self.view.layoutIfNeeded()
        } completion: { (completion) in
            self.tableView.reloadData()
        }
    }
    
    func clearSelection() {
        guard arrCategories != nil else {return}
        objCategory.subCategories.forEach{$0.isViewEnable = false}
        objCategory.subCategories.forEach{$0.innerSubCat.forEach{$0.isViewEnable = false}}
    }
    
    func setSectionSelectedSubCategory(ind: Int) {
        clearSelection()
        objCategory.subCategories[ind].isViewEnable = true
        self.tableView.reloadData()
    }
    
    func setRowSelectedInnerCategory(ind: Int, section: Int) {
        clearSelection()
        objCategory.subCategories[section].innerSubCat[ind].isViewEnable = true
        self.tableView.reloadData()
    }
    
    func getAPIData(id: String = "") {
        let loadParam: [String: Any] = ["PageNumber": loadMore.index, "PageSize": loadMore.limit]
        let param: [String: Any] = ["ApiSecretKey":secretKey,"CustomerGUID": _user.guid, "LanguageId": languageId,"StoreId": storeId, "CurrencyId": currencyId, "CategoryId": id.isEmpty ? objCategoryId! : id, "CatalogPagingResponse" : loadParam]
        getProductByCategory(param: param)
    }
    
    func navigateToProductDetail(product: Product) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "proDetailSegue", sender: product)
        }
    }
    
    func getFilterData(data: FilterModel) {
        let loadParam: [String: Any] = ["PageNumber": loadMore.index, "PageSize": loadMore.limit]
        
        let selectedSpecs = data.arrSpecFilter.flatMap{$0.arrAttributeOption.filter{$0.selected}}
        let arrSpecId = selectedSpecs.map{$0.specId}.filter{!$0.isEmpty}
        
        let selectedPrice = data.arrPriceFilter.filter{$0.selected}
        let minPrice: String = selectedPrice.map{$0.from}.min() ?? "0"
        let maxPrice: String = selectedPrice.map{$0.to}.max() ?? "0"
        
        let strMin = minPrice.isEqual(str: "0") ? "" : minPrice
        let strMax = maxPrice.isEqual(str: "0") ? "" : maxPrice
        
        let param: [String: Any] = ["ApiSecretKey":secretKey,"CustomerGUID": _user.guid, "LanguageId": languageId,"StoreId": storeId, "CurrencyId": currencyId, "CategoryId": objCategoryId!, "SpecIds": arrSpecId, "MinPrice": strMin, "MaxPrice": strMax, "CatalogPagingResponse" : loadParam]
        getProductByCategory(param: param)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "filterSegue" {
            let destVC = segue.destination as! FilterVC
            destVC.objCategoryId = self.objCategoryId
            destVC.catName = self.catName
            destVC.delegate = self
        } else if segue.identifier == "proDetailSegue" {
            let destVC = segue.destination as! ProductDetailVC
            destVC.proName = (sender as! Product).name
            destVC.proId = (sender as! Product).id
        }
    }
}

extension ProductVC {
    
    @IBAction func btnListGridViewTapped(_ sender: UIButton) {
        isLayoutList = !isLayoutList
        sender.isSelected = !sender.isSelected
        collectionView.reloadData()
    }
    
    @IBAction func btnSortTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            self.arrProducts.sort { (objPro, objPro1) -> Bool in
                return objPro1.name > objPro.name
            }
        } else {
            self.arrProducts.sort { (objPro, objPro1) -> Bool in
                return objPro.name > objPro1.name
            }
        }
        collectionView.reloadData()
    }
    
    @IBAction func btnMoveToWishList(_ sender: UIButton) {
        guard let idx = IndexPath.indexPathForCellContainingView(view: sender, inCollectionView: collectionView) else {return}
        let objProduct = self.arrProducts[idx.row]
        self.moveToWishList(with: objProduct.id) { (completion) in
            self.navigateToProductDetail(product: objProduct)
        }
    }
    
    @IBAction func btnFilterTapped(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "filterSegue", sender: nil)
        }
    }
    
    @objc func btnExpandSectionTapped(_ sender: UIButton) {
        let section = sender.tag
        let isSelected = objCategory.subCategories[section].isRowSelected
        objCategory.subCategories[section].isRowSelected = !isSelected
        let totalSection = CGFloat(objCategory.subCategories.count) * (45.widthRatio)
        let totalHeight = objCategory.subCategories[section].isRowSelected ? CGFloat(objCategory.subCategories[section].innerSubCat.count) * (45.widthRatio) : 0
        let finalHeight = totalSection + totalHeight
        tblConst.constant = finalHeight
        view.layoutIfNeeded()
        tableView.reloadData()
    }
    
    @IBAction func btnResetSubSelection(_ sender: UIButton) {
        if isSliderOpen {
            toggleTblSlider()
        }
        clearSelection()
        self.loadMore = LoadMore()
        self.getAPIData()
    }
    
    @IBAction func btnSubCatTapped(_ sender: UIButton) {
        let tag = sender.tag
        setSectionSelectedSubCategory(ind: tag)
        self.toggleTblSlider()
        let objSubCategory = objCategory.subCategories[tag].id
        self.loadMore = LoadMore()
        getAPIData(id: objSubCategory)
    }
    
    @IBAction func btnExpandTapped(_ sender: UIButton) {
        self.toggleTblSlider()
    }
}

extension ProductVC: FilterDataDelegate {
   
    func applyFileredData(data: FilterModel) {
        _filterData = data
        self.loadMore = LoadMore()
        self.getFilterData(data: data)
    }
    
    func reloadTableData() {
        self.loadMore = LoadMore()
        self.getAPIData()
    }
}

extension ProductVC {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrCategories.isEmpty ? 0 : objCategory.subCategories.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objCategory.subCategories[section].isRowSelected ? objCategory.subCategories[section].innerSubCat.count : 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let isSelected = objCategory.subCategories[indexPath.section].isRowSelected
        return isSelected ? 45.widthRatio : 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return arrCategories.isEmpty ? 0 : 45.widthRatio
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard !arrCategories.isEmpty else {return nil}
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellHeader") as! MenuItemCell
        cell.lblTitle.text = objCategory.subCategories[section].name
        let isSelected = objCategory.subCategories[section].isViewEnable
        cell.lblTitle.font = isSelected ? UIFont.boldSystemFont(ofSize: 16.widthRatio) : UIFont.systemFont(ofSize: 15.widthRatio)
        cell.btnExpand.tag = section
        cell.btnSection.tag = section
        cell.btnExpand.isHidden = objCategory.subCategories[section].innerSubCat.isEmpty
        cell.imgDropDown.isHidden = objCategory.subCategories[section].innerSubCat.isEmpty
        cell.imgDropDown.transform = objCategory.subCategories[section].isRowSelected ? CGAffineTransform(rotationAngle: .pi) : CGAffineTransform.identity
        cell.btnExpand.addTarget(self, action: #selector(btnExpandSectionTapped(_:)), for: .touchUpInside)
        cell.contentView.backgroundColor = #colorLiteral(red: 0.9411764706, green: 0.9411764706, blue: 0.9411764706, alpha: 1)
        return cell.contentView
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MenuItemCell
        cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as! MenuItemCell
        cell.lblTitle.text = objCategory.subCategories[indexPath.section].innerSubCat[indexPath.row].name
        let isSelected = objCategory.subCategories[indexPath.section].innerSubCat[indexPath.row].isViewEnable
        cell.lblTitle.font = isSelected ? UIFont.boldSystemFont(ofSize: 16.widthRatio) : UIFont.systemFont(ofSize: 15.widthRatio)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.setRowSelectedInnerCategory(ind: indexPath.row, section: indexPath.section)
        self.toggleTblSlider()
        let innerSubId = objCategory.subCategories[indexPath.section].innerSubCat[indexPath.row].id
        self.loadMore = LoadMore()
        getAPIData(id: innerSubId)
    }
}

extension ProductVC: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return arrProducts == nil ? 0 : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrProducts.isEmpty ? 1 : arrProducts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if arrProducts.isEmpty {
            let cell: EmptyCollCell
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "noDataCell", for: indexPath) as! EmptyCollCell
            cell.setText(str: "No Product Found")
            return cell
        } else {
            let cell: ProductCollectionCell
            let cellId = isLayoutList ? "listCell" : "collCell"
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ProductCollectionCell
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let productCell = cell as? ProductCollectionCell {
            productCell.prepareUI(data: arrProducts[indexPath.row])
            if indexPath.row == arrProducts.count - 1 && !loadMore.isLoading && !loadMore.isAllLoaded {
                if _filterData == nil {
                    self.getAPIData()
                } else {
                    self.getFilterData(data: _filterData)
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard !arrProducts.isEmpty else {return}
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "proDetailSegue", sender: self.arrProducts[indexPath.row])
        }
    }
}

extension ProductVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return isLayoutList ? 0 : 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if self.arrProducts.isEmpty {
            return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height)
        } else {
            if isLayoutList {
                let width = collectionView.frame.size.width - 10
                return CGSize(width: width, height: 160.widthRatio)
            } else {
                let width = collectionView.frame.size.width - 30
                return CGSize(width: width / 2, height: 220.widthRatio)
            }
        }
    }
}

extension ProductVC {
    
    func getProductByCategory(param: [String: Any]) {
        guard objCategoryId != nil else {return}
        showHud()
        loadMore.isLoading = true
        KPWebCall.call.getProductsByCategory(param: param) { [weak self] (json, statusCode) in
            guard let weakself = self else {return}
            weakself.hideHud()
            weakself.loadMore.isLoading = false
            if statusCode == 200, let dict = json as? NSDictionary, let status = dict["Status"] as? Bool, status {
                if let jsonData = dict["Data"] as? NSDictionary, let arrProductData = jsonData["Products"] as? [NSDictionary]  {
                    if weakself.loadMore.index == 1 {
                        weakself.arrProducts = []
                    }
                    for productDict in arrProductData {
                        let objProduct = Product(dict: productDict)
                        weakself.arrProducts.append(objProduct)
                    }
                    if arrProductData.isEmpty {
                        weakself.loadMore.isAllLoaded = true
                    } else {
                        weakself.loadMore.index += 1
                    }
                }
                weakself.collectionView.reloadData()
            } else {
                weakself.showError(data: json, view: weakself.view)
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
                weakself.showError(data: json, view: weakself.view)
            }
        }
    }
}
