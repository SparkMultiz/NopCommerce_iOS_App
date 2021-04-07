//
//  OrderReturnTableCell.swift
//  NopCommerce
//
//  Created by Chirag Patel on 11/03/20.
//  Copyright © 2020 Chirag Patel. All rights reserved.
//

import UIKit

class OrderReturnTableCell: ConstrainedTableViewCell {

    @IBOutlet weak var lblReturnReason: UILabel!
    @IBOutlet weak var lblReturnAction: UILabel!
    @IBOutlet weak var txtComment: UITextView!
    @IBOutlet weak var lblPlaceHolder: UILabel!
    
    weak var parent: OrderReturnVC!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func prepareReturnUI(idx: Int) {
        if idx == 1 {
            lblReturnReason.text = parent.returnOrder.selectedReason.name
            lblReturnAction.text = parent.returnOrder.selectedAction.name
        } else if idx == 2 {
            txtComment.text = parent.strReason
            lblPlaceHolder.isHidden = !parent.strReason.isEmpty
        }
    }
}


extension OrderReturnTableCell: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        let str = textView.text.trimmedString()
        parent.strReason = str
        lblPlaceHolder.isHidden = !parent.strReason.isEmpty
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.isFirstResponder {
            parent.tableView.scrollToRow(at: IndexPath(row: 0, section: 2), at: .top, animated: true)
        }
    }
}

