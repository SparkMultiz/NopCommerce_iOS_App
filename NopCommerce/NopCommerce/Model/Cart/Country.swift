//
//  Country.swift
//  NopCommerce
//
//  Created by Jayesh on 28/03/20.
//  Copyright © 2020 Chirag Patel. All rights reserved.
//

import Foundation

class Country {
    
    let id: String
    let name: String
    let limitedToStore: Bool
    let twoLetterCode: String
    let isoCode: Int
    var isSelected = false
    
    init(dict: NSDictionary) {
        id = dict.getStringValue(key: "CountryId")
        name = dict.getStringValue(key: "CountryName")
        limitedToStore = dict.getBooleanValue(key: "LimitedToStore")
        twoLetterCode = dict.getStringValue(key: "TwoLetterIsoCode")
        isoCode = dict.getIntValue(key: "NumericIsoCode")
    }
}

class Province {
    
    let id: String
    let contId: String
    let name: String
    let countryName: String
    let abbreviation: String
    var isSelected = false
    
    init(dict: NSDictionary) {
        id = dict.getStringValue(key: "StateId")
        contId = dict.getStringValue(key: "CountryId")
        name = dict.getStringValue(key: "StateName")
        countryName = dict.getStringValue(key: "CountryName")
        abbreviation = dict.getStringValue(key: "Abbreviation")
    }
}
