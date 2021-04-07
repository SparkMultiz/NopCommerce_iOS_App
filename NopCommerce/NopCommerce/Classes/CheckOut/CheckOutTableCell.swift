//
//  CheckOutTableCell.swift
//  NopCommerce
//
//  Created by Jayesh on 29/03/20.
//  Copyright © 2020 Chirag Patel. All rights reserved.
//

import UIKit

class CheckOutTableCell: ConstrainedTableViewCell {

    @IBOutlet weak var collView: UICollectionView!
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    @IBOutlet weak var tfInputFIeld: UITextField!
    @IBOutlet weak var lblDroDownTitle: UILabel!
    @IBOutlet weak var btnDropDown: UIButton!
    @IBOutlet var btnsAddress: [UIButton]!
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var imgSelectedAddres: UIImageView!
    @IBOutlet weak var lblPersonName: UILabel!
    @IBOutlet weak var lblFormattedAddress: UILabel!
    
    weak var parent: CheckOutCollCell!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setSelectedIdx(ind: Int) {
        for(idx,vw) in btnsAddress.enumerated() {
            if idx == ind {
                vw.backgroundColor = #colorLiteral(red: 0.137254902, green: 0.6941176471, blue: 0.9568627451, alpha: 1)
                vw.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
            } else {
                vw.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                vw.setTitleColor(#colorLiteral(red: 0.137254902, green: 0.6941176471, blue: 0.9568627451, alpha: 1), for: .normal)
            }
        }
    }
    
    func prepareShippingType(stage: EnumCheckOutStages) {
        if stage == .billingAddress {
            lblTitle.text = "Ship to the same address"
            lblSubTitle.text =  "Select a billing address from your address book or enter a new address."
        } else {
            lblTitle.text = "Pickup (Pick up your items at the store)"
            lblSubTitle.text =  "Select a shipping address from your address book or enter a new address."
        }
        imgView.image = parent.parent.isDeliverShippingSame ? #imageLiteral(resourceName: "checkMark") : #imageLiteral(resourceName: "uncheckmark")
    }
    
    func preparePaymentMethodUI(data: PaymentMethod) {
        lblTitle.text = data.name
        lblSubTitle.text = data.systemName
        imgView.kf.setImage(with: data.logoUrl, placeholder: _placeImage)
        imgSelectedAddres.image = data.isSelected ? #imageLiteral(resourceName: "radio") : #imageLiteral(resourceName: "UnSelectedRadio")
    }
    
    func prepareShippingAddressUI(data: ShippingMethod) {
        lblTitle.text = data.name
        lblSubTitle.text = data.desc
        imgSelectedAddres.image = data.isSelected ? #imageLiteral(resourceName: "radio") : #imageLiteral(resourceName: "UnSelectedRadio")
    }
    
    func prepareBillingAddressUI(data: Address) {
        lblPersonName.text = data.fullName
        lblFormattedAddress.text = data.formattedAdress
        imgSelectedAddres.image = data.isSelected ? #imageLiteral(resourceName: "radio") : #imageLiteral(resourceName: "UnSelectedRadio")
    }
    
    func prepareAddressFields(field: UserField) {
        if field.fieldType == .pickerCell {
            btnDropDown.tag = self.tag
            lblTitle.text = field.title
            if field.title == "Country" {
                let selectedCont = parent.parent.arrCountry.filter{$0.isSelected}.first ?? parent.parent.arrCountry[0]
                lblDroDownTitle.text = selectedCont.name
            } else {
                let selectedState = parent.parent.arrProvince.isEmpty ? "Other(Non US)" : parent.parent.arrProvince.filter{$0.isSelected}.first?.name ?? parent.parent.arrProvince[0].name
                lblDroDownTitle.text = selectedState
            }
        } else {
            tfInputFIeld.tag = self.tag
            tfInputFIeld.inputAccessoryView = field.keyboardType == .numberPad ? parent.parent.toolBar : nil
            tfInputFIeld.placeholder = field.placeholder
            tfInputFIeld.text = field.text
            tfInputFIeld.keyboardType = field.keyboardType
            tfInputFIeld.returnKeyType = field.keyBoardReturnKey
        }
    }
}

extension CheckOutTableCell: UITextFieldDelegate {
    
    @IBAction func tfEditingChange(_ textField: UITextField) {
        let str = textField.text!.trimmedString()
        parent.parent.objAddressData.arrAddressField[textField.tag].text = str
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType == .next {
            if let index = parent.tblView.indexPath(for: self) {
                if let cell = parent.getCheckOutCell(row: index.row + 1, section: index.section){
                    cell.tfInputFIeld.becomeFirstResponder()
                }
            }
            textField.resignFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
}

extension CheckOutTableCell: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return parent == nil ? 0 : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return parent.parent.checkOut.arrStages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: CheckBoxCollCell
        cell = collectionView.dequeueReusableCell(withReuseIdentifier: "selectionCell", for: indexPath) as! CheckBoxCollCell
        let objStage = parent.parent.checkOut.arrStages[indexPath.row]
        cell.lblTitle.text = objStage.name
        cell.imgView.isHidden = !objStage.isSelected
        return cell
    }
}

extension CheckOutTableCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let strStage = parent.parent.checkOut.arrStages[indexPath.row].name
        let width = strStage.WidthWithNoConstrainedHeight(font: UIFont.systemFont(ofSize: 16.widthRatio)) + 10
        return CGSize(width: width, height: collectionView.frame.size.height - 5)
    }
}
