//
//  OrderDetailVC.swift
//  NopCommerce
//
//  Created by Chirag Patel on 08/03/20.
//  Copyright © 2020 Chirag Patel. All rights reserved.
//

import UIKit
import SafariServices

class OrderDetailVC: ParentViewController {
    
    var objOrder: Order!
    var orderDetail: OrderDetail!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        getOrderDetails()
    }
}

extension OrderDetailVC {
    
    func prepareUI() {
        lblHeaderTitle?.text = "Order #\(objOrder.id)"
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "returnOrderSegue" {
            let destVC = segue.destination as! OrderReturnVC
            destVC.objOrder = (sender as! Order)
        }
    }
}

extension OrderDetailVC {
    
    @IBAction func btnReOrderTapped(_ sender: UIButton) {
        reOrderItem()
    }
    
    @IBAction func btnReturnItemTapped(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "returnOrderSegue", sender: self.objOrder)
        }
    }
    
    @IBAction func btnViewPdfTapped(_ sender: UIButton) {
    //    let strUrl = "http://mobileapi.rebuildsucceeded.com/orderdetails/pdf/\(objOrder.id)"
    //    guard let url = URL(string: strUrl) else {return}
    //    let safariService = SFSafariViewController(url: url)
     //   present(safariService, animated: true, completion: nil)
    }
}

extension OrderDetailVC {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return orderDetail == nil ? 1 : 5
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 1 ? orderDetail.arrItems.count : 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 3 {
            let billingAddressHeight = orderDetail.billingAddress?.getAddressHeight() ?? 0
            let shippingAddress = orderDetail.shippingAddress?.getAddressHeight() ?? 0
            return billingAddressHeight + shippingAddress + 7
        } else if indexPath.section == 2 {
            return 50.widthRatio
        } else {
            return UITableView.automaticDimension
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell: OrderTableCell
            cell = tableView.dequeueReusableCell(withIdentifier: "cell\(indexPath.section)", for: indexPath) as! OrderTableCell
            cell.lblOrderDate.text = orderDetail == nil ? "" : Date.localDateString(from: orderDetail.createdDate, format: "MM/dd/yyyy HH:mm:ss a")
            cell.prepareOrderDetailUI(data: objOrder)
            return cell
        } else if indexPath.section == 1 {
            let cell: WishlistTableCell
            cell = tableView.dequeueReusableCell(withIdentifier: "cell\(indexPath.section)", for: indexPath) as! WishlistTableCell
            cell.prepareOrderDetailUI(data: orderDetail.arrItems[indexPath.row])
            return cell
        } else {
            let cell: OrderDetailTableCell
            cell = tableView.dequeueReusableCell(withIdentifier: "cell\(indexPath.section)", for: indexPath) as! OrderDetailTableCell
            cell.parent = self
            cell.prepareOrderDetailUI(idx: indexPath.section)
            return cell
        }
    }
}

extension OrderDetailVC {
    
    func getOrderDetails() {
        showHud()
        let param: [String: Any] = ["ApiSecretKey":secretKey, "CustomerGUID":_user.guid, "StoreId": storeId, "LanguageId": languageId, "OrderId": objOrder.id]
        KPWebCall.call.getOrderDetail(param: param) { [weak self] (json, statusCode) in
            guard let weakself = self else {return}
            weakself.hideHud()
            if statusCode == 200, let dict = json as? NSDictionary, let status = dict["Status"] as? Bool, status {
                if let jsonData = dict["Data"] as? NSDictionary {
                    weakself.orderDetail = OrderDetail(dict: jsonData)
                }
                weakself.tableView.reloadData()
            } else {
                weakself.showError(data: json, view: weakself.view)
            }
        }
    }
    
    func reOrderItem() {
        showHud()
        let param: [String: Any] = ["ApiSecretKey":secretKey, "CustomerGUID":_user.guid, "OrderId": objOrder.id]
        KPWebCall.call.reOrderItems(param: param) { [weak self] (json, statusCode) in
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
    
