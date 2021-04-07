//
//  Reward.swift
//  NopCommerce
//
//  Created by Chirag Patel on 18/03/20.
//  Copyright © 2020 Chirag Patel. All rights reserved.
//

import Foundation

class Rewards {
    
    let balance: Int
    let amount: String
    var arrHistory: [RewardHistory] = []
    
    init(dict: NSDictionary) {
        balance = dict.getIntValue(key: "RewardPointsBalance")
        amount = dict.getStringValue(key: "RewardPointsAmount")
        
        if let arrHistoryPoints = dict["RewardPoints"] as? [NSDictionary] {
            for rewardDict in arrHistoryPoints {
                self.arrHistory.append(RewardHistory(dict: rewardDict))
            }
        }
    }
}

class RewardHistory {
        
    let id: String
    let balance: String
    let message: String
    var createdOn: Date?
    
    init(dict: NSDictionary) {
        id = dict.getStringValue(key: "Id")
        balance = dict.getStringValue(key: "PointsBalance")
        message = dict.getStringValue(key: "Message")
        createdOn = Date.getISODateFormatConvertor(from: dict.getStringValue(key: "CreatedOn"))
    }
}
