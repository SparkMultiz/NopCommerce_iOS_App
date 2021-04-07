//
//  BlogDetailVC.swift
//  NopCommerce
//
//  Created by Chirag Patel on 23/12/20.
//  Copyright © 2020 Chirag Patel. All rights reserved.
//

import UIKit

class BlogDetailVC: ParentViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
    }
}

extension BlogDetailVC {
    
    func prepareUI() {
        self.hideShowHomeTabbar(isHidden: true)
        setKeyboardNotifications()
    }
    
}

extension BlogDetailVC {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 250.widthRatio
        } else if indexPath.section == 1 {
            return UITableView.automaticDimension
        } else if indexPath.section == 2 {
            return 110.widthRatio
        } else if indexPath.section == 3 {
            return 150.widthRatio
        } else {
            return 55.widthRatio
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: BlogDetailTableCell
        cell = tableView.dequeueReusableCell(withIdentifier: "cell\(indexPath.section)", for: indexPath) as! BlogDetailTableCell
        cell.parent = self
        cell.prepareBlogDetail(idx: indexPath.section)
        return cell
    }
}
