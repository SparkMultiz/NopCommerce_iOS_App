//
//  NoDataTableCell.swift
//  Avatrac
//
//  Created by Chirag Patel on 10/04/19.
//  Copyright © 2019 Chirag Patel. All rights reserved.
//

import UIKit

class NoDataTableCell: ConstrainedTableViewCell {

    @IBOutlet weak var lblNoData: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setText(str: String) {
        lblNoData.text = str
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
