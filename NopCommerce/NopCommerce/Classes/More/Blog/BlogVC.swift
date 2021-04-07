//
//  BlogVC.swift
//  NopCommerce
//
//  Created by Chirag Patel on 23/12/20.
//  Copyright © 2020 Chirag Patel. All rights reserved.
//

import UIKit

class BlogVC: ParentViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.hideShowHomeTabbar(isHidden: false)
    }
}

extension BlogVC {
    
    func prepareUI() {
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
}

extension BlogVC {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150.widthRatio
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: BlogTableCell
        cell = tableView.dequeueReusableCell(withIdentifier: "blogCell", for: indexPath) as! BlogTableCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "detailSegue", sender: nil)
        }
    }
}
