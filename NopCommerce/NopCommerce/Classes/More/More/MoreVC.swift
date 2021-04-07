//
//  MoreVC.swift
//  NopCommerce
//
//  Created by Chirag Patel on 07/03/20.
//  Copyright © 2020 Chirag Patel. All rights reserved.
//

import UIKit

enum ProfileList : String, CaseIterable {
    case UserProfile = "UserProfile"
    case ChangePassword = "Change Password"
    case Orders = "Orders"
    case DownlableProducts = "Downloadable Products"
    case BackInStock = "Back In Stock"
    case RewardPoints = "Reward Points"
    
    var img: UIImage {
        switch self {
        case .UserProfile:
            return #imageLiteral(resourceName: "user-profile")
        case .ChangePassword:
            return #imageLiteral(resourceName: "lock")
        case .Orders:
            return #imageLiteral(resourceName: "box-open")
        case .DownlableProducts:
            return #imageLiteral(resourceName: "download-blk")
        case .BackInStock:
            return #imageLiteral(resourceName: "boxes")
        case .RewardPoints:
            return #imageLiteral(resourceName: "trophy")
        }
    }
    
    var storyBoardId: String {
        switch self {
        case .UserProfile:
            return "ProfileVC"
        case .ChangePassword:
            return "ChangePasswordVC"
        case .Orders:
            return "ProfileVC"
        case .DownlableProducts:
            return "DownloadProductVC"
        case .BackInStock:
            return "BackInStockVC"
        case .RewardPoints:
            return "RewardPointVC"
        }
    }
}


class MoreVC: ParentViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.hideShowHomeTabbar(isHidden: false)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "orderSegue" {
            let destVC = segue.destination as! OrderVC
            destVC.isFromTab = true
        }
        
    }
    
    func navigateTo(storyBoardId: String) {
        let storyBoard = UIStoryboard(name: "Other", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: storyBoardId)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension MoreVC : UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ProfileList.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: MoreCollectionCell
        cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collCell", for: indexPath) as! MoreCollectionCell
        cell.imgView.image = ProfileList.allCases[indexPath.row].img
        cell.lblMoreName.text = ProfileList.allCases[indexPath.row].rawValue
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedItem = ProfileList.allCases[indexPath.row]
        if selectedItem == .Orders {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "orderSegue", sender: nil)
            }
        } else {
            self.navigateTo(storyBoardId: selectedItem.storyBoardId)
        }
    }
}

extension MoreVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collWidth = collectionView.frame.width - 10
        return CGSize(width: collWidth / 3, height: 95.widthRatio)
    }
}
