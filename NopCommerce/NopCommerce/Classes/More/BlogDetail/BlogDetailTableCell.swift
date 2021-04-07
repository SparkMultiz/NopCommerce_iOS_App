//
//  BlogDetailTableCell.swift
//  NopCommerce
//
//  Created by Chirag Patel on 23/12/20.
//  Copyright © 2020 Chirag Patel. All rights reserved.
//

import UIKit

class BlogDetailTableCell: UITableViewCell {

    @IBOutlet weak var collView: UICollectionView!
    
    weak var parent: BlogDetailVC!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
   
    func prepareBlogDetail(idx: Int) {
        if idx == 2 {
            collView.reloadData()
        }
    }
}

extension BlogDetailTableCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ImageCollCell
        cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tagcell", for: indexPath) as! ImageCollCell
        //cell.lblTitle.text = parent.productDetail.arrTags[indexPath.row].tagName
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let tag = "Tag Name"//parent.productDetail.arrTags[indexPath.row].tagName
        let tagWidth = tag.WidthWithNoConstrainedHeight(font: UIFont.systemFont(ofSize: 15.widthRatio)) + 10
        return CGSize(width: tagWidth, height: 35.widthRatio)
    }
}
