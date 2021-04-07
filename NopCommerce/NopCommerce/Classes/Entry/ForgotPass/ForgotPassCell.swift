//
//  ForgotPassCell.swift
//  NopCommerce
//
//  Created by Chirag Patel on 06/03/20.
//  Copyright © 2020 Chirag Patel. All rights reserved.
//

import UIKit

class ForgotPassCell: ConstrainedTableViewCell, UITextFieldDelegate {

    @IBOutlet weak var lblToolTip: UILabel!
    @IBOutlet weak var btnRecover: UIButton!
    @IBOutlet weak var tfEmail: UITextField!
    
    weak var parent: ForgotPassVC!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func prepareUI(index: Int) {
        if index == 0 {
            lblToolTip.text = getLocalizedKey(str: "account.passwordrecovery.tooltip")
        } else if index == 1 {
            tfEmail.placeholder = getLocalizedKey(str: "account.passwordrecovery.email")
            tfEmail.text = parent.email
        } else {
            btnRecover.setTitle(getLocalizedKey(str: "account.passwordrecovery.recoverbutton"), for: .normal)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func tfEditingChange(_ textField: UITextField) {
        let str = textField.text!.trimmedString()
        parent.email = str
    }
}
