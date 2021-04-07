//
//  ChangePasswordVC.swift
//  NopCommerce
//
//  Created by CHIRAG on 07/03/20.
//  Copyright © 2020 Chirag Patel. All rights reserved.
//

import UIKit

class ChangePasswordVC: ParentViewController {

    var data = ChangePassword()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
    }
}

extension ChangePasswordVC {
    
    func prepareUI() {
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        self.hideShowHomeTabbar(isHidden: true)
        setKeyboardNotifications()
    }
    
    func getChangePassCell(row: Int, section: Int = 0) -> ChangePasswordCell? {
        let cell = tableView.cellForRow(at: IndexPath(row: row, section: section)) as? ChangePasswordCell
        return cell
    }
}

extension ChangePasswordVC {
    
    @IBAction func btnChangePassword(_ sender: UIButton) {
        let validate = self.data.validatetData()
        if validate.isValid {
            self.changePassword()
        } else {
           JTValidationToast.show(message: validate.error)
        }
    }
}

extension ChangePasswordVC {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65.widthRatio
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ChangePasswordCell
        cell = tableView.dequeueReusableCell(withIdentifier: "cell\(indexPath.row)", for: indexPath) as! ChangePasswordCell
        cell.parent = self
        cell.tag = indexPath.row
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let forgotCell = cell as? ChangePasswordCell {
            forgotCell.prepareChangePassUI()
        }
    }
}

extension ChangePasswordVC {
    
    func changePassword() {
        showHud()
        KPWebCall.call.changePassword(param: data.paramDict()) { [weak self] (json, statusCode) in
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
