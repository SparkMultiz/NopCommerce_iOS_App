//
//  User.swift
//  NopCommerce
//
//  Created by Chirag Patel on 12/03/20.
//  Copyright © 2020 Chirag Patel. All rights reserved.
//

import Foundation
import CoreData

class User: NSManagedObject, ParentManagedObject {
    
    @NSManaged var guid: String
    @NSManaged var firstName: String
    @NSManaged var lastName: String
    @NSManaged var email: String
    @NSManaged var userName: String
    @NSManaged var phone: String
    @NSManaged var gender: String
    @NSManaged var dob: String
    @NSManaged var companyName: String
    @NSManaged var profilePic: String
    @NSManaged var isGuestLogin: Bool
    
    var imgUrl: URL? {
        return URL(string: profilePic)
    }
    
    var fullName: String {
        return firstName + " " + lastName
    }
    
    func initGuid(dict: NSDictionary) {
        guid = dict.getStringValue(key: "CustomerGuid")
    }
    
    func initGuest(dict: NSDictionary) {
        guid = dict.getStringValue(key: "CustomerGuid")
        isGuestLogin = true
    }
    
    func initWith(dict: NSDictionary) {
        firstName = dict.getStringValue(key: "FirstName")
        lastName = dict.getStringValue(key: "LastName")
        email = dict.getStringValue(key: "Email")
        phone = dict.getStringValue(key: "Phone")
        gender = dict.getStringValue(key: "Gender")
        companyName = dict.getStringValue(key: "CompanyName")
        profilePic = dict.getStringValue(key: "AvatarPictureUrl")
        userName = dict.getStringValue(key: "Username")
        dob = dict.getStringValue(key: "DateOfBirth")
    }
    
    func updateUserProfile(dict: NSDictionary) {
        profilePic = dict.getStringValue(key: "Data")
    }
    
    func initRegister(dict: NSDictionary) {
        guid = dict.getStringValue(key: "CustomerGuid")
        email = dict.getStringValue(key: "Email")
        userName = dict.getStringValue(key: "Username")
    }
}
