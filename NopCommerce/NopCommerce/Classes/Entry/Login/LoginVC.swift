//
//  LoginVC.swift
//  NopCommerce
//
//  Created by Chirag Patel on 06/03/20.
//  Copyright © 2020 Chirag Patel. All rights reserved.
//

import UIKit

class LoginVC: ParentViewController {

    @IBOutlet weak var btnCross: UIButton!
    @IBOutlet weak var btnSkip: UIButton!
    @IBOutlet weak var lblWelcome: UILabel!

    var data: LoginData!
    var isFromSlideMenu = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        getLoginForm()
    }
}

extension LoginVC {
    
    func prepareUI() {
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        btnCross.isHidden = !isFromSlideMenu
        btnSkip.isHidden = isFromSlideMenu
        lblWelcome.text = getLocalizedKey(str: "account.login.welcome")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "signUpSegue" {
            let destVC = segue.destination as! SignUpVC
            destVC.isFromSlideMenu = self.isFromSlideMenu
        }
    }
    
    func getLoginCell(row: Int, section: Int = 0) -> LoginCell? {
        let cell = tableView.cellForRow(at: IndexPath(row: row, section: section)) as? LoginCell
        return cell
    }
    
    func navigateToHome() {
        _appDelegator.setViewApperance()
        if isFromSlideMenu {
            _appDelegator.navigateUser()
        } else {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "homeSegue", sender: nil)
            }
        }
    }
}

extension LoginVC {
    
    @IBAction func btnSignUpTapped(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "signUpSegue", sender: nil)
        }
    }
    
    @IBAction func btnLoginTapped(_ sender: UIButton) {
        let validate = data.validatetData()
        if validate.isValid {
            if _user != nil {
                _appDelegator.deleteUserObject()
            }
            self.loginUser()
        } else {
            JTValidationToast.show(message: validate.error)
        }
    }
    
    @IBAction func btnGuestLoginTapped(_ sender: UIButton) {
        self.loginGuest { (completion) in
            self.navigateToHome()
        }
    }
}

extension LoginVC {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 3 ? 55.widthRatio : 65.widthRatio
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: LoginCell
        cell = tableView.dequeueReusableCell(withIdentifier: "cell\(indexPath.row)", for: indexPath) as! LoginCell
        cell.parent = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let loginCell = cell as? LoginCell {
            loginCell.prepareLoginUI(index: indexPath.row)
        }
    }
}


extension LoginVC {
    
    func getLoginForm() {
        self.showHud()
        let param: [String: Any] = ["ApiSecretKey": secretKey, "CheckoutAsGuest": false]
        KPWebCall.call.getLoginForm(param: param) { [weak self] (json, statusCode) in
            guard let weakself = self else {return}
            weakself.hideHud()
            weakself.data = LoginData()
            if statusCode == 200, let dict = json as? NSDictionary {
                weakself.data.isUserNameAvailable = dict.getBooleanValue(key: "UsernamesEnabled")
                weakself.tableView.reloadData()
            } else {
                weakself.showError(data: json, view: weakself.view)
            }
        }
    }
    
    func loginUser() {
        self.showHud()
        KPWebCall.call.loginUser(param: data.paramDict()) { [weak self] (json, statusCode) in
            guard let weakself = self else {return}
            if statusCode == 200, let dict = json as? NSDictionary, let status = dict["Status"] as? Bool, status {
                if let userData = dict["Data"] as? NSDictionary {
                    _user = User.addUpdateEntity(key: "guid", value: userData.getStringValue(key: "CustomerGuid"))
                    _user.initGuid(dict: userData)
                    weakself.getUserProfile { (done) in
                        if done {
                            weakself.hideHud()
                            weakself.navigateToHome()
                        }
                    }
                }
            } else {
                weakself.showError(data: json, view: weakself.view)
            }
        }
    }
    
    func loginGuest(completion: @escaping(Bool) -> ()) {
        self.showHud()
        KPWebCall.call.loginGuest { [weak self] (json, statusCode) in
            guard let weakself = self else {return}
            weakself.hideHud()
            if statusCode == 200, let dict = json as? NSDictionary {
                _user = User.addUpdateEntity(key: "guid", value: dict.getStringValue(key: "CustomerGuid"))
                _user.initGuest(dict: dict)
                _appDelegator.saveContext()
                completion(true)
            } else {
                weakself.showError(data: json, view: weakself.view)
            }
        }
    }
}
