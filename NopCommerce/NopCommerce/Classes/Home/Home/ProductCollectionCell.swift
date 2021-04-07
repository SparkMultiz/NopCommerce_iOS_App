//
//  ProductCollectionCell.swift
//  NopCommerce
//
//  Created by Chirag Patel on 07/03/20.
//  Copyright © 2020 Chirag Patel. All rights reserved.
//

import UIKit

class ProductCollectionCell: ConstrainedCollectionViewCell {
    
    @IBOutlet weak var imgProductView: UIImageView!
    @IBOutlet weak var lblProductName: UILabel!
    @IBOutlet weak var lblProductPrice: UILabel!
    @IBOutlet weak var lblProductStrikePrice: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
    }
    
    func prepareUI(data: Product) {
        imgProductView.kf.indicatorType = .activity
        imgProductView.kf.setImage(with: data.objPictureModel?.imgUrl)
        lblProductName.text = data.name
        lblProductPrice.text = data.objPrice?.price
        lblProductStrikePrice.attributedText = data.objPrice?.oldPrice.strikeThrough()
    }
}


class ImageCollCell: ConstrainedCollectionViewCell {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblSecondTitle: UILabel!
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func prepareCategoryUI(data: Category) {
        lblTitle.text = data.name
        imgView.kf.indicatorType = .activity
        imgView.kf.setImage(with: data.pictureModel?.imgUrl)
    }
    
    func prepareAdVUI(data: NavoSlider) {
        imgView.kf.indicatorType = .activity
        imgView.kf.setImage(with: data.imgUrl)
    }
    
}
