//
//  UserDefaults.swift
//  NopCommerce
//
//  Created by Chirag Patel on 06/03/20.
//  Copyright © 2020 Chirag Patel. All rights reserved.
//

import Foundation

enum UserDefaultsKeys : String {
    case isOnBoardingCompleted
    case rememberMe
    case customerGuid
}

extension UserDefaults {
    
    func setOnBoardingStatus(value: Bool) {
        set(value, forKey: UserDefaultsKeys.isOnBoardingCompleted.rawValue)
        self.synchronize()
    }
    
    func isOnBoardingOver()-> Bool {
        return bool(forKey: UserDefaultsKeys.isOnBoardingCompleted.rawValue)
    }
    
    func setIsRememberMe(value: Bool) {
        set(value, forKey: UserDefaultsKeys.rememberMe.rawValue)
        self.synchronize()
    }
    
    func isRememberChecked() -> Bool {
        return bool(forKey: UserDefaultsKeys.rememberMe.rawValue)
    }
    
    func setCustomerGUID(value: String) {
        set(value, forKey: UserDefaultsKeys.customerGuid.rawValue)
        self.synchronize()
    }
    
    func customerGUID() -> String {
        return value(forKey: UserDefaultsKeys.customerGuid.rawValue) as? String ?? ""
    }
}

extension Notification.Name {
    static var addToWishList: Notification.Name {
        return .init(rawValue: "addtowishlist")
    }

    static var addToCart: Notification.Name {
        return .init(rawValue: "addtocart")
    }
}
