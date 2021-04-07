//
//  Address.swift
//  NopCommerce
//
//  Created by Chirag Patel on 17/03/20.
//  Copyright © 2020 Chirag Patel. All rights reserved.
//

import Foundation

enum EnumAddressType: Int {
    case saveAddress = 0
    case addAddress = 1
}

class Address {
    
    let id: String
    let country: String
    let province: String
    let city: String
    let address1: String
    let address2: String
    let zipCode: String
    let fax: String
    let frstName: String
    let lastName: String
    let email: String
    let compName: String
    let phone: String
    var isSelected = false
    var requiredData: FormRequiredData?
    
    var fullName: String {
        return "\(frstName) \(lastName)"
    }
    
    func getAddressHeight() -> CGFloat {
        let width = (_screenSize.width - 20) / 2
        let fullNameHeight = fullName.heightWithConstrainedWidth(width: width, font: UIFont.systemFont(ofSize: 15.widthRatio))
        let addressHeight = formattedAdress.heightWithConstrainedWidth(width: width, font: UIFont.systemFont(ofSize: 15.widthRatio))
        return fullNameHeight + addressHeight + 45.widthRatio
    }
    
    var formatUserDetails: String {
        return "Email: \(email)\nPhone Number: \(phone)\nFax: \(fax)\n\(compName)"
    }
    
    var formattedAdress: String {
        return "\(formatUserDetails)\n\(address1)\n\(address2)\n\(city),\(zipCode)\n\(country)"
    }
    
    init(dict: NSDictionary, hasValidation: Bool = false) {
        id = dict.getStringValue(key: "Id")
        country = dict.getStringValue(key: "CountryName")
        province = dict.getStringValue(key: "StateProvinceName")
        city = dict.getStringValue(key: "City")
        address1 = dict.getStringValue(key: "Address1")
        address2 = dict.getStringValue(key: "Address2")
        zipCode = dict.getStringValue(key: "ZipPostalCode")
        fax = dict.getStringValue(key: "FaxNumber")
        frstName = dict.getStringValue(key: "FirstName")
        lastName = dict.getStringValue(key: "LastName")
        email = dict.getStringValue(key: "Email")
        compName = dict.getStringValue(key: "Company")
        phone = dict.getStringValue(key: "PhoneNumber")
        if hasValidation {
            requiredData = FormRequiredData(dict: dict)
        }
    }
}

