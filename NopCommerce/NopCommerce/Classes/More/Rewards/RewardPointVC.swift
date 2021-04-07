//
//  RewardPointVC.swift
//  NopCommerce
//
//  Created by Chirag Patel on 08/03/20.
//  Copyright © 2020 Chirag Patel. All rights reserved.
//

import UIKit

class RewardPointVC: ParentViewController {

    var objReward: Rewards!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        getRewardPointList()
    }
}

extension RewardPointVC {
    
    func prepareUI() {
        self.hideShowHomeTabbar(isHidden: true)
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        getNoDataCell()
    }
}

extension RewardPointVC {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return objReward == nil ? 0 : 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : objReward.arrHistory.isEmpty ? 1 : objReward.arrHistory.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 100.widthRatio : objReward.arrHistory.isEmpty ? tableView.frame.size.height - 100.widthRatio : UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return (!objReward.arrHistory.isEmpty && section == 1) ? 45.widthRatio : 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard (!objReward.arrHistory.isEmpty && section == 1) else {return nil}
        let headerView = tableView.dequeueReusableCell(withIdentifier: "headerCell") as! TableHeaderCell
        return headerView.contentView
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 1 && objReward.arrHistory.isEmpty) {
            let cell: NoDataTableCell
            cell = tableView.dequeueReusableCell(withIdentifier: "noDataCell", for: indexPath) as! NoDataTableCell
            return cell
        } else {
            let cell: RewardTableCell
            let cellId = indexPath.section == 0 ? "priceCell" : "cell"
            cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! RewardTableCell
            cell.tag = indexPath.row
            cell.prepareUI(idx: indexPath.section, data: objReward)
            return cell
        }
    }
}

extension RewardPointVC {
    
    func getRewardPointList() {
        showHud()
        let param: [String: Any] = ["ApiSecretKey":secretKey, "CustomerGUID":_user.guid, "StoreId": storeId, "CurrencyId": currencyId, "LanguageId": languageId]
        KPWebCall.call.getRewardPoints(param: param) { [weak self] (json, statusCode) in
            guard let weakself = self else {return}
            weakself.hideHud()
            if statusCode == 200, let dict = json as? NSDictionary, let status = dict["Status"] as? Bool, status {
                if let jsonData = dict["Data"] as? NSDictionary {
                    weakself.objReward = Rewards(dict: jsonData)
                }
                weakself.tableView.reloadData()
            } else {
                weakself.showError(data: json, view: weakself.view)
            }
        }
    }
}
