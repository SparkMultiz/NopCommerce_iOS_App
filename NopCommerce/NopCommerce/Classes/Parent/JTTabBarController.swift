//
//  JTTabBarController.swift
//  NopCommerce
//
//  Created by Chirag Patel on 14/03/20.
//  Copyright © 2020 Chirag Patel. All rights reserved.
//

import UIKit

class JTTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
    
    func clearMenuSelection() {
        if let slideMenu = self.parent as? SlideMenuContainerVC {
            slideMenu.clearSelection()
            slideMenu.tableView.reloadData()
        }
    }
    
    func openLoginPage() {
        if let slideMenu = self.parent as? SlideMenuContainerVC {
            slideMenu.panMenuClose()
            slideMenu.prepareForLogin()
        }
    }
    
    func alertForLogin() {
        let alertController = UIAlertController(title: "Login", message: "Do you want to Login", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            self.openLoginPage()
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        clearMenuSelection()
        if selectedIndex == 0 {
            if viewController.children.first is ProductVC {
                let homeVC =  UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
                let nav : UINavigationController = self.viewControllers?.first as! UINavigationController
                nav.viewControllers = [homeVC]
            }
        } else if selectedIndex == 4 {
            if _user.isGuestLogin {
                selectedIndex = 0
                self.alertForLogin()
            } else {
                if viewController.children.first is ContactUsVC || viewController.children.first is AboutUsVC || viewController.children.first is BlogVC || viewController.children.first is NewsVC {
                    let moreVC = UIStoryboard(name: "Other", bundle: nil).instantiateViewController(withIdentifier: "MoreVC") as! MoreVC
                    let nav : UINavigationController = self.viewControllers?.last as! UINavigationController
                    nav.viewControllers = [moreVC]
                }
            }
        }
    }
}
