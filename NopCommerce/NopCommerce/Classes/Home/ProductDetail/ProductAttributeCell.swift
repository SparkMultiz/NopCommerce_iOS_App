//
//  ProductAttributeCell.swift
//  NopCommerce
//
//  Created by Chirag Patel on 20/03/20.
//  Copyright © 2020 Chirag Patel. All rights reserved.
//

import UIKit

class ProductAttributeCell: ConstrainedTableViewCell {
    
    @IBOutlet weak var colorCollView: UICollectionView!
    @IBOutlet var lblSelectedDate: [UILabel]!
    @IBOutlet var btns: [UIButton]!
    
    @IBOutlet weak var btnDropDown: UIButton!
    @IBOutlet weak var lblAttriValue: UILabel!
    @IBOutlet weak var lblAttriTitle: UILabel!
    
    @IBOutlet weak var tfInputField: UITextField!
    @IBOutlet weak var txtView: UITextView!
    
    @IBOutlet weak var tfStartDate: UITextField!
    @IBOutlet weak var tfEndDate: UITextField!
    @IBOutlet weak var rentStackView: UIStackView!
    
    @IBOutlet weak var dropDownView: UIView!
    @IBOutlet weak var lblQuantity: UILabel!
    
    weak var parent: UIViewController?
    
    var objAttribute: ProductAttributes!
    var currSection: Int!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func prepareRentalField(detail: ProductDetail) {
        let startDate = detail.rentalStartDate
        let endtDate = detail.rentalEndDate
        lblSelectedDate[0].attributedText = getLocalizedKey(str: "products.rentalstartdate").setAttriTitle(isRequired: true)
        lblSelectedDate[1].attributedText = getLocalizedKey(str: "products.rentalenddate").setAttriTitle(isRequired: true)
        let rentPrice = detail.objPrice!.rentalPrice
        lblSelectedDate[2].text = rentPrice.isEmpty ? "" : "\(getLocalizedKey(str: "products.price.rentalprice")) \(rentPrice)"
        tfStartDate.text = startDate
        tfEndDate.text = endtDate
    }
    
    func prepareFields(field: UserField, detail: ProductDetail) {
        if field.fieldType == .dobCell, let cart = detail.objCart {
            if field.keyboardType == .decimalPad {
                rentStackView.subviews.last?.isHidden = true
                btns.forEach{$0.isHidden = true}
                lblSelectedDate[0].text = field.title
                lblSelectedDate[2].text = cart.customPriceRange
                if let parentVC = parent as? ProductDetailVC {
                    tfStartDate.inputAccessoryView = parentVC.toolBar
                }
                tfStartDate.keyboardType = field.keyboardType
                tfStartDate.text = field.text
            } else {
                rentStackView.subviews.last?.isHidden = false
                btns.forEach{$0.isHidden = false}
                prepareRentalField(detail: detail)
            }
        } else {
            lblAttriTitle.text = field.title
            if let cart = detail.objCart, !cart.arrQuantity.isEmpty {
                tfInputField.isHidden = true
                dropDownView.isHidden = false
                btnDropDown.tag = self.tag
                lblQuantity.text = field.text
            } else {
                dropDownView.isHidden = true
                tfInputField.isHidden = false
                tfInputField.tag = self.tag
                if let parentVC = parent as? ProductDetailVC {
                    tfInputField.inputAccessoryView = parentVC.toolBar
                }
                tfInputField.keyboardType = field.keyboardType
                tfInputField.text = field.text
            }
        }
    }
    
    func prepareGiftCardUI(field: UserField) {
        lblAttriTitle.text = field.title
        if field.fieldType == .textField {
            tfInputField.inputAccessoryView = nil
            tfInputField.keyboardType = field.keyboardType
            tfInputField.returnKeyType = field.keyBoardReturnKey
            tfInputField.text = field.text
        } else {
            txtView.text = field.text
        }
    }
    
    fileprivate func changeImageTo(_ index: Int) {
        if objAttribute.controlType == .colors {
            DispatchQueue.main.async {
                if let parentVC = self.parent as? ProductDetailVC {
                    if let cell = parentVC.getProductDetailCell(indexPath: IndexPath(row: 0, section: 0)) {
                        cell.scrollToIndex(idx: index)
                    }
                }
            }
        }
    }
    
    func prepareProductAttributeUI() {
        lblAttriTitle.attributedText = objAttribute.name.setAttriTitle(isRequired: objAttribute.isRequired)
        switch objAttribute.controlType {
        case .txtField:
            tfInputField.tag = self.tag
            tfInputField.keyboardType = .default
            tfInputField.returnKeyType = .done
            tfInputField.inputAccessoryView = nil
            tfInputField.text = objAttribute.value
        case .txtView:
            txtView.text = objAttribute.value
        case .dropDown:
            btnDropDown.tag = self.tag
            let selectedVal = objAttribute.arrAttributesValues.filter{$0.isPreSelected}.first
            lblAttriValue.text = selectedVal == nil ? objAttribute.arrAttributesValues.isEmpty ? "" : objAttribute.arrAttributesValues[0].priceValue : selectedVal!.priceValue
        case .colors, .image, .checkBox, .radio:
            if !objAttribute.arrAttributesValues.isEmpty {
                colorCollView.reloadData()
            }
        case .datePicker :
            let dob = objAttribute.value.components(separatedBy: "/").filter{!$0.isEmpty}
            let lblColor = dob.isEmpty ? #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1) : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            lblSelectedDate.forEach{$0.textColor = lblColor}
            if !dob.isEmpty {
                lblSelectedDate[0].text = dob[1]
                lblSelectedDate[1].text = dob[0]
                lblSelectedDate[2].text = dob[2]
            } else {
                lblSelectedDate[0].text = getLocalizedKey(str: "common.month")
                lblSelectedDate[1].text = getLocalizedKey(str: "common.year")
                lblSelectedDate[2].text = getLocalizedKey(str: "common.day")
            }
        default:
            return
        }
    }
}

extension ProductAttributeCell: UITextFieldDelegate, UITextViewDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType == .next {
            if let parentVC = parent as? ProductDetailVC {
                if let index = parentVC.tableView.indexPath(for: self) {
                    if let cell = parentVC.getAttributeCell(row: index.row + 1, section: index.section) {
                        cell.tfInputField.becomeFirstResponder()
                    }
                } else {
                    textField.resignFirstResponder()
                }
            } else if let parentVC = parent as? CartVC {
                if let index = parentVC.tableView.indexPath(for: self) {
                    if let cell = parentVC.getAttributeCell(row: index.row + 1, section: index.section) {
                        cell.tfInputField.becomeFirstResponder()
                    }
                } else {
                    textField.resignFirstResponder()
                }
            }
        }
        textField.resignFirstResponder()
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let str = textView.text.trimmedString()
        if let parentVC = parent as? ProductDetailVC {
            if currSection == 1 {
                parentVC.productDetail.arrGiftCard[self.tag].text = str
            } else {
                parentVC.productDetail.arrAttribues[self.tag].value = str
            }
        } else if let parentVC = parent as? CartVC {
            parentVC.objCart.arrAttribues[self.tag].value = str
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if let parentVC = parent as? ProductDetailVC {
            parentVC.tableView.scrollToRow(at: IndexPath(row: self.tag, section: currSection), at: .top, animated: true)
        } else if let parentVC = parent as? CartVC {
             parentVC.tableView.scrollToRow(at: IndexPath(row: self.tag, section: currSection), at: .top, animated: true)
        }
    }
}

extension ProductAttributeCell: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return parent == nil ? 0 : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return objAttribute.arrAttributesValues.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if objAttribute.controlType == .checkBox || objAttribute.controlType == .radio {
            let cell: CheckBoxCollCell
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "checkBoxCell", for: indexPath) as! CheckBoxCollCell
            cell.prepareUI(objAttribute: objAttribute, indexPath: indexPath)
            return cell
        } else {
            let cell: ColorCollCell
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "colorCell", for: indexPath) as! ColorCollCell
            cell.prepareUI(objAttribute: objAttribute, indexPath: indexPath)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if objAttribute.controlType == .checkBox {
            let isPreSelected = objAttribute.arrAttributesValues[indexPath.row].isPreSelected
            objAttribute.arrAttributesValues[indexPath.row].isPreSelected = !isPreSelected
            if let parentVC = parent as? ProductDetailVC {
                parentVC.changeProductAttribute()
            }
            collectionView.reloadData()
        } else if objAttribute.controlType == .radio {
            objAttribute.arrAttributesValues.forEach{$0.isPreSelected = false}
            objAttribute.arrAttributesValues[indexPath.row].isPreSelected = true
            if let parentVC = parent as? ProductDetailVC {
                parentVC.changeProductAttribute()
            }
            collectionView.reloadData()
        } else if objAttribute.controlType == .colors {
            changeImageTo(indexPath.row)
        }
    }
}

extension ProductAttributeCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if objAttribute.arrAttributesValues.isEmpty {
            return CGSize(width: 0, height: 0)
        } else {
            if objAttribute.controlType == .checkBox || objAttribute.controlType == .radio {
                let collHeight = colorCollView.frame.size.height - 10
                let textWidth = objAttribute.arrAttributesValues[indexPath.row].priceValue.WidthWithNoConstrainedHeight(font: UIFont.systemFont(ofSize: 15.widthRatio)) + 35
                return CGSize(width: textWidth, height: collHeight.widthRatio)
            } else {
                let colorSize = colorCollView.frame.size.height - 10
                return CGSize(width: colorSize.widthRatio, height: colorSize.widthRatio)
            }
        }
    }
}

class ColorCollCell: ConstrainedCollectionViewCell {
    
    @IBOutlet weak var colorView: BaseView!
    @IBOutlet weak var imgView: UIImageView!
    
    func prepareUI(objAttribute: ProductAttributes, indexPath: IndexPath) {
        imgView.isHidden = objAttribute.controlType == .colors
        colorView.isHidden = objAttribute.controlType == .image
        let objSubAttri = objAttribute.arrAttributesValues[indexPath.row]
        if objAttribute.controlType == .colors {
            colorView.isViewRound = true
            colorView.borderWidth = 0.5
            colorView.borderColor = objSubAttri.isPreSelected ? #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1) : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            colorView.backgroundColor =  objSubAttri.color
        } else {
            imgView.kf.indicatorType = .activity
            imgView.kf.setImage(with: objSubAttri.imgUrl, placeholder: _placeImage)
        }
    }
    
}

class CheckBoxCollCell: ConstrainedCollectionViewCell {
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet var lblDashConst: NSLayoutConstraint!
    
    func prepareUI(objAttribute: ProductAttributes, indexPath: IndexPath) {
        let objSubAttri = objAttribute.arrAttributesValues[indexPath.row]
        lblTitle.text = objSubAttri.priceValue
        if objAttribute.controlType == .checkBox {
            imgView.image = objSubAttri.isPreSelected ? #imageLiteral(resourceName: "checkMark") : #imageLiteral(resourceName: "uncheckmark")
        } else {
            imgView.image = objSubAttri.isPreSelected ? #imageLiteral(resourceName: "radio") : #imageLiteral(resourceName: "UnSelectedRadio")
        }
    }
}
