//
//  OrderVC.swift
//  NopCommerce
//
//  Created by Chirag Patel on 07/03/20.
//  Copyright © 2020 Chirag Patel. All rights reserved.
//

import UIKit

class OrderVC: ParentViewController {

    @IBOutlet var btnTopMenu: UIButton!
    @IBOutlet var btnTopBack: UIButton!
    
    var arrOrder: [Order]!
    var isFromTab = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        getOrderList()
    }
}

extension OrderVC  {
    
    func prepareUI() {
        lblHeaderTitle?.text = "My account - Orders"//getLocalizedKey(str: )
        btnTopBack.isHidden = !isFromTab
        btnTopMenu.isHidden = isFromTab
        self.hideShowHomeTabbar(isHidden: isFromTab)
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        refresh.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.addSubview(refresh)
        getNoDataCell()
    }
    
    @objc func refreshData() {
       getOrderList()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "orderDetailSegue" {
            let destVC = segue.destination as! OrderDetailVC
            destVC.objOrder = (sender as! Order)
        }
    }
}

extension OrderVC {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrOrder == nil ? 0 : 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrOrder.isEmpty ? 1 : arrOrder.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return arrOrder.isEmpty ? tableView.frame.size.height - (isFromTab ? 0 : _tabBarHeight) : UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if arrOrder.isEmpty {
            let cell: NoDataTableCell
            cell = tableView.dequeueReusableCell(withIdentifier: "noDataCell", for: indexPath) as! NoDataTableCell
            cell.setText(str: "No Order Found")
            return cell
        } else {
            let cell: OrderTableCell
            cell = tableView.dequeueReusableCell(withIdentifier: "orderCell", for: indexPath) as! OrderTableCell
            cell.prepareOrderUI(data: arrOrder[indexPath.row])
            return cell
        }
    }
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !arrOrder.isEmpty else {return}
        DispatchQueue.main.async {
            let objOrder = self.arrOrder[indexPath.row]
            self.performSegue(withIdentifier: "orderDetailSegue", sender: objOrder)
        }
    }
}

extension OrderVC {
        
    func getOrderList() {
        if !refresh.isRefreshing {
            showHud()
        }
        let param: [String: Any] = ["ApiSecretKey":secretKey, "CustomerGUID":_user.guid, "StoreId": storeId, "LanguageId": languageId]
        KPWebCall.call.getOrderList(param: param) { [weak self] (json, statusCode) in
            guard let weakself = self else {return}
            weakself.hideHud()
            weakself.refresh.endRefreshing()
            weakself.arrOrder = []
            if statusCode == 200, let dict = json as? NSDictionary, let status = dict["Status"] as? Bool, status {
                if let arrAllOrders = dict["Data"] as? [NSDictionary] {
                    for orderDict in arrAllOrders {
                        let objOrder = Order(dict: orderDict)
                        weakself.arrOrder.append(objOrder)
                    }
                }
            }
            weakself.tableView.reloadData()
        }
    }
}
