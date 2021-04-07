//
//  LanguageVC.swift
//  NopCommerce
//
//  Created by Chirag Patel on 21/05/20.
//  Copyright © 2020 Chirag Patel. All rights reserved.
//

import UIKit

class LanguageVC: ParentViewController {
    
    @IBOutlet weak var btnBack: UIButton!
    
    var arrLanguge: [Languages]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        getAppLanguages()
    }
}

extension LanguageVC {
    
    func prepareUI() {
        btnBack.isHidden = _user == nil
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        getNoDataCell()
    }
    
    func navToOnBoarding() {
        _appDelegator.setViewApperance()
        if _user != nil {
            _appDelegator.navigateUser()
        } else {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "onBoardingSegue", sender: nil)
            }
        }
    }
    
    func setSelectedInd(ind: Int) {
        for(idx,lang) in arrLanguge.enumerated() {
            if ind == idx {
                lang.isSelected = true
            } else {
                lang.isSelected = false
            }
        }
        tableView.reloadData()
    }
    
    @IBAction func btnSelectLanguageTapped(_ sender: UIButton) {
        let selectedLang = arrLanguge.filter{$0.isSelected}.first
        guard selectedLang != nil else {return}
        languageId = selectedLang!.id
        self.setLanguage()
        _appDelegator.isArabic = selectedLang!.name.isEqual(str: "Arabic")
    }
}

extension LanguageVC {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrLanguge == nil ? 0 : 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrLanguge.isEmpty ? 1 : arrLanguge.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return arrLanguge.isEmpty ? tableView.frame.size.height : 60.widthRatio
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if arrLanguge.isEmpty {
            let cell: NoDataTableCell
            cell = tableView.dequeueReusableCell(withIdentifier: "noDataCell", for: indexPath) as! NoDataTableCell
            cell.setText(str: "No Language Found...")
            return cell
        } else {
            let cell: TableHeaderCell
            cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableHeaderCell
            let objLang = arrLanguge[indexPath.row]
            cell.lblTitle.text = objLang.name
            cell.lblTitle.font = objLang.isSelected ? UIFont.boldSystemFont(ofSize: 17.widthRatio) : UIFont.systemFont(ofSize: 16.widthRatio)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !arrLanguge.isEmpty else {return}
        setSelectedInd(ind: indexPath.row)
    }
}

extension LanguageVC {
    
    func getAppLanguages() {
        showHud()
        KPWebCall.call.getAppLanguages(param: ["ApiSecretKey": secretKey, "StoreId": storeId]) { [weak self] (json, statusCode) in
            guard let weakself = self else {return}
            weakself.hideHud()
            weakself.arrLanguge = []
            if statusCode == 200, let dict = json as? NSDictionary, let status = dict["Status"] as? Bool, status {
                if let jsonData = dict["Data"] as? NSDictionary, let arrAvailableLanguages = jsonData["AvailableLanguages"] as? [NSDictionary] {
                    for languageDict in arrAvailableLanguages {
                        let objLanguage = Languages(dict: languageDict)
                        if objLanguage.id.isEqual(str: "1") {
                            objLanguage.isSelected = true
                        }
                        weakself.arrLanguge.append(objLanguage)
                    }
                }
                weakself.tableView.reloadData()
            } else {
                weakself.showError(data: json, view: weakself.view)
            }
        }
    }
    
    func setLanguage() {
        showHud()
        KPWebCall.call.setAppLanguage(param: ["ApiSecretKey": secretKey, "StoreId": storeId, "LanguageId": languageId]) { [weak self] (json, statusCode) in
            guard let weakself = self else {return}
            if statusCode == 200, let dict = json as? NSDictionary, let status = dict["Status"] as? Bool, status {
                _appDelegator.storeCurrentLangId(id: languageId)
                weakself.getLanguageResource()
            } else {
                weakself.showError(data: json, view: weakself.view)
            }
        }
    }
    
    func getLanguageResource() {
        KPWebCall.call.getLangaugeResourceString(param: ["ApiSecretKey": secretKey, "LanguageId": languageId]) { (json, statusCode) in
            self.hideHud()
            if statusCode == 200, let dict = json as? NSDictionary, let status = dict["Status"] as? Bool, status {
                if let langData = dict["Data"] as? NSDictionary, let arrResources = langData["AvailableLanguageResourceString"] as? [NSDictionary] {
                    arrLang = []
                    for langDict in arrResources {
                        let objLang = Language.addUpdateEntity(key: "name", value: langDict.getStringValue(key: "Name"))
                        objLang.initWith(dict: langDict)
                        arrLang.append(objLang)
                    }
                    _appDelegator.saveContext()
                }
                self.navToOnBoarding()
            }
        }
    }
}
