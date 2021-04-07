//
//  ProductAssociatedCell.swift
//  NopCommerce
//
//  Created by Jayesh on 23/03/20.
//  Copyright © 2020 Chirag Patel. All rights reserved.
//

import UIKit

class ProductAssociatedCell: ConstrainedTableViewCell {
    
    @IBOutlet weak var imgProductView: UIImageView!
    @IBOutlet weak var lblProductTitle: UILabel!
    @IBOutlet weak var lblProductSku: UILabel!
    @IBOutlet weak var lblProductAvailability: UILabel!
    @IBOutlet weak var lblProductPrice: UILabel!
    @IBOutlet weak var lblNotifyMessage: UILabel!
    @IBOutlet weak var tfQuantity: UITextField!
    @IBOutlet weak var associatedStackView: UIStackView!
    @IBOutlet weak var stackConst: NSLayoutConstraint!
    
    @IBOutlet weak var dropDownView: UIView!
    @IBOutlet weak var lblQuantity: UILabel!
    @IBOutlet weak var btnDropDown: UIButton!
    
    weak var parent: ProductDetailVC!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func prepareAssociatedUI(data: ProductDetail) {
        imgProductView.kf.indicatorType = .activity
        imgProductView.kf.setImage(with: data.objPictureModel?.imgUrl)
        lblProductTitle.text = data.name
        lblProductSku.text = "\(getLocalizedKey(str: "products.sku")) \(data.sku)"
        lblProductPrice.text = data.objPrice?.price
        
        if !data.stockAvailabitity.isEmpty {
            lblProductAvailability.text = "\(getLocalizedKey(str: "products.availability")) \(data.stockAvailabitity)"
        } else {
            lblProductAvailability.text = getLocalizedKey(str: "products.availability")
        }
        if data.displayBackInStockSubscription, let stock = data.objStock {
            self.associatedStackView.subviews[0].isHidden = false
            self.stackConst.constant = 80.0
            layoutIfNeeded()
            lblNotifyMessage.text = stock.title
        } else {
            self.associatedStackView.subviews[0].isHidden = true
            self.stackConst.constant = 40.0
            layoutIfNeeded()
        }
                
        if let cart = data.objCart, !cart.arrQuantity.isEmpty {
            tfQuantity.isHidden = true
            dropDownView.isHidden = false
            btnDropDown.tag = self.tag
            let selectedVal = cart.arrQuantity.filter{$0.isSelected}.first
            lblQuantity.text = selectedVal == nil ? cart.arrQuantity[0].value : selectedVal!.value
        } else {
            dropDownView.isHidden = true
            tfQuantity.isHidden = false
            tfQuantity.tag = self.tag
            tfQuantity.inputAccessoryView = parent.toolBar
            tfQuantity.text = data.strQuantity
        }
    }
}

extension ProductAssociatedCell {
    
    @IBAction func btnDropDownTapped(_ sender: UIButton) {
        parent.configureDropDown(sender: sender)
        parent.dropDown.dataSource.removeAll()
        parent.dropDown.dataSource = parent.productDetail.arrAssociatedProduct[sender.tag].objCart!.arrQuantity.map{$0.text}
        parent.productDetail.arrAssociatedProduct[sender.tag].objCart!.arrQuantity.forEach{$0.isSelected = false}
        parent.dropDown.selectionAction = { [weak self] (index: Int, item: String) in
            guard let weakself = self else {return}
            weakself.parent.productDetail.arrAssociatedProduct[sender.tag].objCart!.arrQuantity[index].isSelected = true
            weakself.parent.tableView.reloadData()
        }
        parent.dropDown.show()
    }
    
    @IBAction func btnMoveToWishListCart(_ sender: UIButton) {
        let isCart = sender.tag == 0
        let objAssociateProduct = parent.productDetail.arrAssociatedProduct[self.tag]
        let qty = objAssociateProduct.objCart!.arrQuantity.isEmpty ? objAssociateProduct.strQuantity : objAssociateProduct.objCart?.arrQuantity.filter{$0.isSelected}.first?.value
        guard let quantity = qty, Int(quantity) ?? 0 > 0 else {
           JTValidationToast.show(message: "Minimum Quantity must be 1")
            return
        }
        parent.addToWishListCart(with: objAssociateProduct.id, isCart: isCart, qty: quantity)
    }
    
    @IBAction func btnSubcribeUnSubscribeStockTapped(_ sender: UIButton) {
        let objProduct = parent.productDetail.arrAssociatedProduct[self.tag]
        guard let objStock = objProduct.objStock else {return}
        parent.popUpAlertForUnAvailableProduct(stock: objStock, proId: objProduct.id)
    }
}

extension ProductAssociatedCell: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func tfEditingChange(_ textField: UITextField) {
        let str = textField.text!.trimmedString()
        parent.productDetail.arrAssociatedProduct[self.tag].strQuantity = str
    }
}
