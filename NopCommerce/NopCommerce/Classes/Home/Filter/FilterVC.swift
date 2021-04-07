//
//  FilterVC.swift
//  NopCommerce
//
//  Created by Chirag Patel on 11/03/20.
//  Copyright © 2020 Chirag Patel. All rights reserved.
//

import UIKit

protocol FilterDataDelegate: NSObjectProtocol {
    func applyFileredData(data: FilterModel)
    func reloadTableData()
}

var _filterData: FilterModel!

class FilterVC: ParentViewController {

    @IBOutlet weak var tblMainCategory: UITableView!
    @IBOutlet weak var tblSubCategory: UITableView!
    
    @IBOutlet weak var lblFilterBy: UILabel!
    @IBOutlet weak var btnClearAll: UIButton!
    @IBOutlet weak var btnApplyAll: UIButton!
    
    @IBOutlet weak var btmBtnConst: NSLayoutConstraint!
    @IBOutlet weak var btmBtnView: UIView!
    
    var objCategoryId: String?
    var filterData: FilterModel!
    var selectedMainCatIdx = 0
    var catName: String!

    weak var delegate: FilterDataDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        loadFilterData()
    }
}

extension FilterVC {
    
    func prepareUI(){
        lblHeaderTitle?.text = catName
        self.hideShowHomeTabbar(isHidden: true)
        tblMainCategory.tableFooterView = UIView()
        tblSubCategory.tableFooterView = UIView()
        lblFilterBy.text = getLocalizedKey(str: "filtering.pricerangefilter")
       // btnClearAll.setTitle(getLocalizedKey(str: "plugins.nopaccelerateplus.search.field.facet.clearall"), for: .normal)
       // btnApplyAll.setTitle(getLocalizedKey(str: ""), for: .normal)
        btmBtnConst.constant = _bottomAreaSpacing + 44
        tblMainCategory.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 55, right: 0)
        tblSubCategory.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 55, right: 0)
    }
    
    func reloadData() {
        tblMainCategory.reloadData()
        tblSubCategory.reloadData()
    }
}

extension FilterVC {
    
    @IBAction func btnApplyTapped(_ sender: UIButton) {
        guard filterData != nil && filterData.arrCount != 0 else {return}
        let selectedPrice = self.filterData.arrPriceFilter.filter{$0.selected}
        let seletedSpec = self.filterData.arrSpecFilter.flatMap{$0.arrAttributeOption.filter{$0.selected}}
        guard let delegate = delegate else {return}
        if selectedPrice.isEmpty && seletedSpec.isEmpty {
             _filterData = nil
            delegate.reloadTableData()
        } else {
             delegate.applyFileredData(data: filterData)
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnClearAllTapped(_ sender: UIButton) {
        guard filterData != nil && filterData.arrCount != 0 else {return}
        self.filterData.arrPriceFilter.forEach{$0.selected = false}
        self.filterData.arrSpecFilter.forEach{$0.arrAttributeOption.forEach{$0.selected = false}}
        reloadData()
    }
}

extension FilterVC {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return filterData == nil ? 0 : tableView == tblMainCategory ? filterData.arrCount : 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard filterData.arrCount != 0 else {return 0}
        if tableView == tblMainCategory {
            return 1
        } else {
            let index = filterData.isPriceFilterEmpty ? 0 : 1
            return (!filterData.isPriceFilterEmpty && selectedMainCatIdx == 0) ? filterData.arrPriceFilter.count : filterData.arrSpecFilter[selectedMainCatIdx - index].arrAttributeOption.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.widthRatio
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == tblMainCategory {
            let cell: MainFilterCell
            cell = tableView.dequeueReusableCell(withIdentifier: "mainFilterCell", for: indexPath) as! MainFilterCell
            cell.prepareFilterUI(filterData: filterData, indexPath: indexPath, selectedSection: selectedMainCatIdx)
            return cell
        } else {
            let cell: SubFilterCell
            cell = tableView.dequeueReusableCell(withIdentifier: "subFilterCell", for: indexPath) as! SubFilterCell
            cell.prepareFilterUI(filterData: filterData, indexPath: indexPath, selectedSection: selectedMainCatIdx)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard filterData.arrCount != 0 else {return}
        if tableView == tblMainCategory {
            selectedMainCatIdx = indexPath.section
            tblMainCategory.reloadData()
        } else {
            if (!filterData.isPriceFilterEmpty && selectedMainCatIdx == 0) {
                let isSelected = filterData.arrPriceFilter[indexPath.row].selected
                filterData.arrPriceFilter[indexPath.row].selected = !isSelected
            } else {
                let index = filterData.isPriceFilterEmpty ? 0 : 1
                let isSelected = filterData.arrSpecFilter[selectedMainCatIdx - index]
                    .arrAttributeOption[indexPath.row].selected
                filterData.arrSpecFilter[selectedMainCatIdx - index]
                .arrAttributeOption[indexPath.row].selected = !isSelected
            }
        }
        tblSubCategory.reloadData()
    }
}

extension FilterVC {
    
    func loadFilterData() {
        guard objCategoryId != nil else {return}
        let param: [String: Any] = ["ApiSecretKey":secretKey,"CustomerGUID": _user.guid, "LanguageId": languageId,"StoreId": storeId, "CurrencyId": currencyId, "CategoryId": objCategoryId!]
        showHud()
        KPWebCall.call.loadFilterData(param: param) { [weak self] (json, statusCode) in
            guard let weakself = self else {return}
            weakself.hideHud()
            if statusCode == 200, let dict = json as? NSDictionary, let status = dict["Status"] as? Bool, status {
                if let jsonData = dict["Data"] as? NSDictionary {
                    weakself.filterData = FilterModel(dict: jsonData)
                }
                if weakself.filterData.arrCount == 0 {
                    JTValidationToast.show(message: "No Filter Added")
                    weakself.navigationController?.popViewController(animated: true)
                }
                weakself.btmBtnView.isHidden = weakself.filterData.arrCount == 0
                weakself.reloadData()
            } else {
                weakself.showError(data: json, view: weakself.view)
            }
        }
    }
}
