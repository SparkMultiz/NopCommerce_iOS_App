//
//  SlideMenu.swift
//  NopCommerce
//
//  Created by Chirag Patel on 13/03/20.
//  Copyright © 2020 Chirag Patel. All rights reserved.
//

import Foundation

class MainCategory {
    
    let id: String
    let name: String
    var subCategories: [SubCategory] = []
    var isSectionSelected = false
    var isViewEnable = false
    
    init(id: String, name: String) {
        self.id = id
        self.name = name
    }
    
    init(dict: NSDictionary) {
        id = dict.getStringValue(key: "Id")
        name = dict.getStringValue(key: "Name")
        
        if let arrSubCat = dict["SubCategories"] as? [NSDictionary] {
            for subCatDict in arrSubCat {
                self.subCategories.append(SubCategory(dict: subCatDict))
            }
        }
        
    }
}

class SubCategory {
    
    let id: String
    let name: String
    var innerSubCat: [SubCategory] = []
    var isRowSelected = false
    var isViewEnable = false
    
    init(dict: NSDictionary) {
        id = dict.getStringValue(key: "Id")
        name = dict.getStringValue(key: "Name")
        if let arrSubCat = dict["SubCategories"] as? [NSDictionary] {
            for subCatDict in arrSubCat {
                self.innerSubCat.append(SubCategory(dict: subCatDict))
            }
        }
    }
}
