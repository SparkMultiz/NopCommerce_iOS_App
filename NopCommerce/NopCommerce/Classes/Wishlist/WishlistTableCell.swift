//
//  WishlistTableCell.swift
//  NopCommerce
//
//  Created by Chirag Patel on 07/03/20.
//  Copyright © 2020 Chirag Patel. All rights reserved.
//

import UIKit

class WishlistTableCell: ConstrainedTableViewCell {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblProductTitle: UILabel!
    @IBOutlet weak var lblProductSku: UILabel!
    @IBOutlet weak var lblProductDesc: UILabel!
    @IBOutlet weak var lblProductSubPrice: UILabel!
    @IBOutlet weak var lblProductUnitPrice: UILabel!
    
    @IBOutlet weak var dropDownView: UIView!
    @IBOutlet weak var btnEditProduct: UIButton!
    @IBOutlet weak var tfQuantity: UITextField!
    @IBOutlet weak var lblQuantity: UILabel!
    @IBOutlet weak var btnDropDown: UIButton!
    @IBOutlet weak var lblQuantityTitle: UILabel!
    @IBOutlet weak var btnRemove: UIButton?
    @IBOutlet weak var btnMoveToWishList: UIButton?
    
    weak var parent: UIViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func prepareWishListUI(data: WishList) {
        imgView.kf.indicatorType = .activity
        imgView.kf.setImage(with: data.pictureModel?.imgUrl)
        lblProductTitle.text = data.proName
        lblProductSku.text = "\(getLocalizedKey(str: "products.sku")) \(data.sku)"
        lblProductDesc.text = data.attributeInfo
        lblProductSubPrice.text = "\(getLocalizedKey(str: "shoppingcart.totals.subtotal")) \(data.subTotal)"
        lblProductUnitPrice.text = "\(getLocalizedKey(str: "shoppingcart.mini.unitprice")) \(data.unitPrice)"
        btnEditProduct.isHidden = !data.allowItemEditing
        dropDownView.isHidden = data.arrQuantity.isEmpty
        tfQuantity.isHidden = !data.arrQuantity.isEmpty
        lblQuantityTitle.text = "\(getLocalizedKey(str: "products.qty"))"
        if data.arrQuantity.isEmpty {
            tfQuantity.tag = self.tag
            if let parentVC = parent as? CartVC {
                tfQuantity.inputAccessoryView = parentVC.toolBar
            } else if let parentVC = parent as? WishListVC {
                tfQuantity.inputAccessoryView = parentVC.toolBar
            }
            tfQuantity.isUserInteractionEnabled = data.allowItemEditing
            tfQuantity.textColor = data.allowItemEditing ? #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) : #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
            tfQuantity.layer.borderWidth = 1.0
            tfQuantity.layer.borderColor = data.allowItemEditing ? #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).cgColor : #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1).cgColor
            tfQuantity.text = "\(data.quantity)"
        } else {
            btnDropDown.tag = self.tag
            lblQuantity.text = "\(data.quantity)"
        }
        btnRemove?.setTitle(" \(getLocalizedKey(str: "shoppingcart.remove")) ", for: .normal)
        btnMoveToWishList?.setTitle(" \(getLocalizedKey(str: "shoppingcart.addtowishlist")) ", for: .normal)
    }
    
    func prepareOrderDetailUI(data: WishList) {
        if let imageVW = self.imgView {
            imageVW.kf.indicatorType = .activity
            imageVW.kf.setImage(with: data.pictureModel?.imgUrl, placeholder: _placeImage)
        }
        lblProductTitle.text = data.proName
        lblProductSku.text = "\(getLocalizedKey(str: "products.sku")) \(data.sku)"
        lblQuantity.text = "\(getLocalizedKey(str: "products.qty")) \(data.quantity)"
        lblProductUnitPrice.text = "\(data.unitPrice)"
    }
}

extension WishlistTableCell: UITextFieldDelegate {
    
    @IBAction func tfEditingChange(_ textField: UITextField) {
        let strText = textField.text!.trimmedString()
        if let parentVC = parent as? WishListVC {
            parentVC.arrWishList[tfQuantity.tag].quantity = strText.integerValue ?? 0
        } else if let parentVC = parent as? CartVC {
            parentVC.objCart.arrItems[tfQuantity.tag].quantity = strText.integerValue ?? 0
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        tfQuantity.resignFirstResponder()
        return true
    }
}


class WishListFooterCell: ConstrainedTableViewCell {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblTitle2: UILabel!
    @IBOutlet weak var btnUpdateShoppingCart: UIButton!
    @IBOutlet weak var btnContinueShopping: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func prepareWishlistBtnUI() {
        btnUpdateShoppingCart.setTitle(getLocalizedKey(str: "wishlist.updatecart"), for: .normal)
        btnContinueShopping.setTitle(getLocalizedKey(str: "wishlist.emailafriend"), for: .normal)
        
    }
    
    func prepareBtnUI() {
        btnUpdateShoppingCart.setTitle(getLocalizedKey(str: "shoppingcart.updatecart"), for: .normal)
        btnContinueShopping.setTitle(getLocalizedKey(str: "shoppingcart.continueshopping"), for: .normal)
    }
    
    func prepareFooter() {
        lblTitle2.text = getLocalizedKey(str: "wishlist.yourwishlisturl")
        lblTitle.text = "http://demo.nopcommerce.com/wishlist/\(_user.guid)"
    }
}
