//
//  ChangePassword.swift
//  NopCommerce
//
//  Created by Chirag Patel on 12/03/20.
//  Copyright © 2020 Chirag Patel. All rights reserved.
//

import Foundation

struct ChangePassword {
    var oldPassword = ""
    var newPassword = ""
    var confPassword = ""
    
    func paramDict() -> [String: Any] {
        var dict: [String: Any] = [:]
        dict["ApiSecretKey"] = secretKey
        dict["EmailId"] = _user.email
        dict["OldPassword"] = oldPassword
        dict["NewPassword"] = newPassword
        return dict
    }
    
    func validatetData() -> (isValid: Bool, error: String) {
        var result = (isValid: true, error: "")
        
        if String.validateStringValue(str: oldPassword){
            result.isValid = false
            result.error = getLocalizedKey(str: "account.changepassword.fields.oldpassword.required")
            return result
        }
        
        if String.validateStringValue(str: newPassword){
            result.isValid = false
            result.error = getLocalizedKey(str: "account.changepassword.fields.newpassword.required")
            return result
        }
        
        if !newPassword.isEqual(str: confPassword) {
            result.isValid = false
            result.error = getLocalizedKey(str: "account.fields.confirmpassword.required")
            return result
        }
        
        return result
    }
    
    
}
