//
//  Cart.swift
//  NopCommerce
//
//  Created by Jayesh on 27/03/20.
//  Copyright © 2020 Chirag Patel. All rights reserved.
//

import Foundation

class Cart {
    
    // BOOl
    let onePageCheckOutEnable: Bool
    let showSku: Bool
    let showProductImages: Bool
    let showEstimateShipping: Bool
    let isEditable: Bool
    let showTermsOnCart: Bool
    let showTermsOnConfirm: Bool
    let displayTaxShippingInfo: Bool
    let displayTax: Bool
    let displayTaxRates: Bool
    let isApplied: Bool
    
    //String
    var checkOutAttriInfo: String
    let minSubTotalWarning: String
    let taxRates: String
    let tax: String
    var zipCode: String = ""
    
    var arrItems: [WishList] = []
    var arrAttribues: [ProductAttributes] = []
    var arrOffersFields: [UserField] = []
    
    var objDiscountBox: CartOffers?
    var objGiftCardBox: CartOffers?
    
    var isApplyCoupanShown: Bool {
        return objDiscountBox?.isDisplay ?? false
    }
    
    var isGiftCardShown: Bool {
        return objGiftCardBox?.isDisplay ?? false
    }
    
    var attributeInfo: String {
        return checkOutAttriInfo.replace("<br />", replacement: "\n")
    }
    
    func prepareCartOffers() {
        if isApplyCoupanShown {
            var t1 = UserField()
            t1.title = getLocalizedKey(str: "shoppingcart.discountcouponcode")
            t1.key = t1.isSelected ? "Remove Coupan" : getLocalizedKey(str: "shoppingcart.discountcouponcode.button")
            t1.placeholder = getLocalizedKey(str: "shoppingcart.discountcouponcode.tooltip")
            t1.image = #imageLiteral(resourceName: "offer")
            t1.keyBoardReturnKey = .done
            arrOffersFields.append(t1)
        }
        
        if isGiftCardShown {
            var t2 = UserField()
            t2.title = getLocalizedKey(str: "shoppingcart.giftcardcouponcode")
            t2.key = t2.isSelected ? "Remove Gift Card" : getLocalizedKey(str: "shoppingcart.giftcardcouponcode")
            t2.placeholder = getLocalizedKey(str: "shoppingcart.giftcardcouponcode.tooltip")
            t2.image = #imageLiteral(resourceName: "GiftCard")
            t2.keyBoardReturnKey = .done
            arrOffersFields.append(t2)
        }
    }
    
    func validatetData() -> (isValid: Bool, error: String) {
        var result = (isValid: true, error: "")
        
        for attri in self.arrAttribues {
            if attri.controlType == .txtField || attri.controlType == .txtView || attri.controlType == .datePicker {
                if String.validateStringValue(str: attri.value) {
                    result.isValid = false
                    result.error = "Please enter \(attri.name)"
                    return result
                }
            }
        }
        return result
    }
    
    init(dict: NSDictionary) {
        onePageCheckOutEnable = dict.getBooleanValue(key: "OnePageCheckoutEnabled")
        showSku = dict.getBooleanValue(key: "ShowSku")
        showProductImages = dict.getBooleanValue(key: "ShowProductImages")
        showEstimateShipping = dict.getBooleanValue(key: "ShowEstimateShipping")
        isEditable = dict.getBooleanValue(key: "IsEditable")
        showTermsOnCart = dict.getBooleanValue(key: "TermsOfServiceOnShoppingCartPage")
        showTermsOnConfirm = dict.getBooleanValue(key: "TermsOfServiceOnOrderConfirmPage")
        displayTaxShippingInfo = dict.getBooleanValue(key: "DisplayTaxShippingInfo")
        displayTax = dict.getBooleanValue(key: "DisplayTax")
        displayTaxRates = dict.getBooleanValue(key: "DisplayTaxRates")
        isApplied = dict.getBooleanValue(key: "IsApplied")
        
        checkOutAttriInfo = dict.getStringValue(key: "CheckoutAttributeInfo")
        minSubTotalWarning = dict.getStringValue(key: "MinOrderSubtotalWarning")
        taxRates = dict.getStringValue(key: "TaxRates")
        tax = dict.getStringValue(key: "Tax")
        
        if let arrAllItems = dict["Items"] as? [NSDictionary] {
            for itemDict in arrAllItems {
                let objItem = WishList(dict: itemDict)
                self.arrItems.append(objItem)
            }
        }
        
        if let allAttrubutes = dict["CheckoutAttributes"] as? [NSDictionary] {
            for attriDict in allAttrubutes {
                let objAtttribute = ProductAttributes(dict: attriDict)
                self.arrAttribues.append(objAtttribute)
            }
        }
        
        if let discountDict = dict["DiscountBox"] as? NSDictionary {
            self.objDiscountBox = CartOffers(dict: discountDict)
        }
        
        if let giftDict = dict["GiftCardBox"] as? NSDictionary {
            self.objGiftCardBox = CartOffers(dict: giftDict)
        }
        
        self.prepareCartOffers()
    }
}

class CartOffers {
    
    let isDisplay: Bool
    let message: String
    let currCode: String
    
    init(dict: NSDictionary) {
        isDisplay = dict.getBooleanValue(key: "Display")
        message = dict.getStringValue(key: "Message")
        currCode = dict.getStringValue(key: "CurrentCode")
    }
}

class OrderTotal {
    
    let orderTotal: String
    let subTotal: String
    let rewardPoints: Int
    let estimatedTax: String
    let shipping: String
    
    //var arrTax: [TaxRate] = []
//    var totalTax: Double {
//        return arrTax.map{$0.taxValue}.reduce(.zero, +)
//    }
    
    var isShippingFree: Bool {
        let shipRate = shipping.doubleValue ?? 0.0
        return shipRate.isZero
    }
    
    init(dict: NSDictionary) {
        orderTotal = dict.getStringValue(key: "OrderTotal")
        subTotal = dict.getStringValue(key: "SubTotal")
        rewardPoints = dict.getIntValue(key: "WillEarnRewardPoints")
        estimatedTax = dict.getStringValue(key: "Tax")
        shipping = dict.getStringValue(key: "Shipping")
    }
}

class ShippingOption {
    
    let name: String
    let desc: String
    let price: String
    
    init(dict: NSDictionary) {
        name = dict.getStringValue(key: "Name")
        desc = dict.getStringValue(key: "Description")
        price = dict.getStringValue(key: "Price")
    }
    
}

class TaxRate {
    let rate: String
    let value: String
    
    var taxValue: Double {
        return value.doubleValue ?? 0.0
    }
    
    init(dict: NSDictionary) {
        rate = dict.getStringValue(key: "Rate")
        value = dict.getStringValue(key: "Value")
    }
}

class ShippingMethod {
    
    let name: String
    let desc: String
    let systemName: String
    let fee: String
    var isSelected: Bool = false
    
    var methodSelected: String {
        return "\(name)___\(systemName)"
    }
    
    init(dict: NSDictionary) {
        name = dict.getStringValue(key: "Name")
        desc = dict.getStringValue(key: "Description")
        systemName = dict.getStringValue(key: "ShippingRateComputationMethodSystemName")
        fee = dict.getStringValue(key: "Fee")
        isSelected = dict.getBooleanValue(key: "Selected")
    }
}

class PaymentMethod {
   
    let name: String
    let systemName: String
    let fee: String
    let strLogo: String
    var isSelected: Bool = false
    
    var logoUrl: URL? {
        return URL(string: strLogo)
    }
    
    init(dict: NSDictionary) {
        name = dict.getStringValue(key: "Name")
        systemName = dict.getStringValue(key: "PaymentMethodSystemName")
        fee = dict.getStringValue(key: "Fee")
        strLogo = dict.getStringValue(key: "LogoUrl")
        isSelected = dict.getBooleanValue(key: "Selected")
    }
}
