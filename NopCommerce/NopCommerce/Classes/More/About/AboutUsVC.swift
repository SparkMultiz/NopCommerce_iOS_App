//
//  AboutUsVC.swift
//  NopCommerce
//
//  Created by Chirag Patel on 18/03/20.
//  Copyright © 2020 Chirag Patel. All rights reserved.
//

import UIKit

class AboutUsVC: ParentViewController {

    var objTopic: TopicDetail!
    var isPrivacyPolicy = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
    }
}

extension AboutUsVC {
    
    func prepareUI() {
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        getTopicData(serviceName: isPrivacyPolicy ? "PrivacyInfo" : "AboutUs")
    }
}

extension AboutUsVC {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return objTopic == nil ? 0 : 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ContactTableCell
        cell = tableView.dequeueReusableCell(withIdentifier: "topicCell", for: indexPath) as! ContactTableCell
        cell.lblContactBody.attributedText = objTopic.bodyDesc
        return cell
    }
}

extension AboutUsVC {
    
    func getTopicData(serviceName: String) {
        showHud()
        let params : [String: Any] = ["ApiSecretKey":secretKey, "CustomerGUID":_user.guid, "StoreId":storeId,"LanguageId":languageId,"SystemName":serviceName,"IsHtmlL":"false"]
        KPWebCall.call.getHomeWelcomeText(param: params) { [weak self] (json, statusCode) in
            guard let weakself = self else {return}
            weakself.hideHud()
            if statusCode == 200, let dict = json as? NSDictionary, let status = dict["Status"] as? Bool, status {
                if let jsonData = dict["Data"] as? NSDictionary {
                    weakself.objTopic = TopicDetail(dict: jsonData)
                }
                weakself.lblHeaderTitle?.text = weakself.objTopic.title
                weakself.tableView.reloadData()
            } else {
                weakself.showError(data: json, view: weakself.view)
            }
        }
    }
}
