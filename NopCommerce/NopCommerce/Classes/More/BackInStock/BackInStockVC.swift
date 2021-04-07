//
//  BackInStockVC.swift
//  NopCommerce
//
//  Created by Chirag Patel on 08/03/20.
//  Copyright © 2020 Chirag Patel. All rights reserved.
//

import UIKit

class BackInStockVC: ParentViewController {

    var arrStock: [Subscription]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        getStockData()
    }
}

extension BackInStockVC {
    
    func prepareUI() {
        lblHeaderTitle?.text = getLocalizedKey(str: "pagetitle.backinstocksubscriptions")
        self.hideShowHomeTabbar(isHidden: true)
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        getNoDataCell()
    }
}

extension BackInStockVC {
    
    @IBAction func btnDeleteSelectedTapped(_ sender: UIButton) {
        let selectedSubsId = self.arrStock.filter{$0.isSelected}.map{$0.id}
        self.deleteSelectedStock(stocksId: selectedSubsId)
    }
}

extension BackInStockVC {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrStock == nil ? 0 : arrStock.isEmpty ? 1 : 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? arrStock.isEmpty ? 1 : arrStock.count : 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard !arrStock.isEmpty else {return tableView.frame.size.height}
        return indexPath.section == 0 ? UITableView.automaticDimension : 55.widthRatio
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if arrStock.isEmpty {
            let cell: NoDataTableCell
            cell = tableView.dequeueReusableCell(withIdentifier: "noDataCell", for: indexPath) as! NoDataTableCell
            return cell
        } else {
            let cell: BackInStockCell
            let cellID = indexPath.section == 0 ? "cell" : "btnCell"
            cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! BackInStockCell
            if cellID.isEqual(str: "cell") {
                cell.prepareStockVC(data: arrStock[indexPath.row])
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let isSelected = arrStock[indexPath.row].isSelected
        arrStock[indexPath.row].isSelected = !isSelected
        tableView.reloadData()
    }
}

extension BackInStockVC {
    
    func getStockData() {
        showHud()
        let param: [String: Any] = ["ApiSecretKey":secretKey, "CustomerGUID":_user.guid, "StoreId": storeId]
        KPWebCall.call.getBackInStocks(param: param) { [weak self] (json, statusCode) in
            guard let weakself = self else {return}
            weakself.hideHud()
            weakself.arrStock = []
            if statusCode == 200, let dict = json as? NSDictionary, let status = dict["Status"] as? Bool, status {
                if let jsonData = dict["Data"] as? NSDictionary, let arrSubscription = jsonData["Subscriptions"] as? [NSDictionary] {
                    for stockDict in arrSubscription {
                        let objStock = Subscription(dict: stockDict)
                        weakself.arrStock.append(objStock)
                    }
                }
            }
            weakself.tableView.reloadData()
        }
    }
    
    func deleteSelectedStock(stocksId: [String]) {
        showHud()
        let param: [String: Any] = ["ApiSecretKey":secretKey, "CustomerGUID":_user.guid, "SubscriptionIds": stocksId]
        KPWebCall.call.deleteStocks(param: param) { [weak self] (json, statusCode) in
            guard let weakself = self else {return}
            weakself.hideHud()
            if statusCode == 200, let dict = json as? NSDictionary, let status = dict["Status"] as? Bool, status {
                if let jsonData = dict["Data"] as? NSDictionary {
                    weakself.showSuccessMsg(data: jsonData, view: weakself.view)
                }
                weakself.getStockData()
            } else {
                weakself.showError(data: json, view: weakself.view)
            }
        }
    }
}
