//
//  NewsVC.swift
//  NopCommerce
//
//  Created by Chirag Patel on 23/12/20.
//  Copyright © 2020 Chirag Patel. All rights reserved.
//

import UIKit

class NewsVC: ParentViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
    }
}

extension NewsVC {
    
    func prepareUI() {
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
    }
    
}

extension NewsVC {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: NewsTableCell
        cell = tableView.dequeueReusableCell(withIdentifier: "newsCell", for: indexPath) as! NewsTableCell
        return cell
    }
}
