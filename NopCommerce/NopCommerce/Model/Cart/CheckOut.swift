//
//  CheckOut.swift
//  NopCommerce
//
//  Created by Jayesh on 16/04/20.
//  Copyright © 2020 Chirag Patel. All rights reserved.
//

import Foundation

class CheckOutOrder {
    
    var billingAddress: Address?
    var shippingAddress: Address?
    var orderDetail: OrderDetail?
    var arrItems: [WishList] = []
    var arrAttribues: [ProductAttributes] = []
    
    init(dict: NSDictionary) {
        if let reviewDict = dict["OrderReviewData"] as? NSDictionary, let objBillingAddress = reviewDict["BillingAddress"] as? NSDictionary {
            self.billingAddress = Address(dict: objBillingAddress)
        }
        
        if let reviewDict = dict["OrderReviewData"] as? NSDictionary, let objShippingAddress = reviewDict["ShippingAddress"] as? NSDictionary {
            self.shippingAddress = Address(dict: objShippingAddress)
        }
        
        if let allItems = dict["Items"] as? [NSDictionary] {
            for itemDict in allItems {
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
        
        self.orderDetail = OrderDetail(dict: dict)
    }
}

class OrderTotalDetail {
    
    let priceIncludeTax: Bool
    let displayTaxShippingInfo: Bool
    let discountApplied: Bool
    
    let shipping: String
    let discount: String
    let orderSubTotal: String
    let orderTotal: String
    let tax: String
    
    init(dict: NSDictionary) {
        priceIncludeTax = dict.getBooleanValue(key: "PricesIncludeTax")
        displayTaxShippingInfo = dict.getBooleanValue(key: "PricesIncludeTax")
        discountApplied = dict.getBooleanValue(key: "DiscountApplied")
        
        shipping = dict.getStringValue(key: "OrderShippingInclTax")
        discount = dict.getStringValue(key: "OrderDiscount")
        orderSubTotal = dict.getStringValue(key: "OrderSubtotalExclTax")
        orderTotal = dict.getStringValue(key: "OrderTotal")
        tax = dict.getStringValue(key: "OrderTax")
    }
}


class ConfirmOrder {
    
    var objCustomer: Customer?
    var payMethod: PaymentMethodDetail?
    var orderDetail: OrderDetail?
    var orderTotal: OrderTotal?
    
    init(dict: NSDictionary) {
        if let customerDict = dict["Customer"] as? NSDictionary {
            self.objCustomer = Customer(dict: customerDict)
        }
        
        if let objPayMethod = dict["PaymentMethodDetail"] as? NSDictionary {
            self.payMethod = PaymentMethodDetail(dict: objPayMethod)
        }
        
        if let orderDict = dict["OrderDetail"] as? NSDictionary {
            self.orderDetail = OrderDetail(dict: orderDict)
        }
        
        if let totalDict = dict["OrderTotalDetail"] as? NSDictionary {
            self.orderTotal = OrderTotal(dict: totalDict)
        }
    }
}

class Customer {
    
    let id: String
    let guid: String
    
    init(dict: NSDictionary) {
        id = dict.getStringValue(key: "CustomerId")
        guid = dict.getStringValue(key: "CustomerGuid")
    }
}

class PaymentMethodDetail {
    
    let systemName: String
    let methodName: String
    
    init(dict: NSDictionary) {
        systemName = dict.getStringValue(key: "SystemName")
        methodName = dict.getStringValue(key: "MethodName")
    }
    
}
