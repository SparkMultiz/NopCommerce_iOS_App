//
//  AppDelegate.swift
//  NopCommerce
//
//  Created by Chirag Patel on 06/03/20.
//  Copyright © 2020 Chirag Patel. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var isArabic: Bool = false

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        setViewApperance()
        if _userDefault.isOnBoardingOver() {
            self.navigateUser()
        }
        setUpPaypal()
        // Check for internet
        if !KPWebCall.call.isInternetAvailable(){
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
                KPWebCall.call.networkManager.listener?(NetworkReachabilityManager.NetworkReachabilityStatus.notReachable)
            })
        }
        return true
    }
    
    func setUpPaypal() {
        let strSandBox = "AT3CEOyiZMOZfZAsyaYSnEOj4qSJfn_m7B9hbduVTlHnwKqOEJMz4qbmnU4oVP_Hop-EyMeEJysfyN06"
        PayPalMobile.initializeWithClientIds(forEnvironments: [PayPalEnvironmentProduction: "",
                                                               PayPalEnvironmentSandbox: strSandBox])
    }
        
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "NopCommerce")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    var managedObjectContext: NSManagedObjectContext{
        return persistentContainer.viewContext
    }
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

extension AppDelegate {
    
    // Check user is already logged in or not.
    func checkForUser() -> Bool {
        let users = User.fetchDataFromEntity(predicate: nil, sortDescs: nil)
        if !users.isEmpty {
            _user = users.first!
            return true
        } else {
            return false
        }
    }
    
    func navigateUser() {
        let nav = window?.rootViewController as! KPNavigationViewController
        let loginVC = UIStoryboard.init(name: "Entry", bundle: nil).instantiateViewController(withIdentifier: "LoginVC")
        let slideMenu = UIStoryboard.init(name: "Entry", bundle: nil).instantiateViewController(withIdentifier: "SlideMenuContainerVC")
        if checkForUser() {
            nav.viewControllers = [loginVC, slideMenu]
        } else {
            nav.viewControllers = [loginVC]
        }
        _appDelegator.window?.rootViewController = nav
    }
    
    func deleteUserObject() {
        _user = nil
        let users = User.fetchDataFromEntity(predicate: nil, sortDescs: nil)
        for user in users{
            managedObjectContext.delete(user)
        }
        saveContext()
    }
    
    func removeAllNotification() {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
    
    func unregisterForNormalNotifications() {
        UIApplication.shared.unregisterForRemoteNotifications()
    }
    
    func removeUserAndNavToLogin() {
        deleteUserObject()
        unregisterForNormalNotifications()
        removeAllNotification()
        if let nav = window?.rootViewController as? UINavigationController{
            _ = nav.popToRootViewController(animated: true)
        }
    }
}

extension AppDelegate {
    
    func storeCurrentLangId(id: String) {
        _userDefault.set(id, forKey: NopCurrlanguage)
        _userDefault.synchronize()
    }
    
    func getCurrLangId() -> String? {
        return _userDefault.value(forKey: NopCurrlanguage) as? String
    }
    
    func storeCurrentCurrId(id: String) {
        _userDefault.set(id, forKey: NopCurrCurrency)
        _userDefault.synchronize()
    }
    
    func getCurrCurrencyId() -> String? {
        return _userDefault.value(forKey: NopCurrCurrency) as? String
    }
    
    func setViewApperance() {
        arrLang = Language.fetchDataFromEntity(predicate: nil, sortDescs: nil)
        guard let langId = _appDelegator.getCurrLangId() else {return}
        isArabic = langId.isEqual(str: "2")
        if isArabic {
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
        } else {
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
        }
    }
}

// or^4oIhM
