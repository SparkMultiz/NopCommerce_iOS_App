//
//  Order.swift
//  NopCommerce
//
//  Created by Chirag Patel on 17/03/20.
//  Copyright © 2020 Chirag Patel. All rights reserved.
//

import Foundation

class Order {
    
    let id: String
    var date: String
    let status: String
    let total: String
    
    init(dict: NSDictionary) {
        id = dict.getStringValue(key: "OrderId")
        date = dict.getStringValue(key: "OrderDate")
        status = dict.getStringValue(key: "OrderStatus")
        total = dict.getStringValue(key: "OrderTotal")
    }
}

class OrderDetail {
    let orderId: String
    let orderGuid: String
    let pdfInvoiceDisable: Bool
    let isReOrderAllowed: Bool
    let isReturnRequestAllowed: Bool
    let paymentMethod: String
    let paymentMethodStatus: String
    let shippingMethod: String
    let shippingMethodStatus: String
    let orderTotal: String
    let orderDiscount: String
    var subTotal: String = ""
    let tax: String
    let delivery: String
    let customerCurrencyCode: String
    let earnPoints: Int
    let customerIp: String
    var createdDate: Date?
    var billingAddress: Address?
    var shippingAddress: Address?
    var arrItems: [WishList] = []
    
    var totalAmountOrderTax: Double {
        return Double(tax.replace("$", replacement: "")) ?? .zero
    }
    
    init(dict: NSDictionary) {
        orderId = dict.getStringValue(key: "OrderId")
        orderGuid = dict.getStringValue(key: "OrderGuid")
        pdfInvoiceDisable = dict.getBooleanValue(key: "PdfInvoiceDisabled")
        isReOrderAllowed = dict.getBooleanValue(key: "IsReOrderAllowed")
        isReturnRequestAllowed = dict.getBooleanValue(key: "IsReturnRequestAllowed")
        customerIp = dict.getStringValue(key: "CustomerIp")
        paymentMethod = dict.getStringValue(key: "PaymentMethod")
        paymentMethodStatus = dict.getStringValue(key: "PaymentMethodStatus")
        shippingMethod = dict.getStringValue(key: "ShippingMethod")
        shippingMethodStatus = dict.getStringValue(key: "ShippingStatus")
        customerCurrencyCode = dict.getStringValue(key: "CustomerCurrencyCode")
        orderTotal = dict.getStringValue(key: "OrderTotal")
        orderDiscount = dict.getStringValue(key: "OrderTotalDiscount")
        
        if !dict.getStringValue(key: "OrderSubtotal").isEmpty {
            subTotal = dict.getStringValue(key: "OrderSubtotal")
        } else if !dict.getStringValue(key: "SubTotal").isEmpty {
            subTotal = dict.getStringValue(key: "SubTotal")
        }
        
        tax = dict.getStringValue(key: "Tax")
        delivery = "Free"//dict.getStringValue(key: "Tax")
        earnPoints = dict.getIntValue(key: "RedeemedRewardPoints")
        createdDate = Date.getISODateFormatConvertor(from: dict.getStringValue(key: "CreatedOn"))
        
        if let objBillingAddress = dict["BillingAddress"] as? NSDictionary {
            self.billingAddress = Address(dict: objBillingAddress)
        }
        
        if let objShippingAddress = dict["ShippingAddress"] as? NSDictionary {
            self.shippingAddress = Address(dict: objShippingAddress)
        }
        
        if let allItems = dict["Items"] as? [NSDictionary] {
            for itemDict in allItems {
                let objItem = WishList(dict: itemDict)
                self.arrItems.append(objItem)
            }
        }
    }
}

class ReturnOrder {
    
    var arrItems: [WishList] = []
    var arrReturnReason: [AvailableReturnType] = []
    var arrReturnAction: [AvailableReturnType] = []
    
    var selectedReason: AvailableReturnType {
        return arrReturnReason.filter{$0.isSelected}.first ?? arrReturnReason[0]
    }
    
    var selectedAction: AvailableReturnType {
        return arrReturnAction.filter{$0.isSelected}.first ?? arrReturnAction[0]
    }
    
    init(dict: NSDictionary) {
        
        if let allItems = dict["Items"] as? [NSDictionary] {
            for itemDict in allItems {
                let objItem = WishList(dict: itemDict)
                self.arrItems.append(objItem)
            }
        }
        
        if let allReturnReason = dict["AvailableReturnReasons"] as? [NSDictionary] {
            for reasonDict in allReturnReason {
                let objReason = AvailableReturnType(dict: reasonDict)
                self.arrReturnReason.append(objReason)
            }
        }
        
        if let allReturnAction = dict["AvailableReturnActions"] as? [NSDictionary] {
            for returnDict in allReturnAction {
                let objReturn = AvailableReturnType(dict: returnDict)
                self.arrReturnAction.append(objReturn)
            }
        }
    }
}

class AvailableReturnType {
    
    let id: String
    let name: String
    var isSelected = false
    
    init(dict: NSDictionary) {
        id = dict.getStringValue(key: "Id")
        name = dict.getStringValue(key: "Name")
    }
    
}
