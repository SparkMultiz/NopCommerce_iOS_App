//
//  TopicDetail.swift
//  NopCommerce
//
//  Created by Chirag Patel on 14/03/20.
//  Copyright © 2020 Chirag Patel. All rights reserved.
//

import Foundation

class TopicDetail {
    
    let title: String
    let body: String
    
    var isTopicEmpty: Bool {
        return title.isEmpty && body.isEmpty
    }
    
    var bodyDesc: NSAttributedString? {
        return body.html2AttributedString
    }
    
    init(dict: NSDictionary) {
        title = dict.getStringValue(key: "Title")
        body = dict.getStringValue(key: "Body")
    }
    
}
