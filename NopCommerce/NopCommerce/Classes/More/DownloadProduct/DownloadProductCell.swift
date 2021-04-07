//
//  DownloadProductCell.swift
//  NopCommerce
//
//  Created by Jayesh on 15/03/20.
//  Copyright © 2020 Chirag Patel. All rights reserved.
//

import UIKit

class DownloadProductCell: ConstrainedTableViewCell {

    @IBOutlet weak var lblOrderId: UILabel!
    @IBOutlet weak var lblOrderDate: UILabel!
    @IBOutlet weak var lblOrderProduct: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func prepareDownloadableUI(data: DownloadProduct) {
        lblOrderId.text = data.orderId
        lblOrderDate.text = Date.localDateString(from: data.createdOn, format: "MM/dd/yyyy HH:mm:ss a")
        lblOrderProduct.text = data.proName
    }

}
