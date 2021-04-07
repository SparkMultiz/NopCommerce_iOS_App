//
//  NewsTableCell.swift
//  NopCommerce
//
//  Created by Chirag Patel on 23/12/20.
//  Copyright © 2020 Chirag Patel. All rights reserved.
//

import UIKit

class NewsTableCell: ConstrainedTableViewCell {

    @IBOutlet weak var lblNewsTitle: UILabel!
    @IBOutlet weak var lblNewsDesc: UILabel!
    @IBOutlet weak var lblNewsDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
