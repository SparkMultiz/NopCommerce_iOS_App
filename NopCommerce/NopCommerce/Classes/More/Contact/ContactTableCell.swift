//
//  ContactTableCell.swift
//  NopCommerce
//
//  Created by Chirag Patel on 11/03/20.
//  Copyright © 2020 Chirag Patel. All rights reserved.
//

import UIKit

class ContactTableCell: ConstrainedTableViewCell {

    @IBOutlet weak var lblContactBody: UILabel!
    @IBOutlet weak var tfFirstField: UITextField!
    @IBOutlet weak var tfSecondField: UITextField!
    @IBOutlet weak var txtView: UITextView!
    @IBOutlet weak var lblPlaceHolder: UILabel!
    @IBOutlet weak var btnSendEmail: UIButton!
    
    weak var parent: WishListEmailVC!
    weak var parentContact: ContactUsVC!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func prepareEmailWishListUI(idx: Int) {
        if idx == 0 {
            tfFirstField.placeholder = getLocalizedKey(str: "products.emailafriend.friendemail.hint")
            tfFirstField.text = parent.strFrndEmail
        } else if idx == 1 {
            tfSecondField.placeholder = getLocalizedKey(str: "products.emailafriend.youremailaddress.hint")
            tfSecondField.text = parent.strEmail
        } else if idx == 2 {
            lblPlaceHolder.text = getLocalizedKey(str: "wishlist.emailafriend.personalmessage.hint")
            txtView.text = parent.strMsg
            lblPlaceHolder.isHidden = !parent.strMsg.isEmpty
        } else {
            btnSendEmail.setTitle(getLocalizedKey(str: "products.emailafriend.button"), for: .normal)
        }
    }
    
    func prepareContactUI(idx: Int) {
        if idx == 0 {
            tfFirstField.text = parentContact.strName
        } else if idx == 1 {
            tfSecondField.text = parentContact.strEmail
        } else if idx == 2 {
            txtView.text = parentContact.strMsg
            lblPlaceHolder.isHidden = !parentContact.strMsg.isEmpty
        }
    }
}

extension ContactTableCell: UITextFieldDelegate {
    
    @IBAction func tfEditingChange(_ textField: UITextField) {
        let str = textField.text!//.trimmedString()
        if parentContact != nil {
            if textField == tfFirstField {
                parentContact.strName = str
            } else {
                parentContact.strEmail = str
            }
        } else {
            if textField == tfFirstField {
                parent.strFrndEmail = str
            } else {
                parent.strEmail = str
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

extension ContactTableCell: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        let str = textView.text.trimmedString()
        if parent != nil {
            parent.strMsg = str
            lblPlaceHolder.isHidden = !parent.strMsg.isEmpty
        } else {
            parentContact.strMsg = str
            lblPlaceHolder.isHidden = !parentContact.strMsg.isEmpty
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.isFirstResponder {
            if parent != nil {
                parent.tableView.scrollToRow(at: IndexPath(row: 2, section: 0), at: .top, animated: true)
            } else {
                parentContact.tableView.scrollToRow(at: IndexPath(row: 2, section: 1), at: .top, animated: true)
            }
        }
    }
}
