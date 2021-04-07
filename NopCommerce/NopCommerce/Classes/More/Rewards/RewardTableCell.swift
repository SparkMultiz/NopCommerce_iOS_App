//
//  RewardTableCell.swift
//  NopCommerce
//
//  Created by Jayesh on 15/03/20.
//  Copyright © 2020 Chirag Patel. All rights reserved.
//

import UIKit

class RewardTableCell: ConstrainedTableViewCell {

    @IBOutlet weak var lblBalance: UILabel!
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var lblPointsMsg: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func prepareUI(idx: Int, data: Rewards) {
        if idx == 0 {
            lblBalance.text = "\(data.balance)"
            lblAmount.text = data.amount
        } else {
            lblPointsMsg.text = data.arrHistory[self.tag].message
            lblDate.text = Date.localDateString(from: data.arrHistory[self.tag].createdOn)
        }
    }
}
