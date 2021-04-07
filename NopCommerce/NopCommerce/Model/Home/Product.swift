//
//  Product.swift
//  NopCommerce
//
//  Created by Chirag Patel on 14/03/20.
//  Copyright © 2020 Chirag Patel. All rights reserved.
//

import Foundation

enum EnumProductType: String {
    case simple = "SimpleProduct"
    case grouped = "GroupedProduct"
}

class Product {
    
    let id: String
    let proType: EnumProductType
    let name: String
    let shortDesc: String
    var fullDesc: String
    var objPrice: ProductPrice?
    var objPictureModel: PictureModel?
    
    var attributeFullDesc: NSAttributedString? {
        return fullDesc.html2AttributedString
    }
    
    init(dict: NSDictionary) {
        id = dict.getStringValue(key: "Id")
        proType = EnumProductType(rawValue: dict.getStringValue(key: "ProductType")) ?? .simple
        name = dict.getStringValue(key: "Name")
        shortDesc = dict.getStringValue(key: "ShortDescription")
        fullDesc = dict.getStringValue(key: "FullDescription")
        
        if let priceDict = dict["ProductPrice"] as? NSDictionary {
            self.objPrice = ProductPrice(dict: priceDict)
        }
        if let pictureDict = dict["DefaultPictureModel"] as? NSDictionary {
            self.objPictureModel = PictureModel(dict: pictureDict)
        }
    }
}

class ProductDetail {
    
    let showSku: Bool
    let showManufacturePartNumber: Bool
    let showGtin: Bool
    let showVendor: Bool
    let isShippingEnable: Bool
    let isFreeShipping: Bool
    let isRental: Bool
    let hasSampleDownload: Bool
    let displayBackInStockSubscription: Bool
    
    let id: String
    let proType: EnumProductType
    var fullDesc: String
    let shortDesc: String
    let name: String
    let seName: String
    let sku: String
    let manufacturPartNumber: String
    let gtin: String
    let deliveryDate: String
    let stockAvailabitity: String
    
    var strQuantity: String = "1"
    var selectedImg: UIImage?
    var rentalStartDate: String = Date.localDateString(from: Date(), format: "MM/dd/yyyy")
    var rentalEndDate: String = Date.localDateString(from: Date(), format: "MM/dd/yyyy")
    
    var objPrice: ProductPrice?
    var objVendor: CommonModel?
    var objReview: Review?
    var objStock: BackInStockModel?
    var objGiftCard: GiftCard?
    var objPictureModel: PictureModel?
    var objCart: AddToCart?
    
    var arrTags: [CommonModel] = []
    var arrPictures: [PictureModel] = []
    var arrSpecification: [Specification] = []
    var arrManufacturers:[CommonModel] = []
    var arrTierPrice: [TierPrice] = []
    var arrAttribues: [ProductAttributes] = []
    var arrAssociatedProduct: [ProductDetail] = []
    var arrGiftCard: [UserField] = []
    var arrCartFields: [UserField] = []
    
    var attributeFullDesc: NSAttributedString? {
        return fullDesc.html2AttributedString
    }
    
    var isGiftCard: Bool {
        return objGiftCard?.isGiftCard ?? false
    }
    
    var isCustomerEnterPrice: Bool {
        return objCart?.isCustomEnterPrice ?? false
    }
    
    func giftCartDict() -> [String: Any] {
        var dict: [String: Any] = [:]
        dict["RecipientName"] = arrGiftCard[0].text
        dict["RecipientEmail"] = arrGiftCard[1].text
        dict["SenderName"] = arrGiftCard[2].text
        dict["SenderEmail"] = arrGiftCard[3].text
        dict["Message"] = arrGiftCard[4].text
        return dict
    }
    

    func prepareAttributeParams(isAttriLoaded: Bool = true) -> [String] {
        var arrAttri: [String] = []
        for(_,attri) in self.arrAttribues.enumerated() {
            if attri.controlType == .txtField || attri.controlType == .txtView || attri.controlType == .datePicker {
                let objStr = "product_attribute_\(id)_\(attri.attrId)_\(attri.id)_\(attri.value)"
                arrAttri.append(objStr)
            } else {
                if attri.arrAttributesValues != nil && !attri.arrAttributesValues.isEmpty {
                    let arrSelectedVal = attri.arrAttributesValues.filter{$0.isPreSelected}
                    let strSelectedId = arrSelectedVal.map{"\($0.id)"}.filter{!$0.isEmpty}.joined(separator: ",")
                    if !(strSelectedId.isEmpty && attri.controlType == .checkBox) {
                        let strSubAttriVal = arrSelectedVal.isEmpty ? "\(attri.arrAttributesValues[0].id)" : strSelectedId
                        if isAttriLoaded {
                            let objStr = "product_attribute_\(id)_\(attri.id)_\(attri.arrAttributesValues[0].atriMapId)_\(strSubAttriVal)"
                            arrAttri.append(objStr)
                        } else {
                            let objStr = "product_attribute_\(id)_\(attri.attrId)_\(attri.arrAttributesValues[0].atriMapId)_\(strSubAttriVal)"
                            arrAttri.append(objStr)
                        }
                        
                    }
                }
            }
        }
        return arrAttri
    }
    
    func changeAttriDict() -> [String: Any] {
        var dict: [String: Any] = [:]
        dict["ApiSecretKey"] = secretKey
        dict["CustomerGUID"] = _user.guid
        dict["StoreId"] = storeId
        dict["CurrencyId"] = currencyId
        dict["Quantity"] = arrCartFields[arrCartFields.firstIndex{$0.keyboardType == .numberPad}!].text
        dict["ProductId"] = id
        dict["AttributeControlIds"] = prepareAttributeParams()
        return dict
    }
    
    func paramDict(isCart: Bool) -> [String: Any] {
        var dict: [String: Any] = [:]
        dict["ApiSecretKey"] = secretKey
        dict["CustomerGUID"] = _user.guid
        dict["StoreId"] = storeId
        dict["CurrencyId"] = currencyId
        dict["ShoppingCartTypeId"] = isCart ? "1" : "2"
        dict["Quantity"] = arrCartFields[arrCartFields.firstIndex{$0.keyboardType == .numberPad}!].text
        dict["ProductId"] = id
        
        if isGiftCard {
            dict["GiftCardDetails"] = giftCartDict()
        }
        if isRental {
            dict["RentalStartDate"] = rentalStartDate
            dict["RentalEndDate"] = rentalEndDate
        }
        if isCustomerEnterPrice {
            let priceIdx = arrCartFields.firstIndex{$0.keyboardType == .decimalPad}
            dict["CustomerEnterPrice"] = arrCartFields[priceIdx!].text
        }
        dict["AttributeControlIds"] = prepareAttributeParams(isAttriLoaded: false)
        return dict
    }
    
    func validatetData() -> (isValid: Bool, error: String) {
        var result = (isValid: true, error: "")
        
        if isGiftCard {
            if String.validateStringValue(str: arrGiftCard[0].text){
                result.isValid = false
                result.error = kEnterName
                return result
            }
            if String.validateStringValue(str: arrGiftCard[1].text){
                result.isValid = false
                result.error = kEnterEmail
                return result
            } else if !arrGiftCard[1].text.isValidEmailAddress() {
                result.isValid = false
                result.error = kInvalidEmail
                return result
            }
            if String.validateStringValue(str: arrGiftCard[2].text){
                result.isValid = false
                result.error = kEnterName
                return result
            }
            if String.validateStringValue(str: arrGiftCard[3].text){
                result.isValid = false
                result.error = kEnterEmail
                return result
            } else if !arrGiftCard[3].text.isValidEmailAddress() {
                result.isValid = false
                result.error = kInvalidEmail
                return result
            }
            if String.validateStringValue(str: arrGiftCard[4].text){
                result.isValid = false
                result.error = kEnterMessage
                return result
            }
        }
        
        for attri in self.arrAttribues {
            if attri.controlType == .txtField || attri.controlType == .txtView || attri.controlType == .datePicker {
                if String.validateStringValue(str: attri.value) {
                    result.isValid = false
                    result.error = "Please enter \(attri.name)"
                    return result
                }
            }
        }
        
        if isRental {
            if String.validateStringValue(str: rentalStartDate){
                result.isValid = false
                result.error = kEnterDob
                return result
            }
            if String.validateStringValue(str: rentalEndDate){
                result.isValid = false
                result.error = kEnterDob
                return result
            }
        }
        
        if isCustomerEnterPrice {
            let priceIdx = arrCartFields.firstIndex{$0.keyboardType == .decimalPad}
            if String.validateStringValue(str: arrCartFields[priceIdx!].text){
                result.isValid = false
                result.error = kEnterPrice
                return result
            }
        }
        
        let qtyIdx = arrCartFields.firstIndex{$0.keyboardType == .numberPad}
        if String.validateStringValue(str: arrCartFields[qtyIdx!].text) {
            result.isValid = false
            result.error = kEnterQty
            return result
        } else {
            guard let qty = Int(arrCartFields[qtyIdx!].text), qty > 0 else {
                result.isValid = false
                result.error = "Quantity should me minimum 1"
                return result
            }
        }
        return result
    }
    
     func getGiftCardData() {
        var t1 = UserField()
        t1.title = getLocalizedKey(str: "products.giftcard.recipientname")
        t1.text = objGiftCard?.receiptientName ?? ""
        arrGiftCard.append(t1)
        
        var t2 = UserField()
        t2.title = getLocalizedKey(str: "products.giftcard.recipientemail")
        t2.text = objGiftCard?.receiptientEmail ?? ""
        t2.keyboardType = .emailAddress
        arrGiftCard.append(t2)
        
        var t3 = UserField()
        t3.title = getLocalizedKey(str: "products.giftcard.sendername")
        t3.text = objGiftCard?.senderName ?? ""
        arrGiftCard.append(t3)
        
        var t4 = UserField()
        t4.title = getLocalizedKey(str: "products.giftcard.senderemail")
        t4.keyboardType = .emailAddress
        t4.keyBoardReturnKey = .done
        t4.text = objGiftCard?.senderEmail ?? ""
        arrGiftCard.append(t4)
        
        var t5 = UserField()
        t5.title = getLocalizedKey(str: "products.giftcard.message")
        t5.text = objGiftCard?.message ?? ""
        t5.fieldType = .txtViewCell
        arrGiftCard.append(t5)
    }
    
     func getAddToCartData() {
        
        if isRental {
            var t1 = UserField()
            t1.fieldType = .dobCell
            t1.text = objPrice?.rentalPrice ?? ""
            arrCartFields.append(t1)
        }
        
        if isCustomerEnterPrice {
            var t2 = UserField()
            t2.fieldType = .dobCell
            t2.title = getLocalizedKey(str: "products.enterproductprice")
            t2.text = "\(objCart?.customEnteredPrice ?? 0.0)"
            t2.keyboardType = .decimalPad
            arrCartFields.append(t2)
        }
        
        if proType == .simple {
            var t3 = UserField()
            t3.title = getLocalizedKey(str: "products.productattributes.priceadjustment.quantity")
            t3.text = objCart!.arrQuantity.isEmpty ? "\(objCart?.enteredQty ?? 1)" : objCart!.arrQuantity[0].value
            t3.keyboardType = .numberPad
            arrCartFields.append(t3)
        }
    }
    
    func getProductInfo() -> [(header: String, footer: String)] {
        var data: [(header: String, footer: String)] = []
        
        if !stockAvailabitity.isEmpty {
            data.append((getLocalizedKey(str: "products.availability"), stockAvailabitity))
        } else if displayBackInStockSubscription, let stock = objStock {
            data.append(("", stock.title))
        }
        
        if !arrManufacturers.isEmpty {
            data.append((getLocalizedKey(str: "products.manufacturers"), arrManufacturers.map{$0.name}.joined(separator: ",")))
        }
        if showSku {
            data.append((getLocalizedKey(str: "products.sku"), sku))
        }
        
        if showVendor, let vendor = objVendor {
            data.append((getLocalizedKey(str: "products.vendor"), vendor.name))
        }
        
        if !deliveryDate.isEmpty {
            data.append((getLocalizedKey(str: "products.deliverydate"), deliveryDate))
        }
        
        if hasSampleDownload {
            data.append(("", getLocalizedKey(str: "products.downloadsample")))
        }
        
        return data
    }
    
    init(dict: NSDictionary) {
        // BOOl
        showSku = dict.getBooleanValue(key: "ShowSku")
        showManufacturePartNumber = dict.getBooleanValue(key: "ShowManufacturerPartNumber")
        showGtin = dict.getBooleanValue(key: "ShowGtin")
        showVendor = dict.getBooleanValue(key: "ShowVendor")
        hasSampleDownload = dict.getBooleanValue(key: "HasSampleDownload")
        isShippingEnable = dict.getBooleanValue(key: "IsShipEnabled")
        isFreeShipping = dict.getBooleanValue(key: "IsFreeShipping")
        isRental = dict.getBooleanValue(key: "IsRental")
        displayBackInStockSubscription = dict.getBooleanValue(key: "DisplayBackInStockSubscription")
        
        // String
        id = dict.getStringValue(key: "Id")
        name = dict.getStringValue(key: "Name")
        seName = dict.getStringValue(key: "SeName")
        proType = EnumProductType(rawValue: dict.getStringValue(key: "ProductType")) ?? .simple
        fullDesc = dict.getStringValue(key: "FullDescription")
        sku = dict.getStringValue(key: "Sku")
        manufacturPartNumber = dict.getStringValue(key: "ManufacturerPartNumber")
        gtin = dict.getStringValue(key: "Gtin")
        deliveryDate = dict.getStringValue(key: "DeliveryDate")
        stockAvailabitity = dict.getStringValue(key: "StockAvailability")
        shortDesc = dict.getStringValue(key: "ShortDescription")
        rentalStartDate = dict.getStringValue(key: "RentalStartDate")
        rentalEndDate = dict.getStringValue(key: "RentalEndDate")
        
        if let priceDict = dict["ProductPrice"] as? NSDictionary {
            self.objPrice = ProductPrice(dict: priceDict)
        }
        
        if let vendorDict = dict["VendorModel"] as? NSDictionary {
            objVendor = CommonModel(dict: vendorDict)
        }
        
        if let reviewDict = dict["ProductReviewOverview"] as? NSDictionary {
            objReview = Review(dict: reviewDict)
        }
        
        if let stockDict = dict["BackInStockSubscribeResponseModel"] as? NSDictionary {
            objStock = BackInStockModel(dict: stockDict)
        }
        
        if let pictureDict = dict["DefaultPictureModel"] as? NSDictionary {
            self.objPictureModel = PictureModel(dict: pictureDict)
        }
        
        if let giftDict = dict["GiftCard"] as? NSDictionary {
            objGiftCard = GiftCard(dict: giftDict)
        }
        
        if let cartDict = dict["AddToCart"] as? NSDictionary {
            objCart = AddToCart(dict: cartDict)
        }
        
        if let allProductPictures = dict["PictureModels"] as? [NSDictionary] {
            for productDict in allProductPictures {
                let objProduct = PictureModel(dict: productDict)
                self.arrPictures.append(objProduct)
            }
        }
        
        if let allProductTags = dict["ProductTags"] as? [NSDictionary] {
            for tagDict in allProductTags {
                let objTag = CommonModel(dict: tagDict)
                self.arrTags.append(objTag)
            }
        }
        
        if let allSpecifications = dict["ProductSpecifications"] as? [NSDictionary] {
            for specsDict in allSpecifications {
                let objSpec = Specification(dict: specsDict)
                self.arrSpecification.append(objSpec)
            }
        }
        
        if let allManufacturers = dict["ProductManufacturers"] as? [NSDictionary] {
            for manufacturerDict in allManufacturers {
                let objManufacturer = CommonModel(dict: manufacturerDict)
                self.arrManufacturers.append(objManufacturer)
            }
        }
        
        if let allTiers = dict["TierPrices"] as? [NSDictionary] {
            for tierDict in allTiers {
                let objTier = TierPrice(dict: tierDict)
                self.arrTierPrice.append(objTier)
            }
        }
        
        if let allAttrubutes = dict["ProductAttributes"] as? [NSDictionary] {
            for attriDict in allAttrubutes {
                let objAtttribute = ProductAttributes(dict: attriDict)
                self.arrAttribues.append(objAtttribute)
            }
        }
        
        if let allAssociatedProducts = dict["AssociatedProducts"] as? [NSDictionary] {
            for associatedDict in allAssociatedProducts {
                let objProduct = ProductDetail(dict: associatedDict)
                self.arrAssociatedProduct.append(objProduct)
            }
        }
        self.getGiftCardData()
        self.getAddToCartData()
    }
}

class ProductPrice {
    
    let oldPrice: String
    var price: String = ""
    let disableBuyButton: Bool
    let disableWishListButton: Bool
    let availableForPreOrder: Bool
    let isRental: Bool
    let rentalPrice: String
    let displayTaxInfo: Bool
    
    init(dict: NSDictionary) {
        oldPrice = dict.getStringValue(key: "OldPrice")
        price = dict.getStringValue(key: "Price")
        disableBuyButton = dict.getBooleanValue(key: "DisableBuyButton")
        disableWishListButton = dict.getBooleanValue(key: "DisableWishlistButton")
        availableForPreOrder = dict.getBooleanValue(key: "AvailableForPreOrder")
        isRental = dict.getBooleanValue(key: "IsRental")
        rentalPrice = dict.getStringValue(key: "RentalPrice")
        displayTaxInfo = dict.getBooleanValue(key: "DisplayTaxShippingInfo")
    }
}

class Specification {
    
    let id: String
    let name: String
    let text: String
    let colorCode: String
    
    var color: UIColor {
        return UIColor.hexStringToUIColor(hexStr: colorCode)
    }
    
    init(dict: NSDictionary) {
        id = dict.getStringValue(key: "SpecificationAttributeId")
        name = dict.getStringValue(key: "SpecificationAttributeName")
        text = dict.getStringValue(key: "ValueRaw")
        colorCode = dict.getStringValue(key: "ColorSquaresRgb")
    }
}

class AddToCart {
    
    let proId: String
    let isRental: Bool
    let enteredQty: Int
    let isCustomEnterPrice: Bool
    var customEnteredPrice: Double
    let customPriceRange: String
    var arrQuantity: [Quantity] = []
    
    init(dict: NSDictionary) {
        proId = dict.getStringValue(key: "ProductId")
        isRental = dict.getBooleanValue(key: "IsRental")
        isCustomEnterPrice = dict.getBooleanValue(key: "CustomerEntersPrice")
        customPriceRange = dict.getStringValue(key: "CustomerEnteredPriceRange")
        enteredQty = dict.getIntValue(key: "EnteredQuantity")
        customEnteredPrice = dict.getDoubleValue(key: "CustomerEnteredPrice")
        if let allQuantity = dict["AllowedQuantities"] as? [NSDictionary] {
            for quntityDict in allQuantity {
                self.arrQuantity.append(Quantity(dict: quntityDict))
            }
        }
    }
}

class GiftCard {
    
    let isGiftCard: Bool
    let receiptientName: String
    let receiptientEmail: String
    let senderName: String
    let senderEmail: String
    var message: String
    
    init(dict: NSDictionary) {
        isGiftCard = dict.getBooleanValue(key: "IsGiftCard")
        receiptientName = dict.getStringValue(key: "RecipientName")
        receiptientEmail = dict.getStringValue(key: "RecipientEmail")
        senderName = dict.getStringValue(key: "SenderName")
        senderEmail = dict.getStringValue(key: "SenderEmail")
        message = dict.getStringValue(key: "Message")
    }
}


class Review {
    
    let id: String
    let customerName: String
    let title: String
    let text: String
    let rating: Int
    let date: String
    let proId: String
    let totalReview: Int
    let overAllSum: Int
    
    var isReviewGiven: Bool {
        return overAllSum > 0
    }
    
    var avgSum: Double {
        return Double(overAllSum) / Double(totalReview)
    }
    
    init(dict: NSDictionary) {
        id = dict.getStringValue(key: "Id")
        customerName = dict.getStringValue(key: "CustomerName")
        title = dict.getStringValue(key: "Title")
        text = dict.getStringValue(key: "ReviewText")
        rating = dict.getIntValue(key: "Rating")
        date = dict.getStringValue(key: "WrittenOnStr")
        proId = dict.getStringValue(key: "ProductId")
        totalReview = dict.getIntValue(key: "TotalReviews")
        overAllSum = dict.getIntValue(key: "RatingSum")
    }
}

class CommonModel {
    
    let id: String
    let count: Int
    let name: String
    let seName: String
    
    var tagName: String {
        return "\(name)(\(count))"
    }
    
    init(dict: NSDictionary) {
        id = dict.getStringValue(key: "Id")
        count = dict.getIntValue(key: "ProductCount")
        name = dict.getStringValue(key: "Name")
        seName = dict.getStringValue(key: "SeName")
    }
}

class BackInStockModel {
    
    let title: String
    let message: String
    let desc: String
    
    var alreadySubscriped: Bool
    let subscriptionAllowed: Bool
    
    init(dict: NSDictionary) {
        title = dict.getStringValue(key: "PopupTitle")
        message = dict.getStringValue(key: "BackInStockMessage")
        desc = dict.getStringValue(key: "BackInStockDescription")
        
        alreadySubscriped = dict.getBooleanValue(key: "AlreadySubscribed")
        subscriptionAllowed = dict.getBooleanValue(key: "SubscriptionAllowed")
    }
}

class TierPrice {
    let price: String
    let quantity: Int
    
    init(dict: NSDictionary) {
        price = dict.getStringValue(key: "Price")
        quantity = dict.getIntValue(key: "Quantity")
    }
}

class ProductAttributes {
    
    let id: String
    let proId: String
    let attrId: String
    let name: String
    let textPromt: String
    let hasCondition: Bool
    let isRequired: Bool
    let controlType: EnumProductAttribuesType
    var value: String = ""
    var arrAttributesValues: [ProductAttributesValues]!
    
    enum EnumProductAttribuesType: String {
        case dropDown = "DropdownList"
        case colors = "ColorSquares"
        case image = "ImageSquares"
        case radio = "RadioList"
        case checkBox = "Checkboxes"
        case txtView = "MultilineTextbox"
        case txtField = "TextBox"
        case upload = "FileUpload"
        case datePicker = "Datepicker"
        case none = ""
                
        var cellIdentifier: String {
            switch self {
            case .dropDown:
                return "dropDownCell"
            case .colors, .image, .checkBox, .radio:
                return "colorCell"
            case .datePicker:
                return "dobCell"
            case .txtView:
                return "txtViewCell"
            case .txtField:
                return "txtCell"
            case .upload:
                return "uploadCell"
            default:
                return ""
            }
        }
        
        var cellHeight: CGFloat {
            switch self {
            case .dropDown:
                return 65.widthRatio
            case .colors, .image, .checkBox, .radio, .datePicker:
                return 75.widthRatio
            case .txtView:
                return 120.widthRatio
            case .upload, .txtField:
                return 70.widthRatio
            default:
                return 0
            }
        }
    }
    
    init(dict: NSDictionary) {
        id = dict.getStringValue(key: "Id")
        proId = dict.getStringValue(key: "ProductId")
        attrId = dict.getStringValue(key: "ProductAttributeId")
        name = dict.getStringValue(key: "Name")
        textPromt = dict.getStringValue(key: "TextPrompt")
        hasCondition = dict.getBooleanValue(key: "HasCondition")
        value = dict.getStringValue(key: "DefaultValue")
        isRequired = dict.getBooleanValue(key: "IsRequired")
        controlType = EnumProductAttribuesType(rawValue: dict.getStringValue(key: "AttributeControlType")) ?? .none
        
        if let arrAllAttribuesValue = dict["Values"] as? [NSDictionary] {
            self.arrAttributesValues = []
            for attriDict in arrAllAttribuesValue {
                let objSubAttriDict = ProductAttributesValues(dict: attriDict)
                self.arrAttributesValues.append(objSubAttriDict)
            }
        }
    }
}

class ProductAttributesValues {
  
    let id: Int
    let picId: Int
    let atriMapId: Int
    let name: String
    let colorRGB: String
    let price: Double
    let priceAdjustment: String
    var isPreSelected: Bool
    let strPicture: String
    let strFullSizePicture: String
    
    var value: String = ""
    
    var color: UIColor {
        return UIColor.hexStringToUIColor(hexStr: colorRGB)
    }
    
    var imgUrl: URL? {
        return URL(string: strPicture)
    }
    
    var bigImgUrl: URL? {
        return URL(string: strFullSizePicture)
    }
    
    var priceValue: String {
        return "\(name)\(priceAdjustment.isEmpty ? "" : "[\(priceAdjustment)]")"
    }
    
    init(dict: NSDictionary) {
        id = dict.getIntValue(key: "Id")
        atriMapId = dict.getIntValue(key: "ProductAttributeMappingId")
        picId = dict.getIntValue(key: "PictureId")
        name = dict.getStringValue(key: "Name")
        value = dict.getStringValue(key: "Name")
        colorRGB = dict.getStringValue(key: "ColorSquaresRgb")
        price = dict.getDoubleValue(key: "PriceAdjustmentValue")
        priceAdjustment = dict.getStringValue(key: "PriceAdjustment")
        isPreSelected = dict.getBooleanValue(key: "IsPreSelected")
        strPicture = dict.getStringValue(key: "PictureUrl")
        strFullSizePicture = dict.getStringValue(key: "FullSizePictureUrl")
    }
}
