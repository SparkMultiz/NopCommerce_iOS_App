//
//  ProductDetailVC.swift
//  NopCommerce
//
//  Created by Jayesh on 10/03/20.
//  Copyright © 2020 Chirag Patel. All rights reserved.
//

import UIKit

class ProductDetailVC: ParentViewController {
    
    @IBOutlet weak var btnAddToCart: UIButton!
    @IBOutlet weak var btnWishList: UIButton!
    @IBOutlet weak var btmBtnConst: NSLayoutConstraint!
    @IBOutlet weak var btmBtnView: UIView!
    
    var productDetail: ProductDetail!
    var toolBar: ToolBarView!
    
    var arrReview: [Review]!
    var arrBoughtsProducts: [Product]!
    
    var wishOrCartId: String?
    var proId: String?
    var proName: String!
    
    var isFromCart: Bool!
    var isFromWishList: Bool!
    
    var dropDown = DropDown()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        getProductDetail()
    }
}

extension ProductDetailVC {
    
    func prepareUI() {
        lblHeaderTitle?.text = proName
        self.hideShowHomeTabbar(isHidden: true)
        prepareToolbar()
        setKeyboardNotifications()
    }
    
    func updateBottomView() {
        if productDetail.proType == .grouped {
            btmBtnView.isHidden = true
        } else {
            btmBtnView.isHidden = false
            btmBtnConst.constant = _bottomAreaSpacing + 44.0
            if isFromWishList != nil {
                btnWishList.setTitle(getLocalizedKey(str: "products.wishlist.addtowishlist.update"), for: .normal)
                btnWishList.setImage(nil, for: .normal)
            } else if isFromCart != nil {
                btnAddToCart.setTitle(getLocalizedKey(str: "shoppingcart.addtowishlist.update"), for: .normal)
                btnAddToCart.setImage(nil, for: .normal)
            } else {
                btnWishList.setTitle(" \(getLocalizedKey(str: "products.wishlist.addtowishlist"))  ", for: .normal)
                btnWishList.setImage( #imageLiteral(resourceName: "ic_Tab_Wishlist") , for: .normal)
                btnAddToCart.setTitle(productDetail.isRental ? getLocalizedKey(str: "shoppingcart.rent") : " \(getLocalizedKey(str: "shoppingcart.addtocart")) ", for: .normal)
                btnAddToCart.setImage(!productDetail.isRental ? #imageLiteral(resourceName: "Cart") : nil, for: .normal)
            }
        }
        let btmConst = productDetail.proType == .grouped ? 10 : _bottomAreaSpacing + 50.0
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: btmConst, right: 0)
    }
    
    func prepareToolbar(){
        toolBar = ToolBarView.instantiateViewFromNib()
        toolBar.handleTappedAction { [weak self] (tapped, toolbar) in
            self?.view.endEditing(true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailSegue" {
            let destVC = segue.destination as! ProductDetailVC
            if let data = sender as? Product {
                destVC.proName = data.name
                destVC.proId = data.id
            } else if let data = sender as? ProductDetail {
                destVC.proName = data.name
                destVC.proId = data.id
            }
        } else if segue.identifier == "addReviewSegue" {
            let destVC = segue.destination as! ReviewVC
            destVC.proId = self.proId
            destVC.proName = self.proName
            destVC.reviewBlock = {
                self.getProductReviews()
            }
        }
    }
    
    func getProductDetailCell(indexPath: IndexPath) -> ProductDetailTableCell? {
        let cell = tableView.cellForRow(at: indexPath) as? ProductDetailTableCell
        return cell
    }
    
    func getAttributeCell(row: Int, section: Int = 2) -> ProductAttributeCell? {
        let cell = tableView.cellForRow(at: IndexPath(row: row, section: section)) as? ProductAttributeCell
        return cell
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
    
    func popUpAlertForUnAvailableProduct(stock: BackInStockModel, proId: String) {
        let title = stock.alreadySubscriped ? getLocalizedKey(str: "backinstocksubscriptions.unsubscribe") : getLocalizedKey(str: "backinstocksubscriptions.notifyme")
        let msg = stock.alreadySubscriped ? getLocalizedKey(str: "backinstocksubscriptions.alreadysubscribed") : getLocalizedKey(str: "backinstocksubscriptions.tooltip")
        
        let alertController = UIAlertController(title: stock.title, message: msg, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: getLocalizedKey(str: "common.cancel"), style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: title, style: .default, handler: { (action) in
            self.notifyProduct(isSubscribed: stock.alreadySubscriped, proId: proId) { (completion) in
                let isSubscribed = stock.alreadySubscriped
                stock.alreadySubscriped = !isSubscribed
            }
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func openAlertForCamera() {
        let actionControl = UIAlertController(title: "Select Option", message: nil, preferredStyle: .actionSheet)
        actionControl.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action) in
            self.openGalleryCamera(with: .camera)
        }))
        actionControl.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action) in
            self.openGalleryCamera(with: .photoLibrary)
        }))
        actionControl.addAction(UIAlertAction(title: getLocalizedKey(str: "common.cancel"), style: .cancel, handler: nil))
        self.present(actionControl, animated: true, completion: nil)
    }
    
    func openGalleryCamera(with sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        picker.allowsEditing = true
        self.present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImg = info[.editedImage] as? UIImage {
            productDetail.selectedImg = pickedImg
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension ProductDetailVC {
    
    @IBAction func btnQuantityDropDownTapped(_ sender: UIButton) {
        configureDropDown(sender: sender)
        dropDown.dataSource.removeAll()
        dropDown.dataSource = productDetail.objCart!.arrQuantity.map{$0.text}
        dropDown.selectionAction = { [weak self] (index: Int, item: String) in
            guard let weakself = self else {return}
            weakself.productDetail.arrCartFields[sender.tag].text = item
            weakself.tableView.reloadData()
        }
        dropDown.show()
    }
    
    @IBAction func btnDropDownTapped(_ sender: UIButton) {
        configureDropDown(sender: sender)
        dropDown.dataSource.removeAll()
        dropDown.dataSource = productDetail.arrAttribues[sender.tag].arrAttributesValues.map{$0.priceValue}
        productDetail.arrAttribues[sender.tag].arrAttributesValues.forEach{$0.isPreSelected = false}
        dropDown.selectionAction = { [weak self] (index: Int, item: String) in
            guard let weakself = self else {return}
            weakself.productDetail.arrAttribues[sender.tag].arrAttributesValues[index].isPreSelected = true
            weakself.changeProductAttribute()
        }
        dropDown.show()
    }
    
    @IBAction func btnOpenDatePicker(_ sender: UIButton) {
        guard let idx = IndexPath.indexPathForCellContainingView(view: sender, inTableView: tableView) else {return}
        let currSection = idx.section
        self.view.endEditing(true)
       let picker = KPDatePicker.instantiateViewFromNib(withView: self.view)
        picker.datePicker.datePickerMode = .date
        if currSection == 3 && idx.row == 1 {
            picker.datePicker.minimumDate = Date.dateFromLocalFormat(from: self.productDetail.rentalStartDate)
        } else {
            picker.datePicker.minimumDate = Date()
        }
        picker.selectionBlock = { [weak self] (date) -> () in
            guard let weakself = self else {return}
            let strDate = currSection == 2 ? Date.localDateString(from: date, format: "yyyy/MMM/dd") : Date.localDateString(from: date, format: "MM/dd/yyyy")
            if currSection == 2 {
                weakself.productDetail.arrAttribues[idx.row].value = strDate
            } else {
                if sender.tag == 0 {
                    weakself.productDetail.rentalStartDate = strDate
                } else {
                    weakself.productDetail.rentalEndDate = strDate
                }
            }
            weakself.tableView.reloadData()
        }
    }
    
    @IBAction func tfEditingChange(_ textField: UITextField) {
        guard let idx = IndexPath.indexPathForCellContainingView(view: textField, inTableView: tableView) else {return}
        let currSection = idx.section
        let str = textField.text!.trimmedString()
        if currSection == 1 {
            productDetail.arrGiftCard[idx.row].text = str
        } else if currSection == 3 {
            productDetail.arrCartFields[idx.row].text = str
        } else {
            productDetail.arrAttribues[idx.row].value = str
        }
    }
}

extension ProductDetailVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    @IBAction func btnAddToWishListAndCartTapped(_ sender: UIButton) {
        guard proId != nil else {return}
        self.moveToCartAndWishList(isCart: sender.tag == 0)
//        let validate = productDetail.validatetData()
//        if validate.isValid {
//            self.moveToCartAndWishList(isCart: sender.tag == 0)
//            self.postWishList()
//        } else {
//           JTValidationToast.show(message: validate.error)
//        }
    }
    
    @IBAction func btnAddReviewTapped(_ sender: UIButton) {
        if _user.isGuestLogin {
           JTValidationToast.show(message: getLocalizedKey(str: "blog.comments.onlyregisteredusersleavecomments"))
        } else {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "addReviewSegue", sender: nil)
            }
        }
    }
    
    @IBAction func btnDownloadNotifyTapped(_ sender: UIButton) {
        if productDetail.displayBackInStockSubscription, let stock = productDetail.objStock {
            self.popUpAlertForUnAvailableProduct(stock: stock, proId: productDetail.id)
        } else if productDetail.hasSampleDownload {
            
        }
    }
    
    @IBAction func btnUploadFile(_ sender: UIButton) {
        openAlertForCamera()
    }
    
    @IBAction func btnShareProduct(_ sender: UIButton) {
        let shareUrl = "http://xitstaging-001-site8.mysitepanel.net/\(productDetail.seName)"
        let title = _appName
        guard shareUrl.isValidURL() else {return}
        let arrShare: [Any] =  [shareUrl]
        let activityVC = UIActivityViewController(activityItems: arrShare, applicationActivities: nil)
        activityVC.setValue(title, forKey: "Subject")
        self.present(activityVC, animated: true, completion: nil)
    }
}

extension ProductDetailVC {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return productDetail == nil ? 0 : arrReview == nil ? 10 : arrBoughtsProducts == nil ? 11 : 12
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return productDetail.isFreeShipping ? 3 : 2
        } else if section == 1 {
            return productDetail.isGiftCard ? productDetail.arrGiftCard.count : 0
        } else if section == 2 {
            return productDetail.arrAttribues.count
        } else if section == 3 {
            return productDetail.arrCartFields.count
        } else if section == 4 {
            return productDetail.fullDesc.isEmpty ? 0 : 1
        } else if section == 5 {
            return productDetail.getProductInfo().count
        } else if section == 6 {
            return productDetail.arrSpecification.count
        } else if section == 7 {
            return 1
        } else if section == 8 {
            return productDetail.arrAssociatedProduct.count
        } else if section == 9 {
            return 1
        } else if section == 10 {
            return arrReview.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return (section == 7 && !productDetail.arrTierPrice.isEmpty) || (section == 11 && !arrBoughtsProducts.isEmpty) ? 50.widthRatio : (section == 6 && !productDetail.arrSpecification.isEmpty) ? 40.widthRatio : (section == 2 && !productDetail.arrAttribues.isEmpty) || (section == 1 && !productDetail.arrGiftCard.isEmpty) ? 10.widthRatio : section == 10 ? 65.widthRatio : 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard (section == 1 && !productDetail.arrGiftCard.isEmpty) || (section == 2 && !productDetail.arrAttribues.isEmpty) || (section == 6 && !productDetail.arrSpecification.isEmpty) || (section == 7 && !productDetail.arrTierPrice.isEmpty) || (section == 11 && !arrBoughtsProducts.isEmpty) || section == 10 else {return nil}
        if section == 10 {
            let reviewView = tableView.dequeueReusableCell(withIdentifier: "reviewHeader") as! ReviewHeaderCell
            reviewView.lblHeaderTitle.text = getLocalizedKey(str: "reviews")
            reviewView.reviewView.isHidden = !productDetail.objReview!.isReviewGiven
            if !reviewView.reviewView.isHidden {
                reviewView.reviewView.rating = productDetail.objReview!.avgSum
            }
            return reviewView.contentView
        } else {
            let headerView = tableView.dequeueReusableCell(withIdentifier: "headerCell") as! TableHeaderCell
            headerView.setHeaderUI(section: section)
            return headerView.contentView
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return indexPath.row == 0 ? 200.widthRatio : UITableView.automaticDimension
        } else if indexPath.section == 1 {
            let fieldType = productDetail.arrGiftCard[indexPath.row].fieldType
            return productDetail.isGiftCard ? fieldType == .textField ? 80.widthRatio : fieldType.cellHeight : 0
        } else if indexPath.section == 2 {
            let objAttri = self.productDetail.arrAttribues
            let objSubAttri = objAttri[indexPath.row].arrAttributesValues
            return objSubAttri == nil || !objSubAttri!.isEmpty ? objAttri[indexPath.row].controlType.cellHeight : 0
        } else if indexPath.section == 3 {
            let objCartData = productDetail.arrCartFields[indexPath.row]
            return objCartData.fieldType == .dobCell ? objCartData.text.isEmpty ? 70.widthRatio : 100.widthRatio : 75.widthRatio
        } else if indexPath.section == 4 {
            return productDetail.fullDesc.isEmpty ? 0 : UITableView.automaticDimension
        } else if indexPath.section == 5 {
            return productDetail.getProductInfo()[indexPath.row].footer.isEmpty ? 0 : UITableView.automaticDimension
        } else if indexPath.section == 6 {
            return productDetail.arrSpecification.isEmpty ? 0 : 40.widthRatio
        } else if indexPath.section == 7 {
            return productDetail.arrTierPrice.isEmpty ? 0 : 80.widthRatio
        } else if indexPath.section == 8 {
            return productDetail.arrAssociatedProduct.isEmpty ? 0 : UITableView.automaticDimension
        } else if indexPath.section == 9 {
            return productDetail.arrTags.isEmpty ? 0 : 100.widthRatio
        } else if indexPath.section == 10 {
            return arrReview.isEmpty ? 0 : UITableView.automaticDimension
        } else {
            return arrBoughtsProducts.isEmpty ? 0 : 220.widthRatio
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell: ProductDetailTableCell
            let cellId = indexPath.row == 0 ? "productCell" : indexPath.row == 1 ? "descCell" : "freeShipCell"
            cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ProductDetailTableCell
            cell.parent = self
            cell.prepareProductDetailUI(idx: indexPath)
            return cell
        } else if indexPath.section == 1 {
            let cell: ProductAttributeCell
            let userField = self.productDetail.arrGiftCard[indexPath.row]
            cell = tableView.dequeueReusableCell(withIdentifier: userField.fieldType.rawValue, for: indexPath) as! ProductAttributeCell
            cell.parent = self
            cell.currSection = indexPath.section
            cell.tag = indexPath.row
            cell.prepareGiftCardUI(field: userField)
            return cell
        } else if indexPath.section == 2 {
            let cell: ProductAttributeCell
            let cellId = productDetail.arrAttribues[indexPath.row].controlType.cellIdentifier
            guard !cellId.isEmpty else { return UITableViewCell() }
            cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ProductAttributeCell
            cell.parent = self
            cell.currSection = indexPath.section
            cell.tag = indexPath.row
            cell.objAttribute = productDetail.arrAttribues[indexPath.row]
            cell.prepareProductAttributeUI()
            return cell
        } else if indexPath.section == 3 {
            let cell: ProductAttributeCell
            let objCartFields = productDetail.arrCartFields[indexPath.row]
            let isProductRental = objCartFields.fieldType == .dobCell
            let cellId = isProductRental ? "rentalDateCell" : "txtCell"
            cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ProductAttributeCell
            cell.parent = self
            cell.currSection = indexPath.section
            cell.tag = indexPath.row
            cell.prepareFields(field: objCartFields, detail: productDetail)
            return cell
        } else if indexPath.section == 4 {
            let cell: ProductDetailTableCell
            cell = tableView.dequeueReusableCell(withIdentifier: "proDesc", for: indexPath) as! ProductDetailTableCell
            cell.lblInfoHeader.text = "PRODUCT DESCRIPTION"
            cell.lblProductDescription.attributedText = productDetail.attributeFullDesc
            return cell
        } else if indexPath.section == 5 {
            let cell: ProductDetailTableCell
            let info = productDetail.getProductInfo()[indexPath.row]
            let cellId = info.header.isEmpty ? "downloadNotifyCell" : "infoCell"
            cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ProductDetailTableCell
            if cellId.isEqual(str: "infoCell") {
                cell.lblInfoHeader.text = info.header
                cell.lblInfoFooter.text = info.footer
            } else {
                cell.imgDownloadNotifyView.image = productDetail.hasSampleDownload ? #imageLiteral(resourceName: "download-blk") : #imageLiteral(resourceName: "email")
                cell.lblDownloadNotify.text = info.footer
            }
            return cell
        } else if indexPath.section == 6 {
            let cell: ProductDetailTableCell
            cell = tableView.dequeueReusableCell(withIdentifier: "specsCell", for: indexPath) as! ProductDetailTableCell
            cell.parent = self
            cell.prepareSpecsUI(idx: indexPath)
            return cell
        } else if indexPath.section == 7 {
            let cell: ProductDetailTableCell
            cell = tableView.dequeueReusableCell(withIdentifier: "tierCell", for: indexPath) as! ProductDetailTableCell
            cell.parent = self
            if !productDetail.arrTierPrice.isEmpty {
                cell.collType = .tier
                cell.tierCollView.reloadData()
            }
            return cell
        } else if indexPath.section == 8 {
            let cell: ProductAssociatedCell
            cell = tableView.dequeueReusableCell(withIdentifier: "associatedCell", for: indexPath) as! ProductAssociatedCell
            cell.parent = self
            cell.tag = indexPath.row
            cell.prepareAssociatedUI(data: productDetail.arrAssociatedProduct[indexPath.row])
            return cell
        } else if indexPath.section == 9 {
            let cell: ProductDetailTableCell
            cell = tableView.dequeueReusableCell(withIdentifier: "tagCell", for: indexPath) as! ProductDetailTableCell
            cell.parent = self
            if !productDetail.arrTags.isEmpty {
                cell.collType = .tag
                cell.tagCollView.reloadData()
            }
            cell.lblInfoHeader.text = getLocalizedKey(str: "products.tags")
            return cell
        } else if indexPath.section == 10 {
            let cell: ProductDetailTableCell
            cell = tableView.dequeueReusableCell(withIdentifier: "reviewCell", for: indexPath) as! ProductDetailTableCell
            cell.parent = self
            cell.prepareReviewUI(idx: indexPath)
            return cell
        } else {
            let cell: ProductDetailTableCell
            cell = tableView.dequeueReusableCell(withIdentifier: "boughtProductCell", for: indexPath) as! ProductDetailTableCell
            cell.parent = self
            if !arrBoughtsProducts.isEmpty {
                cell.collType = .bought
                cell.boughtCollView.reloadData()
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == tableView.numberOfSections - 1 else {return}
        DispatchQueue.main.async {
            guard !self.productDetail.arrAssociatedProduct.isEmpty else {return}
            let objProduct = self.productDetail.arrAssociatedProduct[indexPath.row]
            self.performSegue(withIdentifier: "detailSegue", sender: objProduct)
        }
    }
}

extension ProductDetailVC {
    
    func getProductDetail() {
        guard proId != nil else {return}
        showHud()
        var param: [String: Any] = ["ApiSecretKey":secretKey, "CustomerGUID":_user.guid, "StoreId": storeId, "CurrencyId": currencyId, "LanguageId": languageId, "ProductId": proId!]
        if let cartItemId = wishOrCartId {
            param["UpdateCartItemId"] = cartItemId
        }
        KPWebCall.call.getProductsDetails(param: param) { [weak self] (json, statusCode) in
            guard let weakself = self else {return}
            if statusCode == 200, let dict = json as? NSDictionary, let status = dict["Status"] as? Bool, status {
                if let jsonData = dict["Data"] as? NSDictionary {
                    weakself.productDetail = ProductDetail(dict: jsonData)
                }
                weakself.updateBottomView()
                weakself.changeProductAttribute()
                weakself.getProductReviews()
            } else {
                weakself.showError(data: json, view: weakself.view)
            }
        }
    }
    
    func getProductReviews() {
        guard proId != nil else {return}
        let param: [String: Any] = ["ApiSecretKey":secretKey, "CustomerGUID":_user.guid, "StoreId": storeId, "LanguageId": languageId, "ProductId": proId!]
        KPWebCall.call.getProductReviews(param: param) { [weak self] (json, statusCode) in
            guard let weakself = self else {return}
            weakself.arrReview = []
            if statusCode == 200, let dict = json as? NSDictionary, let status = dict["Status"] as? Bool, status {
                if let jsonData = dict["Data"] as? NSDictionary, let allReviews = jsonData["Items"] as? [NSDictionary] {
                    for reviewDict in allReviews {
                        let objReview = Review(dict: reviewDict)
                        weakself.arrReview.append(objReview)
                    }
                }
                weakself.tableView.reloadData()
                weakself.getRelatedBoughtProducts()
            } else {
                weakself.showError(data: json, view: weakself.view)
            }
        }
    }
    
    func getRelatedBoughtProducts() {
        guard proId != nil else {return}
        let param: [String: Any] = ["ApiSecretKey":secretKey, "CurrencyId": currencyId, "StoreId": storeId, "LanguageId": languageId, "ProductId": proId!]
        KPWebCall.call.getRelatedProductBought(param: param) { [weak self] (json, statusCode) in
            guard let weakself = self else {return}
            weakself.arrBoughtsProducts = []
            if statusCode == 200, let dict = json as? NSDictionary, let status = dict["Status"] as? Bool, status {
                if let arrProductData = dict["Data"] as? [NSDictionary] {
                    for productDict in arrProductData {
                        let objProduct = Product(dict: productDict)
                        weakself.arrBoughtsProducts.append(objProduct)
                    }
                }
                weakself.tableView.reloadData()
            }
        }
    }
    
    func notifyProduct(isSubscribed: Bool, proId: String, completion: @escaping(Bool) -> ()) {
        showHud()
        let param: [String: Any] = ["ApiSecretKey":secretKey,"CustomerGUID": _user.guid,"StoreId": storeId, "ProductIds": [proId]]
        let relPath = isSubscribed ? "BackInStockUnsubscribe" : "BackInStockSubscribe"
        KPWebCall.call.notifyStockProduct(strPath: relPath, param: param) { [weak self] (json, statusCode) in
            guard let weakself = self else {return}
            weakself.hideHud()
            if statusCode == 200, let dict = json as? NSDictionary, let status = dict["Status"] as? Bool, status {
                if let jsonData = dict["Data"] as? NSDictionary {
                    completion(true)
                    weakself.showSuccessMsg(data: jsonData, view: weakself.view)
                }
            } else {
                weakself.showError(data: json, view: weakself.view)
            }
        }
    }
    
    func addToWishListCart(with id: String, isCart: Bool, qty: String) {
        let param: [String: Any] = ["ApiSecretKey":secretKey,"CustomerGUID": _user.guid,"StoreId": storeId, "CurrencyId": currencyId, "ShoppingCartTypeId": isCart ? "1" : "2", "Quantity": qty, "ProductId": id]
        showHud()
        KPWebCall.call.addToCartAndWishList(param: param) { [weak self] (json, statusCode) in
            guard let weakself = self else {return}
            weakself.hideHud()
            if statusCode == 200, let dict = json as? NSDictionary, let status = dict["Status"] as? Bool, status {
                if let jsonData = dict["Data"] as? NSDictionary {
                    weakself.showSuccessMsg(data: jsonData, view: weakself.view)
                    if isCart {
                        weakself.postCart()
                    } else {
                        weakself.postWishList()
                    }
                }
            } else {
                weakself.showError(data: json, view: weakself.view)
            }
        }
    }
    
    
    func changeProductAttribute() {
        showHud()
        let params: [String: Any] = productDetail.changeAttriDict()
        KPWebCall.call.changeProductAttribute(param: params) { [weak self] (json, statusCode) in
            guard let weakself = self else {return}
            weakself.hideHud()
            if statusCode == 200, let dict = json as? NSDictionary, let status = dict["Status"] as? Bool, status {
                if let jsonData = dict["Data"] as? NSDictionary {
                    let price = jsonData.getStringValue(key: "Price")
                    weakself.productDetail.objPrice?.price = price
                    weakself.tableView.reloadData()
                }
            } else {
                weakself.showError(data: json, view: weakself.view)
            }
        }
    }
    
    
    func moveToCartAndWishList(isCart: Bool) {
        showHud()
        var params: [String: Any] = productDetail.paramDict(isCart: isCart)
        if let cartItemId = wishOrCartId {
            params["UpdateCartItemId"] = cartItemId
        }
        KPWebCall.call.addProductToCartAndWishList(param: params) { [weak self] (json, statusCode) in
            guard let weakself = self else {return}
            weakself.hideHud()
            if statusCode == 200, let dict = json as? NSDictionary, let status = dict["Status"] as? Bool, status {
                if let jsonData = dict["Data"] as? NSDictionary {
                    weakself.showSuccMsg(dict: jsonData)
                    if isCart {
                        weakself.postCart()
                    } else {
                        weakself.postWishList()
                    }
                }
            } else {
                weakself.showError(data: json, view: weakself.view)
            }
        }
    }
}
