//
//  FilterModel.swift
//  NopCommerce
//
//  Created by Chirag Patel on 16/03/20.
//  Copyright © 2020 Chirag Patel. All rights reserved.
//

import Foundation

class FilterModel {
    
    var arrSpecFilter: [SpecificationFilter] = []
    var arrPriceFilter: [PriceFilter] = []
    
    var isPriceFilterEmpty: Bool {
        return arrPriceFilter.isEmpty
    }
    
    var arrCount: Int {
        return isPriceFilterEmpty ? arrSpecFilter.count : 1 + arrSpecFilter.count
    }
    
    var selectedPrice: [PriceFilter]? {
        if _filterData != nil {
            return _filterData.arrPriceFilter.filter{$0.selected}
        }
        return nil
    }
    
    init() { }
    
    init(dict: NSDictionary) {
        if let arrSpecs = dict["SpecificationFilter"] as? [NSDictionary] {
            for specDict in arrSpecs {
                let objSpec = SpecificationFilter(dict: specDict)
                self.arrSpecFilter.append(objSpec)
            }
        }
        
        if let arrPrice = dict["PriceRangeFilters"] as? [NSDictionary] {
            for priceDict in arrPrice {
                let objPriceDict = PriceFilter(dict: priceDict)
                let isSelected = selectedPrice == nil ? false : selectedPrice!.contains{$0.to.isEqual(str: objPriceDict.to)}
                objPriceDict.selected = isSelected
                self.arrPriceFilter.append(objPriceDict)
            }
        }
    }
}

class PriceFilter {
    var fromCurrency: String
    let from: String
    let toCurrency: String
    let to: String
    var selected = false
    
    var strTitle: String {
        let strFrom = fromCurrency.isEmpty ? "Under" : fromCurrency
        let strTo = toCurrency.isEmpty ? "Over" : toCurrency
        return "\(strFrom) - \(strTo)"
    }
    
    init(isSelected: Bool = false, dict: NSDictionary) {
        fromCurrency = dict.getStringValue(key: "FromCurrency")
        from = dict.getStringValue(key: "From")
        toCurrency = dict.getStringValue(key: "ToCurrency")
        to = dict.getStringValue(key: "To")
        self.selected = isSelected
    }
}

class SpecificationFilter {
    
    let attributeId: Int
    let attributeName: String
    let attributeDisplayOrder: Int
    var arrAttributeOption: [SpecifiationAttribute] = []
    var isSelected = false
    
    var selectedSpecification: [SpecifiationAttribute]? {
        if _filterData != nil {
            return _filterData.arrSpecFilter.flatMap{$0.arrAttributeOption.filter{$0.selected}}
        }
        return nil
    }
    
    init(dict: NSDictionary) {
        attributeId = dict.getIntValue(key: "SpecificationAttributeId")
        attributeName = dict.getStringValue(key: "SpecificationAttributeName")
        attributeDisplayOrder = dict.getIntValue(key: "SpecificationAttributeDisplayOrder")
        
        if let arrAttriOptions = dict["SpecificationAttributeOptions"] as? [NSDictionary] {
            for option in arrAttriOptions {
                let objOptionDict = SpecifiationAttribute(dict: option)
                let isSelected = selectedSpecification == nil ? false : selectedSpecification!.contains{$0.specId.isEqual(str: objOptionDict.specId)}
                objOptionDict.selected = isSelected
                self.arrAttributeOption.append(objOptionDict)
            }
        }
    }
}

class SpecifiationAttribute {
    let specId: String
    let specName: String
    let specColorRGB: String
    let displayOrder: String
    var selected: Bool = false
    
    init(isSelected: Bool = false ,dict: NSDictionary) {
        specId = dict.getStringValue(key: "SpecificationAttributeOptionId")
        specName = dict.getStringValue(key: "SpecificationAttributeOptionName")
        specColorRGB = dict.getStringValue(key: "SpecificationAttributeColorRGB")
        displayOrder = dict.getStringValue(key: "SpecificationAttributeOptionDisplayOrder")
        self.selected = isSelected
    }
}
