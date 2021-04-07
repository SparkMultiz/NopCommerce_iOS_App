//
//  SearchVC.swift
//  NopCommerce
//
//  Created by Chirag Patel on 11/03/20.
//  Copyright © 2020 Chirag Patel. All rights reserved.
//

import UIKit

class SearchVC: ParentViewController {
    
    var strSearch = ""
    var arrProducts: [Product]!
    var loadMore = LoadMore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
    }
}

extension SearchVC {
    
    func prepareUI() {
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        self.hideShowHomeTabbar(isHidden: true)
        getNoDataCell()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailSegue" {
            let destVC = segue.destination as! ProductDetailVC
            destVC.proName = (sender as! Product).name
            destVC.proId = (sender as! Product).id
        }
    }
}

extension SearchVC: UITextFieldDelegate {
    
    @IBAction func tfEditingChange(_ textField: UITextField) {
        let str = textField.text!.trimmedString()
        self.strSearch = str
        if str.isEmpty {
            self.arrProducts = []
            self.tableView.reloadData()
        } else if str.count >= 3 {
            self.loadMore = LoadMore()
            self.getProductList()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension SearchVC {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrProducts == nil ? 0 : 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrProducts.isEmpty ? 1 : arrProducts.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return arrProducts.isEmpty ? tableView.frame.size.height : UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if arrProducts.isEmpty {
            let cell: NoDataTableCell
            cell = tableView.dequeueReusableCell(withIdentifier: "noDataCell", for: indexPath) as! NoDataTableCell
            cell.setText(str: "No Product Found")
            return cell
        } else {
            let cell: SearchTableCell
            cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SearchTableCell
            cell.prepareProductUI(data: arrProducts[indexPath.row])
            if indexPath.row == arrProducts.count - 1 && !loadMore.isLoading && !loadMore.isAllLoaded {
                self.getProductList()
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !arrProducts.isEmpty else {return}
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "detailSegue", sender: self.arrProducts[indexPath.row])
        }
    }
}

extension SearchVC {
    
    func getProductList() {
        showHud()
        let loadParam: [String: Any] = ["PageNumber": loadMore.index, "PageSize": loadMore.limit]
        let param: [String: Any] = ["ApiSecretKey":secretKey, "CustomerGUID":_user.guid, "StoreId": storeId, "CurrencyId": currencyId, "LanguageId": languageId, "SearchListResponse": ["Q": strSearch], "CatalogPagingResponse": loadParam]
        KPWebCall.call.searchProduct(param: param) { [weak self] (json, statusCode) in
            guard let weakself = self else {return}
            weakself.hideHud()
            if statusCode == 200, let dict = json as? NSDictionary, let status = dict["Status"] as? Bool, status {
                if let jsonData = dict["Data"] as? NSDictionary, let allProducts = jsonData["Products"] as? [NSDictionary] {
                    if weakself.loadMore.index == 1 {
                        weakself.arrProducts = []
                    }
                    for productDict in allProducts {
                        let objProduct = Product(dict: productDict)
                        weakself.arrProducts.append(objProduct)
                    }
                    if allProducts.isEmpty {
                        weakself.loadMore.isAllLoaded = true
                    } else {
                        weakself.loadMore.index += 1
                    }
                }
                weakself.tableView.reloadData()
            } else {
                weakself.showError(data: json, view: weakself.view)
            }
        }
    }
}
