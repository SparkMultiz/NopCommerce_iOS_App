//
//  LoginCell.swift
//  NopCommerce
//
//  Created by Chirag Patel on 06/03/20.
//  Copyright © 2020 Chirag Patel. All rights reserved.
//

import UIKit

class LoginCell: ConstrainedTableViewCell {

    @IBOutlet weak var tfUserNameEmail: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var btnRememberMe: UIButton!
    @IBOutlet weak var btnPasswordHideShow: UIButton!
    
    @IBOutlet weak var btnForgotPass: UIButton!
    @IBOutlet weak var btnSignIn: UIButton!
    @IBOutlet weak var btnSignUp: UIButton!
    @IBOutlet weak var lblNoAccount: UILabel!
    
    weak var parent: LoginVC!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
        
    func prepareLoginUI(index: Int) {
        guard parent.data != nil else {return}
        if index == 0 {
            tfUserNameEmail.keyboardType = parent.data.isUserNameAvailable ? .default : .emailAddress
            tfUserNameEmail.placeholder = parent.data.isUserNameAvailable ? getLocalizedKey(str: "account.login.fields.email/account.login.fields.username") : getLocalizedKey(str: "account.login.fields.email")
            tfUserNameEmail.text = parent.data.userName
        } else if index == 1 {
            tfPassword.text = parent.data.password
            tfPassword.placeholder = getLocalizedKey(str: "account.login.fields.password")
        } else if index == 2 {
            btnForgotPass.setTitle(getLocalizedKey(str: "account.login.forgotpassword"), for: .normal)
            btnRememberMe.setTitle(" \(getLocalizedKey(str: "account.login.fields.rememberme"))", for: .normal)
            btnRememberMe.isSelected = _userDefault.isRememberChecked()
        } else if index == 3 {
            btnSignIn.setTitle(getLocalizedKey(str: "account.login"), for: .normal)
        } else {
            //lblNoAccount.text = getLocalizedKey(str: "account.login.welcome")
            btnSignUp.setTitle(" \(getLocalizedKey(str: "account.register")) ", for: .normal)
        }
    }
}

extension LoginCell: UITextFieldDelegate {
    
    @IBAction func tfEditingChange(_ textField: UITextField) {
        let str = textField.text!.trimmedString()
        if textField == tfUserNameEmail {
            parent.data.userName = str
        } else {
            parent.data.password = str
        }
    }
    
    @IBAction func btnPasswordHideShowTapped(_ sender: UIButton) {
        let isSelected = tfPassword.isSecureTextEntry
        sender.isSelected = !isSelected
        tfPassword.isSecureTextEntry = !isSelected
    }
    
    @IBAction func btnRememberMeTapped(_ sender: UIButton) {
        let isSelected = sender.isSelected
        sender.isSelected = !isSelected
        _userDefault.setIsRememberMe(value: !sender.isSelected)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType == .next {
            if let index = parent.tableView.indexPath(for: self) {
                if let cell = parent.getLoginCell(row: index.row + 1){
                    cell.tfPassword.becomeFirstResponder()
                }
            } else {
                textField.resignFirstResponder()
            }
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
}
