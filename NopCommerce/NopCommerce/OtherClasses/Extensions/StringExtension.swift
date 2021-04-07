//  Created by Tom Swindell on 07/12/2015.
//  Copyright © 2015 The App Developers. All rights reserved.
//

import Foundation
import UIKit
import CoreTelephony

// MARK: - Registration Validation
extension String {
    
    static func validateStringValue(str:String?) -> Bool{
        var strNew = ""
        if str != nil{
            strNew = str!.trimWhiteSpace(newline: true)
        }
        if str == nil || strNew == "" || strNew.count == 0  {  return true  }
        else  {  return false  }
    }
    
    static func validatePassword(str:String?) -> Bool{
        if str == nil || str == "" || str!.count < 6  {  return true  }
        else  {  return false  }
    }
    
    func isValidUsername() -> Bool {
        let usernameRegex = "[0-9a-z_.]{3,15}" //^[a-zA-Z0-9_]{3,15}$
        let temp = NSPredicate(format: "SELF MATCHES %@", usernameRegex).evaluate(with: self)
        return temp
    }
    
    func isValidName() -> Bool{
        let nameRegix = "(?:[\\p{L}\\p{M}]|\\d)"
        return NSPredicate(format: "SELF MATCHES %@", nameRegix).evaluate(with: self)
    }
    
    func isValidURL() -> Bool {
        let urlRegex = "http[s]?://(([^/:.[:space:]]+(.[^/:.[:space:]]+)*)|([0-9](.[0-9]{3})))(:[0-9]+)?((/[^?#[:space:]]+)([^#[:space:]]+)?(#.+)?)?"
        let temp = NSPredicate(format:"SELF MATCHES %@", urlRegex).evaluate(with: self)
        return temp
    }
    
    func isValidEmailAddress() -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        let temp = NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: self)
        return temp
    }

    func validateContact() -> Bool{
//        let contactRegEx = "^\\d{3}-\\d{3}-\\d{4}$"
        let contactRegEx = "^[0-9]{10,10}$"
        let contactTest = NSPredicate(format:"SELF MATCHES %@", contactRegEx)
        return contactTest.evaluate(with: self)
    }
    
    func validateBankAccNo() -> Bool{
        let accountRegEx = "^[0-9]{10,15}$"
        let accountTest = NSPredicate(format:"SELF MATCHES %@", accountRegEx)
        return accountTest.evaluate(with: self)
    }
}

// MARK: - Character check
extension String {
    
    func removeFormatAmount() -> Double {
        let formatter = NumberFormatter()
        
        formatter.locale = Locale(identifier: "en_US")
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.decimalSeparator = ","
        
        return formatter.number(from: self) as! Double? ?? 0
    }
    
    
    func trimmedString() -> String {
        return self.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
    }
    
    func strikeThrough() -> NSAttributedString {
        let attributeString =  NSMutableAttributedString(string: self)
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: NSMakeRange(0,attributeString.length))
        return attributeString
    }
    
    func replace(_ string:String, replacement:String) -> String {
        return self.replacingOccurrences(of: string, with: replacement, options: NSString.CompareOptions.literal, range: nil)
    }
    
    func contains(find: String) -> Bool{
        return self.range(of: find, options: String.CompareOptions.caseInsensitive) != nil
    }
    
    func trimWhiteSpace(newline: Bool = false) -> String {
        if newline {
            return self.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        } else {
            return self.trimmingCharacters(in: NSCharacterSet.whitespaces)
        }
    }
    
    func removeSpecial(_ character: String) -> String {
        let okayChars : Set<Character> = Set("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890")
        return String(self.filter {okayChars.contains($0) })
    }
    
    func suffixNumber() -> String {
        let number: NSNumber = NSNumber(value: Int64(self) ?? 0)
        var num:Double = number.doubleValue
        let sign = ((num < 0) ? "-" : "" )

        num = fabs(num)

        if (num < 1000.0) {
            return "\(sign)\(num)";
        }

        let exp:Int = Int(log10(num) / 3.0 ); //log10(1000));

        let units:[String] = ["K","M","G","T","P","E"];

        let roundedNum:Double = round(10 * num / pow(1000.0,Double(exp))) / 10;
        
        return "\(sign)\(roundedNum)\(units[exp-1])"
    }
    
    func numberFormet(pattern: String) -> String {
        var pureNumber = self.replacingOccurrences( of: "[^0-9]", with: "", options: .regularExpression)
        for index in 0 ..< pattern.count {
            guard index < pureNumber.count else { return pureNumber }
            let stringIndex = String.Index(utf16Offset: index, in: String(pattern))
            let patternCharacter = pattern[stringIndex]
            guard patternCharacter != "#" else { continue }
            pureNumber.insert(patternCharacter, at: stringIndex)
        }
        return String(pureNumber.prefix(pattern.count))
    }

}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
    
    func setAttriTitle(isRequired: Bool) -> NSAttributedString {
        let mutatingAttributedString = NSMutableAttributedString(string: self)
        if isRequired {
            let asterix = NSAttributedString(string: "*", attributes: [.foregroundColor: UIColor.red])
            mutatingAttributedString.append(asterix)
        }
        return mutatingAttributedString
    }
}

extension String {
    func localized(comment: String = "") -> String {
        return NSLocalizedString(self, comment: comment)
    }
}


// MARK: - Layout
extension String {
    
    var length: Int {
        return (self as NSString).length
    }
    
    func isEqual(str: String) -> Bool {
        if self.compare(str) == ComparisonResult.orderedSame{
            return true
        }else{
            return false
        }
    }
    
    func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: [NSStringDrawingOptions.usesLineFragmentOrigin], attributes: [NSAttributedString.Key.font: font], context: nil)
        return boundingBox.height
    }
    
    func singleLineHeight(font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: [NSStringDrawingOptions.usesLineFragmentOrigin], attributes: [NSAttributedString.Key.font: font], context: nil)
        return boundingBox.height
    }
    
    func WidthWithNoConstrainedHeight(font: UIFont) -> CGFloat {
        let width = CGFloat.greatestFiniteMagnitude
        let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return boundingBox.width
    }
}

extension Data {
    var html2AttributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: self, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            print("error:", error)
            return  nil
        }
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
}

extension String {
    var html2AttributedString: NSAttributedString? {
        return Data(utf8).html2AttributedString
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
}
