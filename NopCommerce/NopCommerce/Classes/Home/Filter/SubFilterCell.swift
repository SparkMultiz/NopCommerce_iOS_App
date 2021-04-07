//
//  SubFilterCell.swift
//  NopCommerce
//
//  Created by Chirag Patel on 11/03/20.
//  Copyright © 2020 Chirag Patel. All rights reserved.
//

import UIKit

class SubFilterCell: ConstrainedTableViewCell {
    
    @IBOutlet weak var lblSubCategory: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func prepareFilterUI(filterData: FilterModel, indexPath: IndexPath, selectedSection: Int) {
        if (!filterData.isPriceFilterEmpty && selectedSection == 0) {
            let data = filterData.arrPriceFilter[indexPath.row]
            imgView.image = data.selected ? #imageLiteral(resourceName: "checkMark") : #imageLiteral(resourceName: "uncheckmark")
            lblSubCategory.text = data.strTitle
        } else {
            let index = filterData.isPriceFilterEmpty ? 0 : 1
            let data = filterData.arrSpecFilter[selectedSection - index]
                .arrAttributeOption[indexPath.row]
            imgView.image = data.selected ? #imageLiteral(resourceName: "checkMark") : #imageLiteral(resourceName: "uncheckmark")
            lblSubCategory.text = data.specName
        }
    }
    
}
