//
//  MainFilterCell.swift
//  NopCommerce
//
//  Created by Chirag Patel on 11/03/20.
//  Copyright © 2020 Chirag Patel. All rights reserved.
//

import UIKit

class MainFilterCell: ConstrainedTableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func prepareFilterUI(filterData: FilterModel, indexPath: IndexPath, selectedSection: Int) {
        let boldFont = UIFont.boldSystemFont(ofSize: 17.widthRatio)
        let regularFont = UIFont.systemFont(ofSize: 17.widthRatio)
        lblTitle.font = indexPath.section == selectedSection ? boldFont : regularFont
        contentView.backgroundColor = indexPath.section == selectedSection ? .white : .clear
        if (!filterData.isPriceFilterEmpty && indexPath.section == 0) {
            lblTitle.text = "Price"
        } else {
            let index = filterData.isPriceFilterEmpty ? 0 : 1
            lblTitle.text = filterData.arrSpecFilter[indexPath.section - index].attributeName
        }
    }
}
