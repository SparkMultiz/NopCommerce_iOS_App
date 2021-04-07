//
//  EmptyCollCell.swift
//  Avatrac
//
//  Created by Chirag Patel on 13/04/19.
//  Copyright © 2019 Chirag Patel. All rights reserved.
//

import UIKit

class EmptyCollCell: UICollectionViewCell {

    @IBOutlet weak var lblNoDataFound: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setText(str: String) {
        lblNoDataFound.text = str
    }

}
