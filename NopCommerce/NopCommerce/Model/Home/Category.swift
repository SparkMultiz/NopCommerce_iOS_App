//
//  Category.swift
//  NopCommerce
//
//  Created by Chirag Patel on 14/03/20.
//  Copyright © 2020 Chirag Patel. All rights reserved.
//

import Foundation

class Category {
    
    let id: String
    let name: String
    var pictureModel: PictureModel?
    
    init(dict: NSDictionary) {
        id = dict.getStringValue(key: "Id")
        name = dict.getStringValue(key: "Name")
        if let pictureDict = dict["PictureModel"] as? NSDictionary {
            self.pictureModel = PictureModel(dict: pictureDict)
        }
    }
}

class PictureModel {
 
    let imgStr: String
    let thumbStr: String
    let fullImgStr: String
    let title: String
    
    var imgUrl: URL? {
        return URL(string: imgStr)
    }
    
    var bigImgUrl: URL? {
        return URL(string: fullImgStr)
    }
    
    init(dict: NSDictionary) {
        imgStr = dict.getStringValue(key: "ImageUrl")
        thumbStr = dict.getStringValue(key: "ThumbImageUrl")
        fullImgStr = dict.getStringValue(key: "FullSizeImageUrl")
        title = dict.getStringValue(key: "Title")
    }
}


class NavoSlider {
    
    let imgStr: String
    let text: String
    
    var imgUrl: URL? {
        return URL(string: imgStr)
    }
    
    init(dict: NSDictionary) {
        imgStr = dict.getStringValue(key: "PictureUrl")
        text = dict.getStringValue(key: "Text")
    }
}
