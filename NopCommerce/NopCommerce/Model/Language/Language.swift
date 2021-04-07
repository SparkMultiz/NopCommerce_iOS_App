//
//  Language.swift
//  NopCommerce
//
//  Created by Jayesh on 18/05/20.
//  Copyright © 2020 Chirag Patel. All rights reserved.
//

import Foundation
import CoreData

class Language: NSManagedObject, ParentManagedObject {
    
    @NSManaged var name: String
    @NSManaged var value: String
    
    func initWith(dict: NSDictionary) {
        name = dict.getStringValue(key: "Name")
        value = dict.getStringValue(key: "Value")
    }
}


class Currency: NSManagedObject, ParentManagedObject {
    
    @NSManaged var id: String
    @NSManaged var name: String
    @NSManaged var currency: String
    
    var title: String {
        return "\(name) (\(currency) )"
    }
    
    func initWith(dict: NSDictionary) {
        id = dict.getStringValue(key: "Id")
        name = dict.getStringValue(key: "Name")
        currency = dict.getStringValue(key: "CurrencySymbol")
    }
}


class Languages {
    
    let id: String
    let name: String
    var isSelected = false
    
    init(dict: NSDictionary) {
        id = dict.getStringValue(key: "Id")
        name = dict.getStringValue(key: "Name")
    }
}
