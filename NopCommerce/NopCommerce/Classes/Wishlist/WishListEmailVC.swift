//
//  WishListEmailVC.swift
//  NopCommerce
//
//  Created by Chirag Patel on 11/03/20.
//  Copyright © 2020 Chirag Patel. All rights reserved.
//

import UIKit

class WishListEmailVC: ParentViewController {

    var strEmail = ""
    var strFrndEmail = ""
    var strMsg = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
    }
}

extension WishListEmailVC {
    
    func prepareUI() {
        lblHeaderTitle?.text = getLocalizedKey(str: "wishlist.emailafriend.title")
        if !_user.isGuestLogin {
            strEmail = _user.email
        }
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        setKeyboardNotifications()
    }
}

extension WishListEmailVC {
    
    @IBAction func btnSendEmailTapped(_ sender: UIButton) {
        self.view.endEditing(true)
        if strFrndEmail.isEmpty {
           JTValidationToast.show(message: getLocalizedKey(str: "products.emailafriend.friendemail.required"))
        } else {
            self.emailWishList()
        }
    }
}

extension WishListEmailVC {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 0 || indexPath.row == 1 ? 60.widthRatio : indexPath.row == 2 ? 120.widthRatio : 55.widthRatio
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ContactTableCell
        cell = tableView.dequeueReusableCell(withIdentifier: "cell\(indexPath.row)", for: indexPath) as! ContactTableCell
        cell.parent = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let emailCell = cell as? ContactTableCell {
            emailCell.prepareEmailWishListUI(idx: indexPath.row)
        }
    }
}

extension WishListEmailVC {
    
    func emailWishList() {
        showHud()
        let params : [String: Any] = ["ApiSecretKey":secretKey,"CustomerGUID": _user.guid, "LanguageId": languageId,"StoreId": storeId, "YourEmailAddress": strEmail, "PersonalMessage": strMsg, "FriendEmail": strFrndEmail]
        KPWebCall.call.emailWishListToFriend(param: params) { [weak self] (json, statusCode) in
            guard let weakself = self else {return}
            weakself.hideHud()
            if statusCode == 200, let dict = json as? NSDictionary, let status = dict["Status"] as? Bool, status {
                weakself.showSuccMsg(dict: dict)
            } else {
                weakself.showError(data: json, view: weakself.view)
            }
        }
    }
}
