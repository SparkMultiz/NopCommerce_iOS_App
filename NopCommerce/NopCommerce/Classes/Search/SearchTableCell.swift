//
//  SearchTableCell.swift
//  NopCommerce
//
//  Created by Chirag Patel on 18/03/20.
//  Copyright © 2020 Chirag Patel. All rights reserved.
//

import UIKit

class SearchTableCell: ConstrainedTableViewCell {

    @IBOutlet weak var imgProductView: UIImageView!
    @IBOutlet weak var lblProductTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func prepareProductUI(data: Product) {
        imgProductView.kf.indicatorType = .activity
        imgProductView.kf.setImage(with: data.objPictureModel?.imgUrl, placeholder: _placeImage)
        lblProductTitle.text = data.name
    }

}
