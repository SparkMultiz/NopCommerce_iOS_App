//
//  BackInStockCell.swift
//  NopCommerce
//
//  Created by Jayesh on 15/03/20.
//  Copyright © 2020 Chirag Patel. All rights reserved.
//

import UIKit

class BackInStockCell: ConstrainedTableViewCell {

    @IBOutlet weak var lblProductTitle: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func prepareStockVC(data: Subscription) {
        lblProductTitle.text = data.proName
        imgView.image = data.isSelected ? #imageLiteral(resourceName: "checkMark") : #imageLiteral(resourceName: "uncheckmark")
    }

}
