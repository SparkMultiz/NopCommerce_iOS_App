//
//  OnBoardingVC.swift
//  NopCommerce
//
//  Created by Chirag Patel on 06/03/20.
//  Copyright © 2020 Chirag Patel. All rights reserved.
//

import UIKit

class OnBoardingVC: ParentViewController {

    @IBOutlet weak var btnSkip: UIButton!
    @IBOutlet weak var btnContinue: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //prepareUI()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    func prepareUI() {
        btnSkip.setTitle(arrLang.first{$0.name.isEqual(str: "abc")}?.name, for: .normal)
        btnContinue.setTitle(arrLang.first{$0.name.isEqual(str: "prq")}?.name, for: .normal)
    }
    
}

extension OnBoardingVC {
    
    @IBAction func btnSkipContinueTapped(_ sender: UIButton) {
        _userDefault.setOnBoardingStatus(value: true)
        self.performSegue(withIdentifier: "loginSegue", sender: nil)
    }
}

extension OnBoardingVC: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: SingleImageCollCell
        cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! SingleImageCollCell
        cell.imgView.image = UIImage(named: "ic_OnBoarding_\(indexPath.row + 1)")
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == collectionView {
            let currPage = scrollView.currentPage
            btnSkip.isHidden = currPage == 2
            btnContinue.isHidden = currPage != 2
            pageControl.currentPage = currPage
        }
    }
}

extension OnBoardingVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: -5, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: _screenSize.width, height: _screenSize.height)
    }
}
