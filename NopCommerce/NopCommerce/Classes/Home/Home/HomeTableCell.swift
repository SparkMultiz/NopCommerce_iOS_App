//
//  HomeTableCell.swift
//  NopCommerce
//
//  Created by Chirag Patel on 07/03/20.
//  Copyright © 2020 Chirag Patel. All rights reserved.
//

import UIKit

class HomeTableCell: ConstrainedTableViewCell {

    @IBOutlet weak var headerCollView: UICollectionView!
    @IBOutlet weak var advCollView: UICollectionView!
    @IBOutlet weak var productCollView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var txtWelcomeView: UITextView!
    @IBOutlet weak var lblWelcomeTitle: UILabel!
    
    weak var parent: HomeVC!
        
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func prepareHomeUI(with index: Int) {
        if index == 0 {
            headerCollView.reloadData()
        } else if index == 1 {
            pageControl.numberOfPages = parent.arrNavSlider.count
            advCollView.reloadData()
        } else if index == 2 {
            prepareWelcomeUI(data: parent.welcomeTopic)
        } else {
            productCollView.reloadData()
        }
    }
    
    func prepareWelcomeUI(data: TopicDetail) {
        txtWelcomeView.attributedText = data.bodyDesc
        lblWelcomeTitle.text = data.title
    }
}

extension HomeTableCell: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL, options: [:], completionHandler: nil)
        return false
    }
}

extension HomeTableCell {
    
    @IBAction func btnMoveToWishList(_ sender: UIButton) {
        guard let idx = IndexPath.indexPathForCellContainingView(view: sender, inCollectionView: productCollView) else {return}
        let objProduct = self.tag == 3 ? parent.arrFeaturedProduct[idx.row] : parent.arrBestSellerProduct[idx.row]
        parent.moveToWishList(with: objProduct.id) { (completion) in
            self.parent.navigateToProductDetail(product: objProduct)
        }
    }
}

extension HomeTableCell: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return parent == nil ? 0 : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.tag == 0 ? parent.arrCategory.count : self.tag == 1 ? parent.arrNavSlider.count : self.tag == 3 ? parent.arrFeaturedProduct.count : parent.arrBestSellerProduct.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == productCollView {
            let cell: ProductCollectionCell
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "productCell", for: indexPath) as! ProductCollectionCell
            let objProduct = self.tag == 3 ? parent.arrFeaturedProduct[indexPath.row] : parent.arrBestSellerProduct[indexPath.row]
            cell.prepareUI(data: objProduct)
            return cell
        } else {
            let cell: ImageCollCell
            let cellId = collectionView == advCollView ? "advCell" : "cell"
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ImageCollCell
            if collectionView == advCollView {
                cell.prepareAdVUI(data: parent.arrNavSlider[indexPath.row])
            } else {
                cell.prepareCategoryUI(data: parent.arrCategory[indexPath.row])
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard self.tag == 1 && parent != nil else {return}
        guard !parent.arrNavSlider.isEmpty else {return}
        var rowIndex = indexPath.row
        if rowIndex < parent.arrNavSlider.count - 1 {
            rowIndex += 1
        } else {
            rowIndex = 0
        }
        parent.scrollTimer.invalidate()
        parent.scrollTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(startTimer(timer:)), userInfo: rowIndex, repeats: true)
    }
    
    @objc func startTimer(timer: Timer) {
        UIView.animate(withDuration: 1.0, delay: 0.2, options: .curveEaseOut, animations: {
            self.advCollView.scrollToItem(at: IndexPath(row: timer.userInfo as! Int, section: 0), at: .centeredHorizontally, animated: true)
            self.advCollView.layoutIfNeeded()
        }, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard collectionView != advCollView else {return}
        if collectionView == headerCollView {
            DispatchQueue.main.async {
                let objCategory = self.parent.arrCategory[indexPath.row]
                self.parent.performSegue(withIdentifier: "productSegue", sender: objCategory)
            }
        } else {
            DispatchQueue.main.async {
                let objProduct = self.tag == 3 ? self.parent.arrFeaturedProduct[indexPath.row] : self.parent.arrBestSellerProduct[indexPath.row]
                self.parent.performSegue(withIdentifier: "detailSegue", sender: objProduct)
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == advCollView {
            pageControl.currentPage = scrollView.currentPage
        }
    }
}

extension HomeTableCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return collectionView == advCollView ? 0 : 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return collectionView == advCollView ? 0 : 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == headerCollView {
            let width = headerCollView.frame.size.width - 10
            let height = headerCollView.frame.size.height - 10
            return CGSize(width: width / 4, height: height)
        } else if collectionView == advCollView {
            return CGSize(width: advCollView.frame.size.width, height: 160.widthRatio)
        } else {
            let width = productCollView.frame.size.width - 10
            return CGSize(width: width * 0.4, height: 210.widthRatio)
        }
    }
}
