//
//  LoginData.swift
//  NopCommerce
//
//  Created by Chirag Patel on 06/03/20.
//  Copyright © 2020 Chirag Patel. All rights reserved.
//

import Foundation

struct LoginData {
    
    var userName = ""
    var password = ""
    var isUserNameAvailable = false
    
    func paramDict() -> [String: Any] {
        var dict: [String: Any] = [:]
        dict["StoreId"] = storeId
        dict["ApiSecretKey"] = secretKey
        dict["GuestCustomerGUID"] = customerGUID
        dict["UserName"] = userName
        dict["Password"] = password
        return dict
    }
    
    func validatetData() -> (isValid: Bool, error: String) {
        var result = (isValid: true, error: "")
        
        if String.validateStringValue(str: userName){
            result.isValid = false
            result.error = isUserNameAvailable ? getLocalizedKey(str: "plugins.xcellenceit.webapiclient.account.login.fields.username.required") : getLocalizedKey(str: "account.login.fields.email.required")
            return result
        }
        
        if String.validateStringValue(str: password){
            result.isValid = false
            result.error = kEnterPassword
            return result
        }
        return result
    }
    
}
