//
//  DownloadableProduct.swift
//  NopCommerce
//
//  Created by Chirag Patel on 18/03/20.
//  Copyright © 2020 Chirag Patel. All rights reserved.
//

import Foundation

class DownloadProduct {
    
    let id: String
    let proId: String
    let orderId: String
    let proName: String
    var createdOn: Date?
    
    init(dict: NSDictionary) {
        id = dict.getStringValue(key: "DownloadId")
        proId = dict.getStringValue(key: "ProductId")
        orderId = dict.getStringValue(key: "OrderId")
        proName = dict.getStringValue(key: "ProductName")
        createdOn = Date.getISODateFormatConvertor(from: dict.getStringValue(key: "CreatedOn"))
    }
}
