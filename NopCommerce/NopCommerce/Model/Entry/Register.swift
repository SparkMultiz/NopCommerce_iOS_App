//
//  Register.swift
//  NopCommerce
//
//  Created by Chirag Patel on 06/03/20.
//  Copyright © 2020 Chirag Patel. All rights reserved.
//

import Foundation

enum GenderType: String {
    case male = "male"
    case female = "female"
    
    init(idx: Int) {
        if idx == 0 {
            self = .male
        } else {
            self = .female
        }
    }
}

enum EnumRegisterCell: String {
    case textField = "txtCell"
    case genderCell = "genderCell"
    case dobCell = "dobCell"
    case userNameCell = "userNameCell"
    case passwordCell = "passwordCell"
    case termsCell = "termsCell"
    case txtViewCell = "txtViewCell"
    case pickerCell = "dropDownCell"
    
    //    case .textField, .userNameCell, .passwordCell:
    //            return 70.widthRatio
    //        case .genderCell, .dobCell:
    //            return 65.widthRatio
    
    var cellHeight: CGFloat {
        switch self {
        case .termsCell:
            return max(70.widthRatio, UITableView.automaticDimension)
        case .txtViewCell:
            return 120.widthRatio
        default:
            return 65.widthRatio
        }
    }
}

struct UserField {
    
    var placeholder:String = ""
    var text: String = ""
    var key: String = ""
    var title: String = ""
    var image: UIImage?
    var gender: GenderType = .male
    var isSelected = false
    var keyboardType: UIKeyboardType = .default
    var keyBoardReturnKey: UIReturnKeyType = .next
    var fieldType = EnumRegisterCell.textField
}

struct FormRequiredData {
    
    let isEmailTwice : Bool
    let userNameEnabled : Bool
    let usernameAvailabilityEnabled : Bool
    let genderEnabled : Bool
    let dateOfBirthEnabled : Bool
    let dateOfBirthRequired : Bool
    let phoneEnabled: Bool
    let phoneRequired: Bool
    let faxEnabled: Bool
    let faxRequired: Bool
    let companyEnabled : Bool
    let companyRequired : Bool
    let streetAddressEnabled : Bool
    let streetAddressRequired : Bool
    let streetAddress2Enabled : Bool
    let streetAddress2Required : Bool
    let zipPostalCodeEnabled : Bool
    let zipPostalCodeRequired : Bool
    let cityEnabled : Bool
    let cityRequired : Bool
    let countyEnabled : Bool
    let countyRequired : Bool
    let newsLetterEnabled: Bool
    
    init(dict: NSDictionary) {
        isEmailTwice = dict.getBooleanValue(key: "EnteringEmailTwice")
        userNameEnabled = dict.getBooleanValue(key: "UsernamesEnabled")
        usernameAvailabilityEnabled = dict.getBooleanValue(key: "CheckUsernameAvailabilityEnabled")
        genderEnabled = dict.getBooleanValue(key: "GenderEnabled")
        dateOfBirthEnabled = dict.getBooleanValue(key: "DateOfBirthEnabled")
        dateOfBirthRequired = dict.getBooleanValue(key: "DateOfBirthRequired")
        phoneEnabled = dict.getBooleanValue(key: "PhoneEnabled")
        phoneRequired = dict.getBooleanValue(key: "PhoneRequired")
        faxEnabled = dict.getBooleanValue(key: "FaxEnabled")
        faxRequired = dict.getBooleanValue(key: "FaxRequired")
        companyEnabled = dict.getBooleanValue(key: "CompanyEnabled")
        companyRequired = dict.getBooleanValue(key: "CompanyRequired")
        streetAddressEnabled = dict.getBooleanValue(key: "StreetAddressEnabled")
        streetAddressRequired = dict.getBooleanValue(key: "StreetAddressRequired")
        streetAddress2Enabled = dict.getBooleanValue(key: "StreetAddress2Enabled")
        streetAddress2Required = dict.getBooleanValue(key: "StreetAddress2Required")
        zipPostalCodeEnabled = dict.getBooleanValue(key: "ZipPostalCodeEnabled")
        zipPostalCodeRequired = dict.getBooleanValue(key: "ZipPostalCodeRequired")
        cityEnabled = dict.getBooleanValue(key: "CityEnabled")
        cityRequired = dict.getBooleanValue(key: "CityRequired")
        countyEnabled = dict.getBooleanValue(key: "CountyEnabled")
        countyRequired = dict.getBooleanValue(key: "CountyRequired")
        newsLetterEnabled = dict.getBooleanValue(key: "NewsletterEnabled")
    }
}

class RegisterDataSpecifier {
    
    var arrUserFields       : [[UserField]] = []
    var arrPersonalDetails  : [UserField] = []
    var arrCompanyDetails   : [UserField] = []
    var arrOptionDetails    : [UserField] = []
    var arrPasswordDetails  : [UserField] = []
    var arrOtherDetails     : [UserField] = []
    
    func prepareRegisterFields(formData: FormRequiredData) {
        if formData.genderEnabled {
            var t1 = UserField()
            t1.fieldType = .genderCell
            arrPersonalDetails.append(t1)
        }
        
        var t2 = UserField()
        t2.placeholder = getLocalizedKey(str: "account.fields.firstname")
        t2.key = "First Name"
        arrPersonalDetails.append(t2)
        
        var t3 = UserField()
        t3.placeholder = getLocalizedKey(str: "account.fields.lastname")
        t3.key = "Last Name"
        t3.keyBoardReturnKey = .done
        arrPersonalDetails.append(t3)
        
        if formData.dateOfBirthEnabled {
            var t4 = UserField()
            t4.fieldType = .dobCell
            arrPersonalDetails.append(t4)
        }
        
       // if formData.userNameEnabled {
            var t5 = UserField()
            t5.placeholder = getLocalizedKey(str: "account.fields.username")
            t5.key = "User Name"
            t5.fieldType = .userNameCell
            t5.keyBoardReturnKey = .done
            arrPersonalDetails.append(t5)
      //  }
        
        var t6 = UserField()
        t6.placeholder = getLocalizedKey(str: "account.fields.email")
        t6.key = "Email"
        t6.keyboardType = .emailAddress
        arrPersonalDetails.append(t6)
        
        if formData.isEmailTwice {
            var t7 = UserField()
            t7.placeholder = getLocalizedKey(str: "account.fields.confirmemail")
            t7.key = "Confirm Email"
            t7.keyboardType = .emailAddress
            arrPersonalDetails.append(t7)
        }
        
        if formData.phoneEnabled {
            var t8 = UserField()
            t8.placeholder = getLocalizedKey(str: "account.fields.phone")
            t8.key = "Phone Number"
            t8.keyboardType = .numberPad
            arrPersonalDetails.append(t8)
        }
        arrUserFields.append(arrPersonalDetails)
        
        if formData.companyEnabled {
            var t9 = UserField()
            t9.placeholder = getLocalizedKey(str: "account.fields.company")
            t9.key = "Company Name"
            t9.keyBoardReturnKey = .done
            arrCompanyDetails.append(t9)
        }
        arrUserFields.append(arrCompanyDetails)
        
        var t14 = UserField()
        t14.title = getLocalizedKey(str: "account.fields.newsletter")
        t14.fieldType = .termsCell
        arrOptionDetails.append(t14)
        
        arrUserFields.append(arrOptionDetails)
        
        var t10 = UserField()
        t10.placeholder = getLocalizedKey(str: "account.fields.password")
        t10.key = "Password"
        t10.fieldType = .passwordCell
        arrPasswordDetails.append(t10)
        
        var t11 = UserField()
        t11.placeholder = getLocalizedKey(str: "account.fields.confirmpassword")
        t11.key = "Confirm Password"
        t11.fieldType = .passwordCell
        t11.keyBoardReturnKey = .done
        arrPasswordDetails.append(t11)
        
        arrUserFields.append(arrPasswordDetails)
        
        var t12 = UserField()
        t12.title = "I agree to receive information about exciting offers on emails."
        t12.fieldType = .termsCell
        arrOtherDetails.append(t12)
        
        var t13 = UserField()
        t13.title = getLocalizedKey(str: "account.fields.acceptprivacypolicy")//"By signing up you will agree to our privacy policy & terms."
        t13.fieldType = .termsCell
        arrOtherDetails.append(t13)
        
        arrUserFields.append(arrOtherDetails)
    }
    
    func validatetData(formData: FormRequiredData) -> (isValid: Bool, error: String) {
        var result = (isValid: true, error: "")
        
        let emailIdx            = arrUserFields[0].firstIndex{$0.keyboardType == .emailAddress}
        let phoneIdx            = arrUserFields[0].firstIndex{$0.keyboardType == .numberPad}
        let firstNameIdx        = arrUserFields[0].firstIndex{$0.key == "First Name"}
        let lastNameIdx         = arrUserFields[0].firstIndex{$0.key == "Last Name"}
        let passwordIdx         = arrUserFields[3].firstIndex{$0.key == "Password"}
        let cnfrmPasswordIdx    = arrUserFields[3].firstIndex{$0.key == "Confirm Password"}
        
        if String.validateStringValue(str: arrUserFields[0][firstNameIdx!].text){
            result.isValid = false
            result.error = getLocalizedKey(str: "account.fields.firstname.required")
            return result
        }
        
        if String.validateStringValue(str: arrUserFields[0][lastNameIdx!].text){
            result.isValid = false
            result.error = getLocalizedKey(str: "account.fields.lastname.required")
            return result
        }
        
        if formData.dateOfBirthEnabled {
            let dobIdx = arrUserFields[0].firstIndex{$0.fieldType == .dobCell}
            if String.validateStringValue(str: arrUserFields[0][dobIdx!].text){
                result.isValid = false
                result.error = getLocalizedKey(str: "account.fields.dateofbirth.required")
                return result
            }
        }
        
      //  if formData.userNameEnabled {
            let userNameIdx = arrUserFields[0].firstIndex{$0.fieldType == .userNameCell}
            if String.validateStringValue(str: arrUserFields[0][userNameIdx!].text){
                result.isValid = false
                result.error = getLocalizedKey(str: "account.fields.username.required")
                return result
            } else if !arrUserFields[0][userNameIdx!].text.isValidUsername() {
                result.isValid = false
                result.error = getLocalizedKey(str: "account.fields.username.notvalid")
                return result
            }
       // }
        
        if String.validateStringValue(str: arrUserFields[0][emailIdx!].text){
            result.isValid = false
            result.error = getLocalizedKey(str: "account.fields.email.required")
            return result
        } else if !arrUserFields[0][emailIdx!].text.isValidEmailAddress() {
            result.isValid = false
            result.error = getLocalizedKey(str: "account.fields.emailtorevalidate.note")
            return result
        }
        
        if formData.phoneEnabled {
            if String.validateStringValue(str: arrUserFields[0][phoneIdx!].text){
                result.isValid = false
                result.error = getLocalizedKey(str: "account.fields.phone.required")
                return result
            }
            /*else if !arrUserFields[0][phoneIdx!].text.validateContact() {
                result.isValid = false
                result.error = kMobileInvalid
                return result
            } */
        }
        
        if formData.companyEnabled {
            let compIdx = arrUserFields[1].firstIndex{$0.key == "Company Name"}
            if String.validateStringValue(str: arrUserFields[1][compIdx!].text){
                result.isValid = false
                result.error = getLocalizedKey(str: "account.fields.company.required")
                return result
            }
        }
        
        if String.validateStringValue(str: arrUserFields[3][passwordIdx!].text){
            result.isValid = false
            result.error = getLocalizedKey(str: "account.fields.password.required")
            return result
        } else if arrUserFields[3][passwordIdx!].text.count < 3 {
            result.isValid = false
            result.error = getLocalizedKey(str: "account.fields.password.lengthvalidation")
            return result
        }
        
        if String.validateStringValue(str: arrUserFields[3][cnfrmPasswordIdx!].text){
            result.isValid = false
            result.error = getLocalizedKey(str: "account.fields.confirmpassword.required")
            return result
        } else if !arrUserFields[3][passwordIdx!].text.isEqual(str: arrUserFields[3][cnfrmPasswordIdx!].text) {
            result.isValid = false
            result.error = getLocalizedKey(str: "account.fields.password.enteredpasswordsdonotmatch")
            return result
        }
        
        if !arrUserFields[4][0].isSelected {
            result.isValid = false
            result.error = kSelectOffer
            return result
        }
        
        if !arrUserFields[4][1].isSelected {
            result.isValid = false
            result.error = kSelectTerms
            return result
        }
        
        return result
    }
    
    func paramDict(formData: FormRequiredData) -> [String: Any] {
        var dict: [String: Any] = [:]
        dict["ApiSecretKey"] = secretKey
        dict["StoreId"] = storeId
        dict["LanguageId"] = languageId
        dict["CustomerGUID"] = customerGUID
        
        let emailIdx       = arrUserFields[0].firstIndex{$0.keyboardType == .emailAddress}
        let phoneIdx       = arrUserFields[0].firstIndex{$0.keyboardType == .numberPad}
        let userNameIdx    = arrUserFields[0].firstIndex{$0.fieldType == .userNameCell}
        let firstNameIdx   = arrUserFields[0].firstIndex{$0.key == "First Name"}
        let lastNameIdx    = arrUserFields[0].firstIndex{$0.key == "Last Name"}
        let passwordIdx    = arrUserFields[3].firstIndex{$0.fieldType == .passwordCell}
        
        dict["EmailId"]       = arrUserFields[0][emailIdx!].text
        dict["FirstName"]     = arrUserFields[0][firstNameIdx!].text
        dict["LastName"]      = arrUserFields[0][lastNameIdx!].text
        dict["Password"]      = arrUserFields[3][passwordIdx!].text
        
        if formData.newsLetterEnabled {
            dict["NewsLetter"]    = arrUserFields[2][0].isSelected
        }
        if formData.genderEnabled {
            let genderIdx = arrUserFields[0].firstIndex{$0.fieldType == .genderCell}
            dict["Gender"] = arrUserFields[0][genderIdx!].gender.rawValue
        }
       // if formData.userNameEnabled {
            dict["UserName"] = arrUserFields[0][userNameIdx!].text
      //  }
        if formData.dateOfBirthEnabled {
            let dobIdx = arrUserFields[0].firstIndex{$0.fieldType == .dobCell}
            dict["DateOfBirth"] = arrUserFields[0][dobIdx!].text
        }
        if formData.phoneEnabled {
            dict["PhoneNumber"] = arrUserFields[0][phoneIdx!].text
        }
        if formData.companyEnabled {
            let compIdx = arrUserFields[1].firstIndex{$0.key == "Company Name"}
            dict["CompanyName"] = arrUserFields[1][compIdx!].text
        }
        return dict
    }
    
    
    // Profile Date
    func prepareProfileFields() {
        
        var t1 = UserField()
        t1.fieldType = .genderCell
        t1.gender = GenderType(rawValue: _user.gender) ?? .male
        arrPersonalDetails.append(t1)
        
        var t2 = UserField()
        t2.placeholder = getLocalizedKey(str: "account.fields.firstname")
        t2.key = "First Name"
        t2.text = _user.firstName
        arrPersonalDetails.append(t2)
        
        var t3 = UserField()
        t3.placeholder = getLocalizedKey(str: "account.fields.lastname")
        t3.key = "Last Name"
        t3.text = _user.lastName
        t3.keyBoardReturnKey = .done
        arrPersonalDetails.append(t3)
        
        var t4 = UserField()
        t4.fieldType = .dobCell
        t4.text = _user.dob
        arrPersonalDetails.append(t4)
        
        var t5 = UserField()
        t5.placeholder = getLocalizedKey(str: "account.fields.username")
        t5.key = "User Name"
        t5.text = _user.userName
        t5.fieldType = .userNameCell
        t5.keyBoardReturnKey = .done
        arrPersonalDetails.append(t5)
        
        var t6 = UserField()
        t6.placeholder = getLocalizedKey(str: "account.fields.email")
        t6.key = "Email"
        t6.text = _user.email
        t6.isSelected = true
        t6.keyboardType = .emailAddress
        arrPersonalDetails.append(t6)
        
        var t7 = UserField()
        t7.placeholder = getLocalizedKey(str: "account.fields.phone")
        t7.key = "Phone Number"
        t7.text = _user.phone
        t7.keyboardType = .numberPad
        arrPersonalDetails.append(t7)
        
        arrUserFields.append(arrPersonalDetails)
        
        var t8 = UserField()
        t8.placeholder = getLocalizedKey(str: "account.fields.company")
        t8.key = "Company Name"
        t8.text = _user.companyName
        t8.keyBoardReturnKey = .done
        arrCompanyDetails.append(t8)
        
        arrUserFields.append(arrCompanyDetails)
        
        var t9 = UserField()
        t9.title = getLocalizedKey(str: "account.fields.newsletter")
        t9.fieldType = .termsCell
        arrOptionDetails.append(t9)
               
        arrUserFields.append(arrOptionDetails)
    }
    
    func validateProfileData() -> (isValid: Bool, error: String) {
        var result = (isValid: true, error: "")
        
        if String.validateStringValue(str: arrUserFields[0][1].text){
            result.isValid = false
            result.error = kEnterName
            return result
        }
        
        if String.validateStringValue(str: arrUserFields[0][2].text){
            result.isValid = false
            result.error = kEnterLastName
            return result
        }
        
        if String.validateStringValue(str: arrUserFields[0][3].text){
            result.isValid = false
            result.error = kEnterDob
            return result
        }
        
        if String.validateStringValue(str: arrUserFields[0][6].text){
            result.isValid = false
            result.error = kEnterMobile
            return result
        } else if !arrUserFields[0][6].text.validateContact() {
            result.isValid = false
            result.error = kMobileInvalid
            return result
        }
        
        if String.validateStringValue(str: arrUserFields[1][0].text){
            result.isValid = false
            result.error = kEnterCompanyName
            return result
        }
        
        return result
    }
    
    func profileParamDict() -> [String: Any] {
        var dict: [String: Any] = [:]
        dict["ApiSecretKey"] = secretKey
        dict["CustomerGUID"] = _user.guid
        dict["Gender"]       = arrUserFields[0][0].gender.rawValue
        dict["FirstName"]    = arrUserFields[0][1].text
        dict["LastName"]     = arrUserFields[0][2].text
        dict["DateOfBirth"]  = arrUserFields[0][3].text
        dict["UserName"]     = arrUserFields[0][4].text
        dict["Email"]        = arrUserFields[0][5].text
        dict["PhoneNumber"]   = arrUserFields[0][6].text
        dict["CompanyName"]   = arrUserFields[1][0].text
        return dict
    }
    
}

class NewAddress {
    
    var objAddress: Address?
    var arrAddressField: [UserField] = []
    
    init(dict: NSDictionary) {
        objAddress = Address(dict: dict, hasValidation: true)
        prepareAddressField()
    }
    
    init() {}
    
    func prepareAddressField() {
        guard let address = objAddress else {return}
        
        var t1 = UserField()
        t1.placeholder = "First Name"
        t1.key = "First Name"
        t1.text = address.frstName
        arrAddressField.append(t1)
        
        var t2 = UserField()
        t2.placeholder = "Last Name"
        t2.key = "Last Name"
        t2.text = address.lastName
        arrAddressField.append(t2)
        
        var t3 = UserField()
        t3.placeholder = "Email"
        t3.key = "Email"
        t3.text = address.email
        t3.keyboardType = .emailAddress
        arrAddressField.append(t3)
        
        if address.requiredData!.companyEnabled {
            var t4 = UserField()
            t4.placeholder = "Company Name"
            t4.key = "Company Name"
            t4.text = address.compName
            t4.keyBoardReturnKey = .done
            arrAddressField.append(t4)
        }
        
        //if address.requiredData!.countyEnabled {
        var t5 = UserField()
        t5.title = "Country"
        t5.key = "Country"
        t5.fieldType = .pickerCell
        arrAddressField.append(t5)
        
        var t6 = UserField()
        t6.title = "State/Province"
        t6.key = "State/Province"
        t6.fieldType = .pickerCell
        arrAddressField.append(t6)
        //  }
        
        if address.requiredData!.cityEnabled {
            var t7 = UserField()
            t7.placeholder = "City"
            t7.key = "City"
            arrAddressField.append(t7)
        }
        
        if address.requiredData!.streetAddressEnabled {
            var t8 = UserField()
            t8.placeholder = "Addrerss 1"
            t8.key = "Addrerss 1"
            t8.text = address.address1
            arrAddressField.append(t8)
            
        }
        
        if address.requiredData!.streetAddress2Enabled {
            var t9 = UserField()
            t9.placeholder = "Address 2"
            t9.key = "Address 2"
            t9.text = address.address2
            arrAddressField.append(t9)
        }
        
        if address.requiredData!.zipPostalCodeEnabled {
            var t10 = UserField()
            t10.placeholder = "ZipPostal code"
            t10.key = "ZipPostal code"
            t10.text = address.zipCode
            t10.keyboardType = .numberPad
            arrAddressField.append(t10)
        }
        
        if address.requiredData!.phoneEnabled {
            var t11 = UserField()
            t11.placeholder = "Phone Number"
            t11.key = "Phone Number"
            t11.text = address.phone
            t11.keyboardType = .numberPad
            arrAddressField.append(t11)
        }
        
        if address.requiredData!.faxEnabled {
            var t12 = UserField()
            t12.placeholder = "Fax Number"
            t12.key = "Fax Number"
            t12.text = address.fax
            t12.keyBoardReturnKey = .done
            arrAddressField.append(t12)
        }
    }
    
    func addressDict() -> [String: Any] {
        var dict: [String: Any] = [:]
        guard let address = objAddress else {return dict}
        
        dict["FirstName"] = arrAddressField[0].text
        dict["LastName"] = arrAddressField[1].text
        dict["Email"] = arrAddressField[2].text
        if address.requiredData!.companyEnabled {
            let compIdx = arrAddressField.firstIndex{$0.key == "Company Name"}
            dict["Company"] = arrAddressField[compIdx!].text
        }
        //  if address.requiredData!.countyEnabled {
        let contIdx = arrAddressField.firstIndex{$0.key == "Country"}
        let stateIdx = arrAddressField.firstIndex{$0.key == "State/Province"}
        dict["CountryId"] = arrAddressField[contIdx!].text
        dict["StateProvinceId"] = arrAddressField[stateIdx!].text
        //   }
        if address.requiredData!.cityEnabled {
            let cityIdx = arrAddressField.firstIndex{$0.key == "City"}
            dict["City"] = arrAddressField[cityIdx!].text
        }
        if address.requiredData!.streetAddressEnabled {
            let add1Idx = arrAddressField.firstIndex{$0.key == "Addrerss 1"}
            dict["Address1"] = arrAddressField[add1Idx!].text
        }
        if address.requiredData!.streetAddress2Enabled {
            let add2Idx = arrAddressField.firstIndex{$0.key == "Address 2"}
            dict["Address2"] = arrAddressField[add2Idx!].text
        }
        if address.requiredData!.phoneEnabled {
            let phoneIdx = arrAddressField.firstIndex{$0.key == "Phone Number"}
            dict["PhoneNumber"] = arrAddressField[phoneIdx!].text
        }
        if address.requiredData!.zipPostalCodeEnabled{
            let zipIdx = arrAddressField.firstIndex{$0.key == "ZipPostal code"}
            dict["ZipPostalCode"] = arrAddressField[zipIdx!].text
        }
        if address.requiredData!.faxEnabled {
            let faxIdx = arrAddressField.firstIndex{$0.key == "Fax Number"}
            dict["FaxNumber"] = arrAddressField[faxIdx!].text
        }
        return dict
    }
    
    func paramDict() -> [String: Any] {
        var dict: [String: Any] = [:]
        dict["ApiSecretKey"] = secretKey
        dict["StoreId"] = storeId
        dict["CurrencyId"] = currencyId
        dict["AttributeControlIds"] = []
        dict["CustomerGUID"] = _user.guid
        dict["AddressModel"] = addressDict()
        return dict
    }
    
    func validatetData() -> (isValid: Bool, error: String) {
        var result = (isValid: true, error: "")
        guard let address = objAddress else {return result}
        
        if String.validateStringValue(str: arrAddressField[0].text){
            result.isValid = false
            result.error = kEnterName
            return result
        }
        
        if String.validateStringValue(str: arrAddressField[1].text){
            result.isValid = false
            result.error = kEnterLastName
            return result
        }
        
        if String.validateStringValue(str: arrAddressField[2].text){
            result.isValid = false
            result.error = kEnterEmail
            return result
        } else if !arrAddressField[2].text.isValidEmailAddress() {
            result.isValid = false
            result.error = kInvalidEmail
            return result
        }
        
        if address.requiredData!.companyRequired {
            let compIdx = arrAddressField.firstIndex{$0.key == "Company Name"}
            if String.validateStringValue(str: arrAddressField[compIdx!].text){
                result.isValid = false
                result.error = kEnterCompanyName
                return result
            }
        }
        
        if address.requiredData!.cityRequired {
            let cityIdx = arrAddressField.firstIndex{$0.key == "City"}
            if String.validateStringValue(str: arrAddressField[cityIdx!].text){
                result.isValid = false
                result.error = kEnterCity
                return result
            }
        }
        
        if address.requiredData!.streetAddressRequired {
            let add1Idx = arrAddressField.firstIndex{$0.key == "Addrerss 1"}
            if String.validateStringValue(str: arrAddressField[add1Idx!].text){
                result.isValid = false
                result.error = kEnterAddress
                return result
            }
        }
        
        if address.requiredData!.streetAddress2Required {
            let add2Idx = arrAddressField.firstIndex{$0.key == "Addrerss 2"}
            if String.validateStringValue(str: arrAddressField[add2Idx!].text){
                result.isValid = false
                result.error = kEnterAddress
                return result
            }
        }
        
        if address.requiredData!.zipPostalCodeRequired {
            let zipIdx = arrAddressField.firstIndex{$0.key == "ZipPostal code"}
            if String.validateStringValue(str: arrAddressField[zipIdx!].text){
                result.isValid = false
                result.error = kEnterZipcode
                return result
            }
        }
        
        if address.requiredData!.phoneRequired {
            let phoneIdx = arrAddressField.firstIndex{$0.key == "Phone Number"}
            if String.validateStringValue(str: arrAddressField[phoneIdx!].text){
                result.isValid = false
                result.error = kEnterMobile
                return result
            } else if !arrAddressField[phoneIdx!].text.validateContact() {
                result.isValid = false
                result.error = kMobileInvalid
                return result
            }
        }
        
        if address.requiredData!.faxRequired {
            let faxIdx = arrAddressField.firstIndex{$0.key == "Fax Number"}
            if String.validateStringValue(str: arrAddressField[faxIdx!].text){
                result.isValid = false
                result.error = kEnterMFax
                return result
            }
        }
        return result
    }
}
