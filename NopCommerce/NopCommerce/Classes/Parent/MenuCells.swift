//
//  MenuCells.swift
//  AussieFood
//
//  Created by Yudiz Solutions Pvt.Ltd. on 12/09/16.
//  Copyright © 2016 Yudiz Solutions Pvt.Ltd. All rights reserved.
//

import Foundation
import UIKit

//MARK: - Menu Item Cell

class MenuItemCell: ConstrainedTableViewCell {
    
    @IBOutlet weak var selectedView: UIView!
    @IBOutlet weak var btnExpand: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var tblConst: NSLayoutConstraint!
    @IBOutlet weak var btnSection: UIButton!
    @IBOutlet weak var lblDivider: UILabel!
    
    @IBOutlet weak var imgDropDown: UIImageView!
    
    var subCategory: SubCategory!
    weak var parent: SlideMenuContainerVC!
    
    var selectedSubIndex = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func prepareUI() {
        lblTitle.text = subCategory.name
        btnExpand.isHidden = subCategory.innerSubCat.isEmpty
        selectedView.isHidden = !self.subCategory.isViewEnable
        contentView.backgroundColor = self.subCategory.isViewEnable ? #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) : #colorLiteral(red: 0.1215686275, green: 0.1294117647, blue: 0.1411764706, alpha: 1)
        btnExpand.setImage(self.subCategory.isRowSelected ? UIImage(named: "ic_minus") : UIImage(named: "ic_plus") , for: .normal)
        tblConst.constant = subCategory.isRowSelected ? CGFloat(subCategory.innerSubCat.count) * (45.widthRatio) : 0
        layoutIfNeeded()
    }
}

extension MenuItemCell: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return subCategory == nil ? 0 : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subCategory.innerSubCat.isEmpty ? 0 : subCategory.innerSubCat.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45.widthRatio
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "innerCell", for: indexPath) as! MenuItemCell
        cell.lblTitle.text = subCategory.innerSubCat[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.parent.setSelectedInnerIdx(ind: self.selectedSubIndex, section: self.tag, innerIdx: indexPath.row)
            self.tblView.reloadData()
            let objCat = self.subCategory.innerSubCat[indexPath.row]
            self.parent.prepareProduct(with: objCat.id, name: objCat.name, objCat: arrCategories[self.tag])
        }
    }
}
