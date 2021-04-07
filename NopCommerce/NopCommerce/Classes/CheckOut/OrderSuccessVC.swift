//
//  OrderSuccessVC.swift
//  NopCommerce
//
//  Created by Jayesh on 16/05/20.
//  Copyright © 2020 Chirag Patel. All rights reserved.
//

import UIKit

class OrderSuccessVC: ParentViewController {

    @IBOutlet weak var btnOrderDetail: UIButton!
    @IBOutlet weak var lblOrderId: UILabel!
    
    var strOrderId: String!
    
    let btnAtttribute: [NSAttributedString.Key: Any] = [
    .font: UIFont.boldSystemFont(ofSize: 18),
    .foregroundColor: UIColor.hexStringToUIColor(hexStr: "4AB2F1"),
    .underlineStyle: NSUnderlineStyle.single.rawValue]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
    }
}

extension OrderSuccessVC {
    
    func prepareUI() {
        let attributeString = NSMutableAttributedString(string: "Click here for order details.",
                                                        attributes: btnAtttribute)
        btnOrderDetail.setAttributedTitle(attributeString, for: .normal)
        lblOrderId.text = "Order number: #\(strOrderId!)"
    }
}

extension OrderSuccessVC {
    
    func popToTab(index: Int) {
        for controller in self.navigationController!.children {
            if controller is SlideMenuContainerVC {
                if let slideMenu = controller as? SlideMenuContainerVC {
                    slideMenu.tabbar.selectedIndex = index
                    self.navigationController!.popToViewController(slideMenu, animated: true)
                    break
                }
            }
        }
    }
}

extension OrderSuccessVC {
    
    @IBAction func btnContinueTapped(_ sender: UIButton) {
        self.popToTab(index: 0)
    }
    
    @IBAction func btnOrderDetailTapped(_ sender: UIButton) {
        self.popToTab(index: 3)
    }
}
