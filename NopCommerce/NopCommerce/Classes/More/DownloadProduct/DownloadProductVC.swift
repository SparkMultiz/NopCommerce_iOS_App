//
//  DownloadProductVC.swift
//  NopCommerce
//
//  Created by Chirag Patel on 08/03/20.
//  Copyright © 2020 Chirag Patel. All rights reserved.
//

import UIKit

class DownloadProductVC: ParentViewController {

    var arrItems: [DownloadProduct]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        getDownloadedItems()
    }
}

extension DownloadProductVC {
    
    func prepareUI() {
        self.hideShowHomeTabbar(isHidden: true)
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        getNoDataCell()
    }
}

extension DownloadProductVC {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrItems == nil ? 0 : 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrItems.isEmpty ? 1 : arrItems.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return arrItems.isEmpty ? tableView.frame.size.height : UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if arrItems.isEmpty {
            let cell: NoDataTableCell
            cell = tableView.dequeueReusableCell(withIdentifier: "noDataCell", for: indexPath) as! NoDataTableCell
            return cell
        } else {
            let cell: DownloadProductCell
            cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! DownloadProductCell
            cell.prepareDownloadableUI(data: arrItems[indexPath.row])
            return cell
        }
    }
    
}

extension DownloadProductVC {
    
    func getDownloadedItems() {
        showHud()
        let param: [String: Any] = ["ApiSecretKey":secretKey, "CustomerGUID":_user.guid]
        KPWebCall.call.getDownloadedProducts(param: param) { [weak self] (json, statusCode) in
            guard let weakself = self else {return}
            weakself.hideHud()
            weakself.arrItems = []
            if statusCode == 200, let dict = json as? NSDictionary, let status = dict["Status"] as? Bool, status {
                if let jsonData = dict["Data"] as? NSDictionary, let arrAllItems = jsonData["Items"] as? [NSDictionary] {
                    for itemDict in arrAllItems {
                        let objItem = DownloadProduct(dict: itemDict)
                        weakself.arrItems.append(objItem)
                    }
                }
                weakself.tableView.reloadData()
            } else {
                weakself.showError(data: json, view: weakself.view)
            }
        }
    }
}
