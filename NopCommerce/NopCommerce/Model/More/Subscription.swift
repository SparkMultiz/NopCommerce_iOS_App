//
//  Subscription.swift
//  NopCommerce
//
//  Created by Chirag Patel on 18/03/20.
//  Copyright © 2020 Chirag Patel. All rights reserved.
//

import Foundation

class Subscription {
    
    let id: String
    let proId: String
    let proName: String
    var isSelected = false
    
    init(dict: NSDictionary) {
        id = dict.getStringValue(key: "Id")
        proId = dict.getStringValue(key: "ProductId")
        proName = dict.getStringValue(key: "ProductName")
    }
}
