//
//  CartTableCell.swift
//  NopCommerce
//
//  Created by Chirag Patel on 11/03/20.
//  Copyright © 2020 Chirag Patel. All rights reserved.
//

import UIKit

class CartTableCell: ConstrainedTableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tfInputField: UITextField!
    @IBOutlet weak var btn: UIButton!
        
    @IBOutlet weak var lblCountry: UILabel!
    @IBOutlet weak var lblState: UILabel!
    
    @IBOutlet weak var lblOrderTotal: UILabel!
    @IBOutlet weak var lblOrderTax: UILabel!
    @IBOutlet weak var lblOrderSubTotal: UILabel!
    @IBOutlet weak var lblOrderDelivery: UILabel!
    @IBOutlet weak var lblOrderEarn: UILabel!
    @IBOutlet weak var lblOrderPayable: UILabel!
    
    @IBOutlet weak var lblOrderTotalTitle: UILabel!
    @IBOutlet weak var lblOrderTaxTitle: UILabel!
    @IBOutlet weak var lblOrderSubTotalTitle: UILabel!
    @IBOutlet weak var lblOrderDeliveryTitle: UILabel!
    @IBOutlet weak var lblOrderEarnTitle: UILabel!
    @IBOutlet weak var lblOrderPayableTitle: UILabel!
    
    @IBOutlet weak var lblShippingName: UILabel!
    @IBOutlet weak var lblShippingDesc: UILabel!
    
    @IBOutlet weak var lblCountryTitle: UILabel!
    @IBOutlet weak var lblProvinceTitle: UILabel!
    @IBOutlet weak var lblPostalTitle: UILabel!

    @IBOutlet weak var tickImgView: UIImageView!
    
    var currSection: Int!
    weak var parent: CartVC!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func preparePaymentSumary(data: OrderTotal) {
        lblOrderTotalTitle.text = getLocalizedKey(str: "checkout.placedorderdetails")
        lblOrderSubTotalTitle.text = getLocalizedKey(str: "messages.order.subtotal")
        lblOrderTaxTitle.text = getLocalizedKey(str: "messages.order.tax")
        lblOrderDeliveryTitle.text = "Delivery"
        lblOrderEarnTitle.text = getLocalizedKey(str: "shoppingcart.totals.rewardpoints.willearn")
        lblOrderPayableTitle.text = "Total Payable"
        
        lblOrderTotal.text = data.orderTotal
        lblOrderSubTotal.text = data.subTotal
        lblOrderTax.text = data.estimatedTax
        lblOrderDelivery.text = data.shipping
        lblOrderEarn.text = "\(data.rewardPoints) \(getLocalizedKey(str: "rewardpoints.fields.points"))"
        lblOrderPayable.text = data.orderTotal
    }
    
    func prepareShippingUI(data: ShippingOption) {
        lblShippingName.text = data.name
        lblShippingDesc.text = data.desc
    }
    
    func configureTermsAndCondition() {
        let text = NSMutableAttributedString(string: getLocalizedKey(str: "checkout.termsofservice.iaccept"))
        text.addAttribute(NSAttributedString.Key.font,
                          value: UIFont.systemFont(ofSize: 16.widthRatio),
                          range: NSRange(location: 0, length: text.length))
        
        let interactableText = NSMutableAttributedString(string: getLocalizedKey(str: "checkout.termsofservice.read"))
        interactableText.addAttributes([.foregroundColor: UIColor.blue, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15.widthRatio)], range: NSRange(location: 1, length: interactableText.length - 2))
                
        text.append(interactableText)
        lblTitle.attributedText = text
    }
    
    func prepareOffersUI(field: UserField) {
        lblTitle.text = field.title
        btn.setTitle(field.key.uppercased(), for: .normal)
        tfInputField.inputAccessoryView = nil
        tfInputField.returnKeyType = field.keyBoardReturnKey
        tfInputField.placeholder = field.placeholder
        tfInputField.text = field.text
        tickImgView.image = field.image
    }
    
    func prepareEstimateShipping(country: Country, province: Province?) {
        lblCountryTitle.text = getLocalizedKey(str: "shoppingcart.estimateshipping.country")
        lblProvinceTitle.text = getLocalizedKey(str: "shoppingcart.estimateshipping.stateprovince")
        lblPostalTitle.text = getLocalizedKey(str: "shoppingcart.estimateshipping.zippostalcode")
        lblCountry.text = country.name
        lblState.text = province == nil ? getLocalizedKey(str: "address.othernonus") : province!.name
        tfInputField.inputAccessoryView = parent.toolBar
        tfInputField.text = parent.objCart.zipCode
    }
}

extension CartTableCell: UITextFieldDelegate {
    
    @IBAction func tfEditingChange(_ textField: UITextField) {
        let str = textField.text!.trimmedString()
        if currSection == 2 {
            parent.objCart.arrOffersFields[self.tag].text = str
        } else {
            parent.objCart.zipCode = str
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
