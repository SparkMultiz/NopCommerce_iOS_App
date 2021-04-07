//
//  OrderTableCell.swift
//  NopCommerce
//
//  Created by Chirag Patel on 08/03/20.
//  Copyright © 2020 Chirag Patel. All rights reserved.
//

import UIKit

class OrderTableCell: ConstrainedTableViewCell {

    @IBOutlet weak var lblOrderStatus: UILabel!
    @IBOutlet weak var lblOrderTotal: UILabel!
    @IBOutlet weak var lblOrderDate: UILabel!
    @IBOutlet weak var lblOrderNumber: UILabel!
    
    @IBOutlet weak var lblOrderStatusTitle: UILabel!
    @IBOutlet weak var lblOrderTotalTitle: UILabel!
    @IBOutlet weak var lblOrderDateTitle: UILabel!
    @IBOutlet weak var lblOrderNumberTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func prepareOrderUI(data: Order) {
        lblOrderStatusTitle.text = getLocalizedKey(str: "account.customerorders.ordernumber")
        lblOrderTotalTitle.text  = getLocalizedKey(str: "account.customerorders.orderstatus")
        lblOrderDateTitle.text   = getLocalizedKey(str: "account.customerorders.orderdate")
        lblOrderNumberTitle.text = getLocalizedKey(str: "account.customerorders.ordertotal")
        
        lblOrderStatus.text = data.status
        lblOrderTotal.text = data.total
        lblOrderDate.text = data.date
        lblOrderNumber.text = data.id
    }
    
    func prepareOrderDetailUI(data: Order) {
        lblOrderStatusTitle.text = getLocalizedKey(str: "account.customerorders.ordernumber")
        lblOrderTotalTitle.text  = getLocalizedKey(str: "account.customerorders.orderstatus")
        lblOrderDateTitle.text = getLocalizedKey(str: "order.orderdate")
        lblOrderStatus.text = data.status
        lblOrderTotal.text = data.total
    }

}
