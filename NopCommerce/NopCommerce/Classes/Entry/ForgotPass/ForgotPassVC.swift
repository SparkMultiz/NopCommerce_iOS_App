//
//  ForgotPassVC.swift
//  NopCommerce
//
//  Created by Chirag Patel on 06/03/20.
//  Copyright © 2020 Chirag Patel. All rights reserved.
//

import UIKit

class ForgotPassVC: ParentViewController {

    var email = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
    }
}

extension ForgotPassVC {
    
    func prepareUI() {
        lblHeaderTitle?.text = getLocalizedKey(str: "account.passwordrecovery")
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
    }
}

extension ForgotPassVC {
    
    @IBAction func btnRecoverPassword(_ sender: UIButton) {
        if email.isEmpty {
            JTValidationToast.show(message: getLocalizedKey(str: "account.passwordrecovery.email.required"))
        } else if !email.isValidEmailAddress() {
            JTValidationToast.show(message: getLocalizedKey(str: "account.fields.emailtorevalidate.note"))
        } else {
            self.recoverPassword()
        }
    }
}

extension ForgotPassVC {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 2 ? 55.widthRatio : indexPath.row == 1 ? 70.widthRatio : UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ForgotPassCell
        cell = tableView.dequeueReusableCell(withIdentifier: "cell\(indexPath.row)", for: indexPath) as! ForgotPassCell
        cell.parent = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let forgotCell = cell as? ForgotPassCell {
            forgotCell.prepareUI(index: indexPath.row)
        }
    }
}

extension ForgotPassVC {
    
    func recoverPassword() {
        showHud()
        KPWebCall.call.recoverPassword(param: ["ApiSecretKey": secretKey, "storeId": storeId, "EmailId": email]) { [weak self] (json, statusCode) in
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


