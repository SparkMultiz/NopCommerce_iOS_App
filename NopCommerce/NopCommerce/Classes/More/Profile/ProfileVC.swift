//
//  ProfileVC.swift
//  NopCommerce
//
//  Created by Jayesh on 10/03/20.
//  Copyright © 2020 Chirag Patel. All rights reserved.
//

import UIKit

class ProfileVC: ParentViewController {
    
    var data = RegisterDataSpecifier()
    var toolBar: ToolBarView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        data.prepareProfileFields()
        tableView.reloadData()
    }
}

extension ProfileVC {
    
    func prepareUI() {
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        prepareToolbar()
        self.hideShowHomeTabbar(isHidden: true)
        setKeyboardNotifications()
    }
    
    func prepareToolbar(){
        toolBar = ToolBarView.instantiateViewFromNib()
        toolBar.handleTappedAction { [weak self] (tapped, toolbar) in
            self?.view.endEditing(true)
        }
    }
    
    func getSignUpCell(row: Int, section: Int = 0) -> SignUpCell? {
        let cell = tableView.cellForRow(at: IndexPath(row: row, section: section)) as? SignUpCell
        return cell
    }
}

extension ProfileVC {
    
    @IBAction func btnDatePickerTapped(_ sender: UIButton) {
        self.view.endEditing(true)
        let picker = KPDatePicker.instantiateViewFromNib(withView: self.view)
        picker.datePicker.datePickerMode = .date
        picker.datePicker.maximumDate = Date()
        picker.selectionBlock = { [weak self] (date) -> () in
            guard let weakself = self else {return}
            weakself.data.arrUserFields[0][3].text = Date.localDateString(from: date, format: "yyyy-MMM-dd")
            weakself.tableView.reloadData()
        }
    }
    
    @IBAction func btnUpdateTapped(_ sender: UIButton) {
        let validate = data.validateProfileData()
        if validate.isValid {
            self.upadteProfile()
        } else {
           JTValidationToast.show(message: validate.error)
        }
    }
}

extension ProfileVC {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return data.arrUserFields.isEmpty ? 0 : data.arrUserFields.count + 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section != tableView.numberOfSections - 1 ? data.arrUserFields[section].count : 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == tableView.numberOfSections - 1 ? 50.widthRatio : data.arrUserFields[indexPath.section][indexPath.row].fieldType.cellHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section != tableView.numberOfSections - 1 else {return nil}
        let headerView = tableView.dequeueReusableCell(withIdentifier: "headerCell") as! TableHeaderCell
        headerView.lblTitle.text = getLocalizedKey(str: "account.yourpersonaldetails")
        return headerView.contentView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section != tableView.numberOfSections - 1 ? 45.widthRatio : 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SignUpCell
        let cellID = indexPath.section == tableView.numberOfSections - 1 ? "btnCell" : data.arrUserFields[indexPath.section][indexPath.row].fieldType.rawValue
        cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! SignUpCell
        cell.parentProfile = self
        cell.screenType = .profile
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let signUpCell = cell as? SignUpCell {
            if indexPath.section == tableView.numberOfSections - 1 {
                signUpCell.btnTitle.setTitle(getLocalizedKey(str: "common.save"), for: .normal)
            } else {
                let currentField = data.arrUserFields[indexPath.section][indexPath.row]
                signUpCell.prepareRegiterFields(data: currentField, index: indexPath.row)
            }
        }
    }
}

extension ProfileVC {
    
    func upadteProfile() {
        showHud()
        KPWebCall.call.updateUserProfileData(param: data.profileParamDict()) { [weak self] (json, statusCode) in
            guard let weakself = self else {return}
            weakself.hideHud()
            if statusCode == 200, let dict = json as? NSDictionary, let status = dict["Status"] as? Bool, status {
                weakself.getUserProfile { (done) in
                    weakself.showSuccessMsg(data: dict, view: weakself.view)
                }
            } else {
                weakself.showError(data: json, view: weakself.view)
            }
        }
    }
    
    func checkUserNameAvailibility(userName: String, completion: @escaping(Bool) -> ()) {
        self.showHud()
        let param: [String: Any] = ["ApiSecretKey": secretKey, "UserName": userName, "CustomerGUID": customerGUID]
        KPWebCall.call.checkUserNameAvail(param: param) { [weak self] (json, statusCode) in
            guard let weakself = self else {return}
            weakself.hideHud()
            if statusCode == 200, let dict = json as? NSDictionary, let isAvailable = dict["Available"] as? Bool, isAvailable {
                completion(true)
                weakself.showSuccessMsg(data: dict, view: weakself.view)
            } else {
                completion(false)
                weakself.showError(data: json, view: weakself.view)
            }
        }
    }
}
