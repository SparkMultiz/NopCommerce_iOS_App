//
//  ChangePasswordCell.swift
//  NopCommerce
//
//  Created by CHIRAG on 07/03/20.
//  Copyright © 2020 Chirag Patel. All rights reserved.
//

import UIKit

class ChangePasswordCell: ConstrainedTableViewCell, UITextFieldDelegate {

    @IBOutlet weak var tfOldPass: UITextField!
    @IBOutlet weak var tfNewPass: UITextField!
    @IBOutlet weak var tfConfPass: UITextField!
    @IBOutlet weak var btnSave: UIButton!
    
    weak var parent: ChangePasswordVC!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func prepareChangePassUI() {
        if self.tag == 0 {
            tfOldPass.placeholder = getLocalizedKey(str: "account.changepassword.fields.oldpassword")
            tfOldPass.text = parent.data.oldPassword
        } else if self.tag == 1 {
            tfNewPass.placeholder = getLocalizedKey(str: "account.passwordrecovery.newpassword")
            tfNewPass.text = parent.data.newPassword
        } else if self.tag == 2  {
            tfConfPass.placeholder = getLocalizedKey(str: "account.changepassword.fields.confirmnewpassword")
            tfConfPass.text = parent.data.confPassword
        } else {
            btnSave.setTitle(getLocalizedKey(str: "account.changepassword.button"), for: .normal)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func tfEditingChange(_ textField: UITextField) {
        let str = textField.text!.trimmedString()
        if self.tag == 0 {
            parent.data.oldPassword = str
        } else if self.tag == 1 {
            parent.data.newPassword = str
        } else {
            parent.data.confPassword = str
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType == .next {
            if let index = parent.tableView.indexPath(for: self) {
                if let cell = parent.getChangePassCell(row: index.row + 1){
                    if index.row == 0 {
                        cell.tfNewPass.becomeFirstResponder()
                    } else if index.row == 1 {
                        cell.tfConfPass.becomeFirstResponder()
                    } else {
                        textField.becomeFirstResponder()
                    }
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


