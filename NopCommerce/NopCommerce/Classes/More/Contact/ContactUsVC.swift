//
//  ContactUsVC.swift
//  NopCommerce
//
//  Created by Chirag Patel on 11/03/20.
//  Copyright © 2020 Chirag Patel. All rights reserved.
//

import UIKit

class ContactUsVC: ParentViewController {

    @IBOutlet var btnTopMenu: UIButton!
    @IBOutlet var btnTopBack: UIButton!
     
    var contactTopic: TopicDetail!
    var isFromSlideMenu = false
    
    var strName = ""
    var strEmail = ""
    var strMsg = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        getContactData()
    }
}

extension ContactUsVC {
    
    func prepareUI() {
        lblHeaderTitle?.text = getLocalizedKey(str: "pagetitle.contactus")
        btnTopBack.isHidden = isFromSlideMenu
        btnTopMenu.isHidden = !isFromSlideMenu
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        setUserUI()
        setKeyboardNotifications()
    }
    
    func setUserUI() {
        if !_user.isGuestLogin {
            strName = _user.fullName
            strEmail = _user.email
        }
    }
}

extension ContactUsVC {
    
    @IBAction func btnSubmitTapped(_ sender: UIButton) {
        self.view.endEditing(true)
        if strName.isEmpty {
           JTValidationToast.show(message: kEnterName)
        } else if strEmail.isEmpty {
           JTValidationToast.show(message: kEnterEmail)
        } else if !strEmail.isValidEmailAddress() {
           JTValidationToast.show(message: kInvalidEmail)
        } else if strMsg.isEmpty {
           JTValidationToast.show(message: kEnterMessage)
        } else {
            self.submitContactData()
        }
    }
}

extension ContactUsVC {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return contactTopic == nil ? 0 : 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? contactTopic.body.isEmpty ? 0 : 1 : 4
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return UITableView.automaticDimension
        } else {
            return indexPath.row == 0 || indexPath.row == 1 ? 60.widthRatio : indexPath.row == 2 ? 120.widthRatio : 55.widthRatio
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ContactTableCell
        let cellId = indexPath.section == 0 ? "topicCell" : "cell\(indexPath.row)"
        cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ContactTableCell
        if indexPath.section == 0 {
            cell.lblContactBody.attributedText = contactTopic.bodyDesc
        } else {
            cell.parentContact = self
            cell.prepareContactUI(idx: indexPath.row)
        }
        return cell
    }
}

extension ContactUsVC {
    
    func getContactData() {
        showHud()
        let params : [String: Any] = ["ApiSecretKey":secretKey, "CustomerGUID":_user.guid, "StoreId":storeId,"LanguageId":languageId,"SystemName":"ContactUs","IsHtmlL":"false"]
        KPWebCall.call.getHomeWelcomeText(param: params) { [weak self] (json, statusCode) in
            guard let weakself = self else {return}
            weakself.hideHud()
            if statusCode == 200, let dict = json as? NSDictionary, let status = dict["Status"] as? Bool, status {
                if let jsonData = dict["Data"] as? NSDictionary {
                    weakself.contactTopic = TopicDetail(dict: jsonData)
                }
                weakself.tableView.reloadData()
            } else {
                weakself.showError(data: json, view: weakself.view)
            }
        }
    }
    
    func submitContactData()  {
        showHud()
        let contactParam: [String: Any] = ["Email": strEmail, "Enquiry": strMsg, "FullName": strName]
        let params : [String: Any] = ["ApiSecretKey":secretKey,"StoreId":storeId,"LanguageId":languageId, "ContactUsRequest": contactParam]
        KPWebCall.call.submitContactUs(param: params) { [weak self] (json, statusCode) in
            guard let weakself = self else {return}
            weakself.hideHud()
            if statusCode == 200, let dict = json as? NSDictionary, let status = dict["Status"] as? Bool, status {
                if let jsonData = dict["Data"] as? NSDictionary {
                    weakself.showSuccessMsg(data: jsonData, view: weakself.view)
                }
            } else {
                weakself.showError(data: json, view: weakself.view)
            }
        }
    }
}
