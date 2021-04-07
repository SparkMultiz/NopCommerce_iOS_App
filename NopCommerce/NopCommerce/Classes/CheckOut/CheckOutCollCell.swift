//
//  CheckOutCollCell.swift
//  NopCommerce
//
//  Created by Jayesh on 29/03/20.
//  Copyright © 2020 Chirag Patel. All rights reserved.
//

import UIKit

class CheckOutCollCell: ConstrainedCollectionViewCell {
    
    @IBOutlet weak var tblView: UITableView!
    
    var addressType: EnumAddressType = .saveAddress
    weak var parent: CheckOutVC!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        prepareUI()
    }
    
    func prepareUI() {
        tblView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50 + _bottomAreaSpacing, right: 0)
        setKeyboardNotifications()
    }
}

extension CheckOutCollCell {
    
    func setKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let kbSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            tblView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: kbSize.height + 10, right: 0)
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        tblView.contentInset = UIEdgeInsets(top:0, left: 0, bottom: 50 + _bottomAreaSpacing, right: 0)
    }
}

extension CheckOutCollCell {
    
    func getCheckOutCell(row: Int, section: Int = 0) -> CheckOutTableCell? {
        let cell = tblView.cellForRow(at: IndexPath(row: row, section: section)) as? CheckOutTableCell
        return cell
    }
}

extension CheckOutCollCell {
    
    @IBAction func btnAddressTypeTapped(_ sender: UIButton) {
        self.addressType = EnumAddressType(rawValue: sender.tag)!
        self.parent.btnStack.last?.setTitle(addressType == .saveAddress ? "DELIVER HERE" : "CONTINUE", for: .normal)
        self.tblView.reloadData()
    }
    
    @IBAction func btnDeliverAtShippingAddress(_ sender: UIButton) {
        let isSelected = parent.isDeliverShippingSame
        parent.isDeliverShippingSame = !isSelected
        sender.isSelected = parent.isDeliverShippingSame
        if let cell = tblView.cellForRow(at: IndexPath(row: 0, section: 1)) as? CheckOutTableCell {
            cell.imgView.image = sender.isSelected ? #imageLiteral(resourceName: "checkMark") : #imageLiteral(resourceName: "uncheckmark")
        }
        UIView.performWithoutAnimation {
            self.tblView.reloadSections(IndexSet(integer: 1), with: .none)
        }
    }
    
    @IBAction func btnAcceptTermsTapped(_ sender: UIButton) {
        let isSelected = parent.isTermsSelected
        parent.isTermsSelected = !isSelected
        sender.isSelected = parent.isTermsSelected
        if let cell = tblView.cellForRow(at: IndexPath(row: 0, section: 4)) as? CheckOutTableCell {
            cell.imgView.image = sender.isSelected ? #imageLiteral(resourceName: "checkMark") : #imageLiteral(resourceName: "uncheckmark")
        }
        UIView.performWithoutAnimation {
            self.tblView.reloadSections(IndexSet(integer: 4), with: .none)
        }
    }
}

extension CheckOutCollCell: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard parent != nil else {return 0}
        switch parent.checkOut.stage {
        case .billingAddress, .shippingAddress:
            return parent.arrAddress == nil ? 1 : 3
        case .shippingMethod:
            return parent.arrShippingMethod.isEmpty ? 0 : 2
        case .paymentMethod:
            return parent.arrPaymentMethod.isEmpty ? 0 : 2
        case .confirmOrder:
            return parent.objConfirmOrder == nil ? 0 : 5
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            switch parent.checkOut.stage {
            case .billingAddress, .shippingAddress:
                return section == 1 ? 1 : addressType == .addAddress ? parent.objAddressData.arrAddressField.count : parent.arrAddress.count
            case .shippingMethod:
                return parent.arrShippingMethod.count
            case .paymentMethod:
                return parent.arrPaymentMethod.count
            case .confirmOrder:
                return section == 1 ? parent.objConfirmOrder.arrItems.count : 1
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        } else {
            switch parent.checkOut.stage {
            case .billingAddress, .shippingAddress:
                return section == 1 ? 0 : 55.widthRatio
            case .shippingMethod, .paymentMethod:
                return 0
            case .confirmOrder:
                return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section != 0 else {return nil}
        switch parent.checkOut.stage {
        case .billingAddress, .shippingAddress:
            guard section != 1 else {return nil}
            let headerView = tableView.dequeueReusableCell(withIdentifier: "optAddressCell") as! CheckOutTableCell
            headerView.setSelectedIdx(ind: addressType.rawValue)
            return headerView.contentView
        case .shippingMethod, .paymentMethod:
            return nil
        case .confirmOrder:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 55.widthRatio
        } else {
            switch parent.checkOut.stage {
            case .billingAddress, .shippingAddress:
                return indexPath.section == 1 ? UITableView.automaticDimension :  addressType == .addAddress ? 70.widthRatio : UITableView.automaticDimension
            case .shippingMethod, .paymentMethod:
                return UITableView.automaticDimension
            case .confirmOrder:
                let billingAddressHeight = parent.objConfirmOrder.billingAddress?.getAddressHeight() ?? 0
                let shippingAddress = parent.objConfirmOrder.shippingAddress?.getAddressHeight() ?? 0
                let totalBillingHeight = billingAddressHeight + shippingAddress + 10
                return indexPath.section == 2 ? totalBillingHeight : UITableView.automaticDimension
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell: CheckOutTableCell
            cell = tableView.dequeueReusableCell(withIdentifier: "collCell", for: indexPath) as! CheckOutTableCell
            cell.parent = self
            cell.collView.reloadData()
            return cell
        } else {
            switch parent.checkOut.stage {
            case .billingAddress, .shippingAddress:
                let cell: CheckOutTableCell
                if indexPath.section == 1 {
                    cell = tableView.dequeueReusableCell(withIdentifier: "shipCell", for: indexPath) as! CheckOutTableCell
                    cell.parent = self
                    cell.prepareShippingType(stage: parent.checkOut.stage)
                    return cell
                } else {
                    if addressType == .addAddress {
                        let objField = parent.objAddressData.arrAddressField[indexPath.row]
                        cell = tableView.dequeueReusableCell(withIdentifier: objField.fieldType.rawValue, for: indexPath) as! CheckOutTableCell
                        cell.parent = self
                        cell.tag = indexPath.row
                        cell.prepareAddressFields(field: objField)
                        return cell
                    } else {
                        cell = tableView.dequeueReusableCell(withIdentifier: "addressCell", for: indexPath) as! CheckOutTableCell
                        cell.prepareBillingAddressUI(data: parent.arrAddress[indexPath.row])
                        return cell
                    }
                }
            case .shippingMethod, .paymentMethod:
                let cell: CheckOutTableCell
                let cellId = parent.checkOut.stage == .shippingMethod ? "methodCell" : "paymentCell"
                cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! CheckOutTableCell
                if parent.checkOut.stage == .shippingMethod {
                    cell.prepareShippingAddressUI(data: parent.arrShippingMethod[indexPath.row])
                } else {
                    cell.preparePaymentMethodUI(data: parent.arrPaymentMethod[indexPath.row])
                }
                return cell
            case .confirmOrder:
                if indexPath.section == 1 {
                    let cell: WishlistTableCell
                    cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as! WishlistTableCell
                    cell.prepareOrderDetailUI(data: parent.objConfirmOrder.arrItems[indexPath.row])
                    return cell
                } else if indexPath.section == 2 {
                    let cell: OrderDetailTableCell
                    cell = tableView.dequeueReusableCell(withIdentifier: "billingCell", for: indexPath) as! OrderDetailTableCell
                    cell.parentCheckOut = self.parent
                    cell.collectionView.reloadData()
                    return cell
                } else if indexPath.section == 3 {
                    let cell: OrderDetailTableCell
                    cell = tableView.dequeueReusableCell(withIdentifier: "summaryCell", for: indexPath) as! OrderDetailTableCell
                  //  cell.prepareCheckOutSumary(data: parent.objConfirmOrder.orderTotal!)
                    cell.preparePaymentSumary(data: parent.objConfirmOrder.orderDetail!)
                    return cell
                } else {
                    let cell: CheckOutTableCell
                    cell = tableView.dequeueReusableCell(withIdentifier: "termsCell", for: indexPath) as! CheckOutTableCell
                    cell.imgView.image = parent.isTermsSelected ? #imageLiteral(resourceName: "checkMark") : #imageLiteral(resourceName: "uncheckmark")
                    return cell
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch parent.checkOut.stage {
        case .billingAddress, .shippingAddress:
            guard self.addressType == .saveAddress else {return}
            parent.arrAddress.forEach{$0.isSelected = false}
            parent.arrAddress[indexPath.row].isSelected = true
        case .shippingMethod:
            parent.arrShippingMethod.forEach{$0.isSelected = false}
            parent.arrShippingMethod[indexPath.row].isSelected = true
        case .paymentMethod:
            parent.arrPaymentMethod.forEach{$0.isSelected = false}
            parent.arrPaymentMethod[indexPath.row].isSelected = true
        case .confirmOrder:
            guard indexPath.section == tableView.numberOfSections - 1 else {return}
            // Accepts terms condition here
        }
        tblView.reloadData()
    }
}

