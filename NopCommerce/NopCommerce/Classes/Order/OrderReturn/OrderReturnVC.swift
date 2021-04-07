//
//  OrderReturnVC.swift
//  NopCommerce
//
//  Created by Chirag Patel on 11/03/20.
//  Copyright © 2020 Chirag Patel. All rights reserved.
//

import UIKit

class OrderReturnVC: ParentViewController {
    
    var objOrder: Order!
    var returnOrder: ReturnOrder!
    var strReason = ""
    var dropDown = DropDown()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        getReturnList()
    }
}

extension OrderReturnVC {
    
    func prepareUI() {
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        setKeyboardNotifications()
    }
    
    func configureDropDown(sender: UIButton) {
        dropDown.tag = sender.tag
        dropDown.anchorView = sender
        dropDown.textFont = UIFont.systemFont(ofSize: 15.widthRatio)
        dropDown.bottomOffset = CGPoint(x: 0, y: sender.bounds.height)
        dropDown.direction = .bottom
        dropDown.width = sender.frame.size.width
        dropDown.cellHeight = 50.widthRatio
        dropDown.backgroundColor = #colorLiteral(red: 0.9725490196, green: 0.9725490196, blue: 0.9725490196, alpha: 1)
        dropDown.textColor = UIColor.black
        dropDown.selectionBackgroundColor = UIColor.clear
    }
}


extension OrderReturnVC {
    
    @IBAction func btnQuantityDropDown(_ sender: UIButton) {
        configureDropDown(sender: sender)
        dropDown.dataSource.removeAll()
        let qtyCount = self.returnOrder.arrItems.map{$0.quantity}.first ?? 1
        dropDown.dataSource = (1...qtyCount).map{"\($0)"}
        dropDown.selectionAction = { [weak self] (index: Int, item: String) in
            guard let weakself = self else {return}
            weakself.returnOrder.arrItems[sender.tag].quantity = item.integerValue ?? 0
            weakself.tableView.reloadRows(at: [IndexPath(row: sender.tag, section: 0)], with: .none)
        }
    }
    
    @IBAction func btnDropDownTapped(_ sender: UIButton) {
        configureDropDown(sender: sender)
        dropDown.dataSource.removeAll()
        if dropDown.tag == 0 {
            dropDown.dataSource = self.returnOrder.arrReturnReason.map{$0.name}
            _ = self.returnOrder.arrReturnReason.map{$0.isSelected = false}
            dropDown.selectionAction = { [weak self] (index: Int, item: String) in
                guard let weakself = self else {return}
                weakself.returnOrder.arrReturnReason[index].isSelected = true
                weakself.tableView.reloadRows(at: [IndexPath(row: sender.tag, section: 1)], with: .none)
            }
        } else {
            dropDown.dataSource = self.returnOrder.arrReturnAction.map{$0.name}
            _ = self.returnOrder.arrReturnAction.map{$0.isSelected = false}
            dropDown.selectionAction = { [weak self] (index: Int, item: String) in
                guard let weakself = self else {return}
                weakself.returnOrder.arrReturnAction[index].isSelected = true
                weakself.tableView.reloadRows(at: [IndexPath(row: sender.tag, section: 1)], with: .none)
            }
        }
        dropDown.show()
    }
    
    @IBAction func btnReturnOrder(_ sender: UIButton) {
        if self.strReason.isEmpty {
           JTValidationToast.show(message: kEnterMessage)
        } else {
            self.returnOrderRequest()
        }
    }
}

extension OrderReturnVC {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return returnOrder == nil ? 0 : 4
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? returnOrder.arrItems.count : 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? UITableView.automaticDimension : indexPath.section == 1 ? 200.widthRatio : indexPath.section == 2 ? 120.widthRatio : 55.widthRatio
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell: WishlistTableCell
            cell = tableView.dequeueReusableCell(withIdentifier: "cell\(indexPath.section)", for: indexPath) as! WishlistTableCell
            cell.btnDropDown.tag = indexPath.row
            cell.prepareOrderDetailUI(data: returnOrder.arrItems[indexPath.row])
            return cell
        } else {
            let cell: OrderReturnTableCell
            cell = tableView.dequeueReusableCell(withIdentifier: "cell\(indexPath.section)", for: indexPath) as! OrderReturnTableCell
            cell.parent = self
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let returnCell = cell as? OrderReturnTableCell {
            returnCell.prepareReturnUI(idx: indexPath.section)
        }
    }
}

extension OrderReturnVC {
    
    func getReturnList() {
        showHud()
        let param: [String: Any] = ["ApiSecretKey":secretKey, "CustomerGUID":_user.guid, "StoreId": storeId, "OrderId": objOrder.id]
        KPWebCall.call.getReturnOrderList(param: param) { [weak self] (json, statusCode) in
            guard let weakself = self else {return}
            weakself.hideHud()
            if statusCode == 200, let dict = json as? NSDictionary, let status = dict["Status"] as? Bool, status {
                if let jsonData = dict["Data"] as? NSDictionary {
                    weakself.returnOrder = ReturnOrder(dict: jsonData)
                }
                weakself.tableView.reloadData()
            } else {
                weakself.showError(data: json, view: weakself.view)
            }
        }
    }
    
    func getSelectedDict() -> [NSDictionary] {
        var cartItems: [NSDictionary] = []
        for (_,item) in self.returnOrder.arrItems.enumerated() {
            cartItems.append(["OrderItemId": item.id, "Quantity": item.quantity])
        }
        return cartItems
    }
    
    func returnOrderRequest() {
        showHud()
        let param: [String: Any] = ["ApiSecretKey":secretKey, "CustomerGUID":_user.guid, "StoreId": storeId, "OrderId": objOrder.id, "ReturnRequestReasonId": returnOrder.selectedReason.id, "ReturnRequestActionId": returnOrder.selectedAction.id, "Comments" : strReason, "AllowFiles": "false", "OrderItemModelList": getSelectedDict()]
        KPWebCall.call.returnOrder(param: param) { [weak self] (json, statusCode) in
            guard let weakself = self else {return}
            weakself.hideHud()
            if statusCode == 200, let dict = json as? NSDictionary, let status = dict["Status"] as? Bool, status {
                weakself.showSuccMsg(dict: dict)
            } else {
                weakself.showError(data: json, view: weakself.view)
            }
        }
    }
}
