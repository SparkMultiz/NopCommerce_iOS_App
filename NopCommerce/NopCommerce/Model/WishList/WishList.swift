//
//  WishList.swift
//  NopCommerce
//
//  Created by Chirag Patel on 16/03/20.
//  Copyright © 2020 Chirag Patel. All rights reserved.
//

import Foundation

class WishList {
    
    let id: String
    let sku: String
    let proId: String
    let proName: String
    var quantity: Int
    let unitPrice: String
    let subTotal: String
    let discount: String
    let info: String
    let allowItemEditing: Bool
    
    var arrQuantity: [Quantity] = []
    var pictureModel: PictureModel?
    
    var attributeInfo: String {
        return info.replace("<br />", replacement: "\n")
    }
    
    init(dict: NSDictionary) {
        id = dict.getStringValue(key: "Id")
        sku = dict.getStringValue(key: "Sku")
        proId = dict.getStringValue(key: "ProductId")
        proName = dict.getStringValue(key: "ProductName")
        unitPrice = dict.getStringValue(key: "UnitPrice")
        subTotal = dict.getStringValue(key: "SubTotal")
        discount = dict.getStringValue(key: "Discount")
        quantity = dict.getIntValue(key: "Quantity")
        info = dict.getStringValue(key: "AttributeInfo")
        allowItemEditing = dict.getBooleanValue(key: "AllowItemEditing")
        
        if let pictureDict = dict["Picture"] as? NSDictionary {
            self.pictureModel = PictureModel(dict: pictureDict)
        }
        
        if let allQuantity = dict["AllowedQuantities"] as? [NSDictionary] {
            for quntityDict in allQuantity {
                self.arrQuantity.append(Quantity(dict: quntityDict))
            }
        }
    }
}

class Quantity {
    
    let text: String
    let value: String
    var isSelected = false
    
    init(dict: NSDictionary) {
        text = dict.getStringValue(key: "Text")
        value = dict.getStringValue(key: "Value")
    }
}
