//
//  ReviewVC.swift
//  NopCommerce
//
//  Created by Chirag Patel on 23/03/20.
//  Copyright © 2020 Chirag Patel. All rights reserved.
//

import UIKit

class ReviewModel {
    
    var title = ""
    var text = ""
    var rating = "4"
    
    func validatetData() -> (isValid: Bool, error: String) {
        var result = (isValid: true, error: "")
        
        if String.validateStringValue(str: title){
            result.isValid = false
            result.error = kEnterSubject
            return result
        }
        
        if String.validateStringValue(str: text){
            result.isValid = false
            result.error = kEnterMessage
            return result
        }
        return result
    }
    
    func paramDict() -> [String: Any] {
        var dict: [String: Any] = [:]
        
        let reviewDict: [String: Any] = [
            "Title": title,
            "ReviewText": text,
            "Rating": rating,
            "DisplayCaptcha": "true",
            "CanCurrentCustomerLeaveReview": "true",
            "SuccessfullyAdded": "false",
            "Result": "Abc"]
        
        dict["StoreId"] = storeId
        dict["ApiSecretKey"] = secretKey
        dict["CustomerGUID"] = _user.guid
        dict["CaptchaValid"] = true
        dict["ProductReviewRequest"] = reviewDict
        return dict
    }
}


class ReviewVC: ParentViewController {
    
    var data = ReviewModel()
    
    var proId: String?
    var proName: String!
    
    var reviewBlock: (() -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
    }
}

extension ReviewVC {
    
    func prepareUI() {
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        setKeyboardNotifications()
    }
}

extension ReviewVC {
    
    @IBAction func btnAddReview(_ sender: UIButton) {
        self.view.endEditing(true)
        self.addReview()
//        let validate = self.data.validatetData()
//        if validate.isValid {
//            self.addReview()
//        } else {
//            JTValidationToast.show(message: validate.error)
//        }
    }
}

extension ReviewVC {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 0 ? UITableView.automaticDimension : indexPath.row == 1 ? 60.widthRatio : indexPath.row == 2 ? 120.widthRatio : indexPath.row == 3 ? 70.widthRatio : 55.widthRatio
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ReviewTableCell
        cell = tableView.dequeueReusableCell(withIdentifier: "cell\(indexPath.row)", for: indexPath) as! ReviewTableCell
        cell.parent = self
        cell.configureReviewUI(idx: indexPath)
        return cell
    }
}

extension ReviewVC {
    
    func addReview() {
        guard proId != nil else {return}
        showHud()
        var paramDict = data.paramDict()
        paramDict["ProductId"] = proId!
        KPWebCall.call.addProductReview(param: paramDict) { [weak self] (json, statusCode) in
            guard let weakself = self else {return}
            weakself.hideHud()
            if statusCode == 200, let dict = json as? NSDictionary, let status = dict["Status"] as? Bool, status {
                if let jsonData = dict["Data"] as? NSDictionary {
                    weakself.reviewBlock?()
                    weakself.showSuccMsg(dict: jsonData)
                }
            } else {
                weakself.showError(data: json, view: weakself.view)
            }
        }
    }
}
