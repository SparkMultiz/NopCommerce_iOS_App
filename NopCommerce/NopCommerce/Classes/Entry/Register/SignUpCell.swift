//
//  SignUpCell.swift
//  NopCommerce
//
//  Created by Chirag Patel on 06/03/20.
//  Copyright © 2020 Chirag Patel. All rights reserved.
//

import UIKit

class TableHeaderCell: ConstrainedTableViewCell {
    @IBOutlet weak var topConst: NSLayoutConstraint!
    @IBOutlet weak var lblTitle: UILabel!
    
    func setHeaderUI(section: Int) {
        lblTitle.text = section == 1 || section == 2 ? "" : section == 6 ? getLocalizedKey(str: "products.specs") : section == 7 ? getLocalizedKey(str: "products.tierprices") : getLocalizedKey(str: "products.relatedproducts")
        topConst.constant = section == 6 ? 0 : 10.widthRatio
        layoutIfNeeded()
    }
}

class SignUpCell: ConstrainedTableViewCell, UITextFieldDelegate {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnTitle: UIButton!
    @IBOutlet weak var tfInput: UITextField!
    @IBOutlet var btnGender: [KPWidthButton]!
    @IBOutlet var lblBirthDate: [UILabel]!
    @IBOutlet weak var btnPasswordHideShow: UIButton!
    @IBOutlet weak var lblTemsPolicy: UILabel!
    @IBOutlet weak var imgTickView: UIImageView!
    
    enum ScreenType {
        case register,profile
    }
    
    var screenType: ScreenType = .register
    weak var parentRegister: SignUpVC!
    weak var parentProfile: ProfileVC!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func prepareRegiterFields(data: UserField, index: Int) {
        switch data.fieldType {
        case .textField, .userNameCell, .passwordCell:
            tfInput.tag = index
            tfInput.autocorrectionType = .no
            tfInput.spellCheckingType = .no
            tfInput.isUserInteractionEnabled = !(screenType == .profile && data.keyboardType == .emailAddress)
            tfInput.inputAccessoryView = data.keyboardType == .numberPad ? screenType == .register ? parentRegister.toolBar : parentProfile.toolBar : nil
            tfInput.autocapitalizationType = data.keyboardType == .emailAddress || data.keyboardType == .URL || data.fieldType == .userNameCell ? .none : .words
            tfInput.isSecureTextEntry = data.fieldType == .passwordCell
            tfInput.placeholder = data.placeholder
            tfInput.keyboardType = data.keyboardType
            tfInput.returnKeyType = data.keyBoardReturnKey
            tfInput.text = data.text
            if data.fieldType == .userNameCell {
                btnTitle.setTitle(getLocalizedKey(str: "account.checkusernameavailability.button"), for: .normal)
            }
        case .genderCell:
            lblTitle.text = getLocalizedKey(str: "account.fields.gender")
            btnGender[0].setTitle(getLocalizedKey(str: "account.fields.gender.male"), for: .normal)
            btnGender[1].setTitle(getLocalizedKey(str: "account.fields.gender.female"), for: .normal)
            if data.gender == .male {
                btnGender[0].borderWidth = 0.7
                btnGender[0].borderColor = #colorLiteral(red: 0.1215686275, green: 0.1294117647, blue: 0.1411764706, alpha: 0.95)
            }
            if data.gender == .female {
                btnGender[1].borderWidth = 0.7
                btnGender[1].borderColor = #colorLiteral(red: 0.1215686275, green: 0.1294117647, blue: 0.1411764706, alpha: 0.95)
            }
        case .dobCell:
            lblTitle.text = getLocalizedKey(str: "account.fields.dateofbirth")
            let dob = data.text.components(separatedBy: "-").filter{!$0.isEmpty}
            if !dob.isEmpty {
                lblBirthDate[0].text = dob[2]
                lblBirthDate[1].text = dob[1]
                lblBirthDate[2].text = dob[0]
            } else {
                lblBirthDate[0].text = getLocalizedKey(str: "common.day")
                lblBirthDate[1].text = getLocalizedKey(str: "common.month")
                lblBirthDate[2].text = getLocalizedKey(str: "common.year")
            }
        case .termsCell:
            imgTickView.image = data.isSelected ? #imageLiteral(resourceName: "checkMark") : #imageLiteral(resourceName: "uncheckmark")
            lblTemsPolicy.text = data.title
        default:
            break
        }
    }
}


extension SignUpCell {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType == .next {
            let tblView = screenType == .register ? parentRegister.tableView : parentProfile.tableView
            if let index = tblView!.indexPath(for: self) {
                if parentRegister != nil {
                    if let cell = parentRegister.getSignUpCell(row: index.row + 1, section: index.section){
                        cell.tfInput.becomeFirstResponder()
                    } else {
                        textField.resignFirstResponder()
                    }
                } else {
                    if let cell = parentProfile.getSignUpCell(row: index.row + 1, section: index.section){
                        cell.tfInput.becomeFirstResponder()
                    } else {
                        textField.resignFirstResponder()
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

extension SignUpCell {
    
    @IBAction func tfEditingChange(_ textField: UITextField) {
        let str = textField.text!.trimmedString()
        let data = screenType == .register ? parentRegister.data : parentProfile.data
        data.arrUserFields[self.tag][textField.tag].text = str
    }
        
    @IBAction func btnGenderTapped(_ sender: UIButton) {
        let data = screenType == .register ? parentRegister.data : parentProfile.data
        let index = data.arrUserFields[0].firstIndex{$0.fieldType == .genderCell}
        data.arrUserFields[self.tag][index!].gender = GenderType(idx: sender.tag)
        if parentRegister != nil {
            parentRegister.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        } else {
            parentProfile.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        }
    }
    
    @IBAction func btnAvailability(_ sender: UIButton) {
        let data = screenType == .register ? parentRegister.data : parentProfile.data
        let index = data.arrUserFields[0].firstIndex{$0.fieldType == .userNameCell}
        let strUserName = data.arrUserFields[self.tag][index!].text
        guard !strUserName.isEmpty else {
            JTValidationToast.show(message: kEnterUsername)
            return
        }
        if parentRegister != nil {
            parentRegister.checkUserNameAvailibility(userName: strUserName) { (completed) in
                if !completed {
                    self.parentRegister.data.arrUserFields[self.tag][index!].text.removeAll()
                }
                UIView.performWithoutAnimation {
                    self.parentRegister.tableView.reloadRows(at: [IndexPath(row: index!, section: self.tag)], with: .none)
                }
            }
        } else {
            parentProfile.checkUserNameAvailibility(userName: strUserName) { (completed) in
                if !completed {
                    self.parentProfile.data.arrUserFields[self.tag][index!].text.removeAll()
                }
                UIView.performWithoutAnimation {
                    self.parentProfile.tableView.reloadRows(at: [IndexPath(row: index!, section: self.tag)], with: .none)
                }
            }
        }
    }
    
    @IBAction func btnPasswordHideShowTapped(_ sender: UIButton) {
        if sender.tag == 0 {
            let isSelected = tfInput.isSecureTextEntry
            sender.isSelected = !isSelected
            tfInput.isSecureTextEntry = !isSelected
        } else {
            let isSelected = tfInput.isSecureTextEntry
            sender.isSelected = !isSelected
            tfInput.isSecureTextEntry = !isSelected
        }
    }
}

