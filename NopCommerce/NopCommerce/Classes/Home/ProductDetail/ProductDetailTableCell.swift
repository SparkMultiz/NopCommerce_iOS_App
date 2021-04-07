//
//  ProductDetailTableCell.swift
//  NopCommerce
//
//  Created by Chirag Patel on 19/03/20.
//  Copyright © 2020 Chirag Patel. All rights reserved.
//

import UIKit

class ReviewHeaderCell: ConstrainedTableViewCell {
    @IBOutlet weak var lblHeaderTitle: UILabel!
    @IBOutlet weak var reviewView: FloatRatingView!
}

enum ProductDetailCollections {
    case product, tag, bought, tier
}

class ProductDetailTableCell: ConstrainedTableViewCell {
    
    @IBOutlet weak var productCollView: UICollectionView!
    @IBOutlet weak var tagCollView: UICollectionView!
    @IBOutlet weak var boughtCollView: UICollectionView!
    @IBOutlet weak var tierCollView: UICollectionView!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var lblProductShortDesc: UILabel!
    @IBOutlet weak var lblProductPrice: UILabel!
    @IBOutlet weak var lblProductOldPrice: UILabel!
    
    @IBOutlet weak var lblProductDescription: UILabel!
    @IBOutlet weak var lblInfoHeader: UILabel!
    @IBOutlet weak var lblInfoFooter: UILabel!
    
    @IBOutlet weak var lblSpecsName: UILabel!
    @IBOutlet weak var lblSpecsValue: UILabel!
    @IBOutlet weak var specColorView: UIView!
    @IBOutlet weak var specStackView: UIStackView!
    
    @IBOutlet weak var lblReviewTitle: UILabel!
    @IBOutlet weak var lblReviewText: UILabel!
    @IBOutlet weak var lblReviewDate: UILabel!
    @IBOutlet weak var lblReviewGiver: UILabel!
    
    @IBOutlet weak var lblDownloadNotify: UILabel!
    @IBOutlet weak var imgDownloadNotifyView: UIImageView!
    
    @IBOutlet weak var reviewView: FloatRatingView!
    
    var collType: ProductDetailCollections = .product
    
    weak var parent: ProductDetailVC!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func prepareProductDetailUI(idx: IndexPath) {
        if idx.row == 0 {
            collType = .product
            if !parent.productDetail.arrPictures.isEmpty {
                productCollView.reloadData()
            }
            pageControl.numberOfPages = parent.productDetail.arrPictures.count
        } else if idx.row == 1 {
            lblProductShortDesc.text = parent.productDetail.shortDesc
            lblProductPrice.text = parent.productDetail.objPrice?.price
            lblProductOldPrice.attributedText = parent.productDetail.objPrice?.oldPrice.strikeThrough()
        } else {
            lblInfoHeader.text = getLocalizedKey(str: "products.freeshipping")
        }
    }
    
    func scrollToIndex(idx: Int) {
        productCollView.scrollToItem(at: IndexPath(row: idx, section: 0), at: .centeredHorizontally, animated: true)
    }
    
    func prepareSpecsUI(idx: IndexPath) {
        let objSpec = parent.productDetail.arrSpecification[idx.row]
        lblSpecsName.text = objSpec.name
        if objSpec.colorCode.isEmpty {
            specStackView.subviews[0].isHidden = true
            specStackView.subviews[1].isHidden = false
            lblSpecsValue.text = objSpec.text
        } else {
            specStackView.subviews[0].isHidden = false
            specStackView.subviews[1].isHidden = true
            specColorView.backgroundColor = objSpec.color
        }
    }
    
    func prepareReviewUI(idx: IndexPath) {
        lblReviewTitle.text = parent.arrReview[idx.row].title
        lblReviewText.text = parent.arrReview[idx.row].text
        lblReviewDate.text = parent.arrReview[idx.row].date
        lblReviewGiver.text = "- \(parent.arrReview[idx.row].customerName)"
        reviewView.rating = Double(parent.arrReview[idx.row].rating)
    }
}

extension ProductDetailTableCell: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return parent == nil ? 0 : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collType {
        case .product:
            return parent.productDetail.arrPictures.count
        case .tag:
            return parent.productDetail.arrTags.count
        case .bought:
            return parent.arrBoughtsProducts.count
        case .tier:
            return 1 + parent.productDetail.arrTierPrice.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collType == .bought {
            let cell: ProductCollectionCell
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "productCell", for: indexPath) as! ProductCollectionCell
            let objProduct = parent.arrBoughtsProducts[indexPath.row]
            cell.prepareUI(data: objProduct)
            return cell
        } else {
            let cell: ImageCollCell
            let cellId = collType == .product ? "productImageCell" : collType == .tier ? "tierCollCell" : "tagcell"
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ImageCollCell
            if collType == .product {
                cell.imgView.kf.indicatorType = .activity
                cell.imgView.kf.setImage(with: parent.productDetail.arrPictures[indexPath.row].bigImgUrl)
            } else if collType == .tag {
                cell.lblTitle.text = parent.productDetail.arrTags[indexPath.row].tagName
            } else {
                let arrTierPrice = parent.productDetail.arrTierPrice
                cell.lblTitle.text = indexPath.row == 0 ? getLocalizedKey(str: "products.tierprices.quantity") : "\(arrTierPrice[indexPath.row - 1].quantity)"
                cell.lblSecondTitle.text = indexPath.row == 0 ? getLocalizedKey(str: "products.tierprices.price") : arrTierPrice[indexPath.row - 1].price
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard collectionView == boughtCollView else {return}
        DispatchQueue.main.async {
            let objProduct = self.parent.arrBoughtsProducts[indexPath.row]
            self.parent.performSegue(withIdentifier: "detailSegue", sender: objProduct)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == productCollView {
            pageControl.currentPage = scrollView.currentPage
        }
    }
}

extension ProductDetailTableCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return collType == .product || collType == .tier ? 0 : 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return collType == .product || collType == .tier ? 0 : 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collType == .product {
            let collWidth = productCollView.frame.size.width
            let collHeight = productCollView.frame.size.height
            return CGSize(width: collWidth, height: collHeight)
        } else if collType == .tag {
            let tag = parent.productDetail.arrTags[indexPath.row].tagName
            let tagWidth = tag.WidthWithNoConstrainedHeight(font: UIFont.systemFont(ofSize: 15.widthRatio)) + 10
            return CGSize(width: tagWidth, height: 35.widthRatio)
        } else if collType == .bought {
            let width = boughtCollView.frame.size.width - 5
            let height = boughtCollView.frame.size.height
            return CGSize(width: width / 2, height: height)
        } else {
            let arrTier = parent.productDetail.arrTierPrice
            let width = indexPath.row == 0 ? 80.widthRatio : arrTier[indexPath.row - 1].price.WidthWithNoConstrainedHeight(font: UIFont.systemFont(ofSize: 15.widthRatio)) + 15
            let collHeight = tierCollView.frame.size.height
            return CGSize(width: width, height: collHeight)
        }
    }
}
