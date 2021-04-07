//
//  SignUpVC.swift
//  NopCommerce
//
//  Created by Chirag Patel on 06/03/20.
//  Copyright © 2020 Chirag Patel. All rights reserved.
//

import UIKit

class SignUpVC: ParentViewController {

    var data = RegisterDataSpecifier()
    var formData: FormRequiredData!
    var toolBar: ToolBarView!
    
    var isFromSlideMenu = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        getRegisterForm()
    }
}

extension SignUpVC {
    
    func prepareUI() {
        lblHeaderTitle?.text = getLocalizedKey(str: "account.register")
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        prepareToolbar()
        setKeyboardNotifications()
    }
    
    func initRegisterModel() {
        self.data.prepareRegisterFields(formData: formData)
        self.tableView.reloadData()
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
    
    func navigateToHome() {
        if isFromSlideMenu {
            _appDelegator.navigateUser()
        } else {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "homeSegue", sender: nil)
            }
        }
    }
}

extension SignUpVC {
    
    @IBAction func btnDatePickerTapped(_ sender: UIButton) {
        self.view.endEditing(true)
        let picker = KPDatePicker.instantiateViewFromNib(withView: self.view)
        picker.datePicker.datePickerMode = .date
        picker.datePicker.maximumDate = Date()
        picker.selectionBlock = { [weak self] (date) -> () in
            guard let weakself = self else {return}
            let index = weakself.data.arrUserFields[0].firstIndex{$0.fieldType == .dobCell}
            weakself.data.arrUserFields[0][index!].text = Date.localDateString(from: date, format: "yyyy-MMM-dd")
            weakself.tableView.reloadData()
        }
    }
    
    @IBAction func btnSignUpTapped(_ sender: UIButton) {
        let validate = data.validatetData(formData: formData)
        if validate.isValid {
            if _user != nil {
                _appDelegator.deleteUserObject()
            }
            self.registerUser()
        } else {
            JTValidationToast.show(message: validate.error)
        }
    }
}

extension SignUpVC {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return data.arrUserFields.isEmpty ? 0 : data.arrUserFields.count + 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == tableView.numberOfSections - 1 ? 2 : data.arrUserFields[section].count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == tableView.numberOfSections - 1 ? 50.widthRatio : data.arrUserFields[indexPath.section][indexPath.row].fieldType.cellHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section != 4 && section != 5 else {return nil}
        let headerView = tableView.dequeueReusableCell(withIdentifier: "headerCell") as! TableHeaderCell
        headerView.lblTitle.text = section == 0 ? getLocalizedKey(str: "account.yourpersonaldetails") : section == 1 ? getLocalizedKey(str: "account.companydetails") : section == 2 ? getLocalizedKey(str: "account.options") : getLocalizedKey(str: "account.yourpassword")
        return headerView.contentView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section != 4 && section != 5 ? 40.widthRatio : 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SignUpCell
        let cellID = indexPath.section == tableView.numberOfSections - 1 ? indexPath.row == 0 ? "btnCell" : "signInCell" : data.arrUserFields[indexPath.section][indexPath.row].fieldType.rawValue
        cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! SignUpCell
        cell.parentRegister = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let signUpCell = cell as? SignUpCell {
            if indexPath.section != tableView.numberOfSections - 1 {
                signUpCell.tag = indexPath.section
                let currentField = data.arrUserFields[indexPath.section][indexPath.row]
                signUpCell.prepareRegiterFields(data: currentField, index: indexPath.row)
            } else {
                let str = indexPath.row == 0 ? getLocalizedKey(str: "account.register") : " \(getLocalizedKey(str: "account.login")) "
                signUpCell.btnTitle.setTitle(str, for: .normal)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section != tableView.numberOfSections - 1 else {return}
        guard self.data.arrUserFields[indexPath.section][indexPath.row].fieldType == .termsCell else {return}
        let isSelected = self.data.arrUserFields[indexPath.section][indexPath.row].isSelected
        self.data.arrUserFields[indexPath.section][indexPath.row].isSelected = !isSelected
        UIView.performWithoutAnimation {
            self.tableView.reloadSections(IndexSet(integer: indexPath.section), with: .none)
        }
    }
}

extension SignUpVC {
    
    func getRegisterForm() {
        self.showHud()
        let param: [String: Any] = ["ApiSecretKey": secretKey]
        KPWebCall.call.getSignUpForm(param: param) { [weak self] (json, statusCode) in
            guard let weakself = self else {return}
            weakself.hideHud()
            if statusCode == 200, let dict = json as? NSDictionary {
                weakself.formData = FormRequiredData(dict: dict)
                weakself.initRegisterModel()
            } else {
                weakself.showError(data: json, view: weakself.view)
            }
        }
    }
    
    func checkUserEmailAndRegister() {
        let index = self.data.arrUserFields[0].firstIndex{$0.keyboardType == .emailAddress}
        let strEmail = self.data.arrUserFields[0][index!].text
        self.showHud()
        let param: [String: Any] = ["ApiSecretKey": secretKey, "EmailId": strEmail]
        KPWebCall.call.checkEmailAvail(param: param) { [weak self] (json, statusCode) in
            guard let weakself = self else {return}
            weakself.hideHud()
            if statusCode == 200, let dict = json as? NSDictionary, let isAvailable = dict["Status"] as? Bool, isAvailable {
                weakself.registerUser()
            } else {
                weakself.showError(data: json, view: weakself.view)
            }
        }
    }
    
    func registerUser() {
        self.showHud()
        KPWebCall.call.registerUser(param: data.paramDict(formData: formData)) { [weak self] (json, statusCode) in
            guard let weakself = self else {return}
            weakself.hideHud()
            if statusCode == 200, let dict = json as? NSDictionary, let status = dict["Status"] as? Bool, status {
                if let userData = dict["Data"] as? NSDictionary {
                    _user = User.addUpdateEntity(key: "guid", value: userData.getStringValue(key: "CustomerGuid"))
                    _user.initRegister(dict: userData)
                    weakself.getUserProfile { (done) in
                        if done {
                            weakself.navigateToHome()
                        }
                    }
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
