//
//  SlideMenuContainerVC.swift
//  ELeague
//
//  Created by Yudiz Solutions Pvt.Ltd. on 10/06/16.
//  Copyright © 2016 Yudiz Pvt.Ltd. All rights reserved.
//

import UIKit

//MARK: Point
/**
 *This class use for get center point of menu ,screen
 */
class Point {
    static var centerPoint = CGPoint()
}
//MARK: SlideAction
/**
 * Slide Menu Action Open & close
 */
public enum SlideAction {
    case open
    case close
}

//MARK: SlideAnimationStyle
/**
 *This class use Slide open animation style
 */
public enum SlideAnimationStyle {
    case style1
    case style2
}

public struct SlideMenuOptions {
    public static var animationStyle: SlideAnimationStyle = .style1
    
    public static var screenFrame     = UIScreen.main.bounds
    public static var panVelocity : CGFloat = 800
    public static var panAnimationDuration : TimeInterval = 0.35
    
    public static var pending = UIDevice.current.userInterfaceIdiom == .pad ? _screenSize.width/2.5 : 75 * _widthRatio
    public static var thresholdTrailSpace : CGFloat =  UIScreen.main.bounds.width + pending
    public static var thresholdLedSpace : CGFloat =  UIScreen.main.bounds.width - pending
    public static var panGesturesEnabled: Bool = true
    public static var tapGesturesEnabled: Bool = true
}

var arrCategories: [MainCategory]!


//MARK: - SliderContainer VC
class SlideMenuContainerVC: ParentViewController {
    // MARK: - Outlets
    
    @IBOutlet weak var menuContainer: UIView!
    @IBOutlet weak var mainContainer: UIView!
    
    @IBOutlet weak var topConst: NSLayoutConstraint!
    @IBOutlet weak var mainContainerTrailSpace: NSLayoutConstraint!
    @IBOutlet weak var mainContainerLedSpace: NSLayoutConstraint!
    
    @IBOutlet weak var menuContainerTrailSpace: NSLayoutConstraint!
    @IBOutlet weak var menuContainerLedSpace: NSLayoutConstraint!
    
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var guestView: UIView!
    @IBOutlet var imgProfileView: UIImageView!
    @IBOutlet var lblUserName: UILabel!
    
    // MARK: Variables
    var transparentView = UIControl()
    var tabbar : UITabBarController!
    var menuActionType: SlideAction = .close
    var imgUrl: URL?
    
    var tabBarVC: JTTabBarController? {
        return tabbar as? JTTabBarController
    }
    
    // MARK: - iOS Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getSlideMenuData()
        prepareConstraintUpdate()
        prepareTableViewUI()
        prepareSlideMenuUI()
        prepareMenuHeader()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        prepareTabBar()
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "loginSegue" {
            let destVC = segue.destination as! LoginVC
            destVC.isFromSlideMenu = true
        }
    }
}

//MARK:- Private
extension  SlideMenuContainerVC{
    
    @objc func panDidFire(panner: UIPanGestureRecognizer) {
        let translation = panner.translation(in: self.view)
        if let view = panner.view {
            view.center = CGPoint(x:view.center.x + translation.x,
                                  y:view.center.y + translation.y)
        }
        panner.setTranslation(CGPoint.zero, in: self.view)
    }
    
    func prepareConstraintUpdate(){
        if SlideMenuOptions.animationStyle == .style1 {
            menuContainerTrailSpace.constant =  SlideMenuOptions.screenFrame.width
            menuContainerLedSpace.constant =  -SlideMenuOptions.thresholdLedSpace
            self.view.bringSubviewToFront(menuContainer)
            
        }else{
            menuContainerTrailSpace.constant = SlideMenuOptions.pending
            menuContainerLedSpace.constant = 0
            self.view.bringSubviewToFront(mainContainer)
            mainContainer.layer.shadowColor = UIColor.black.cgColor
            mainContainer.layer.shadowOpacity = 0.6
            mainContainer.layer.shadowOffset = CGSize(width: 0, height: 2)
        }
    }
    
    func prepareTableViewUI() {
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.tableFooterView = UIView()
        topConst.constant = _statusBarHeight
    }
    
    func prepareTabBar() {
        if (tabbar == nil) {
            for childVC in self.children {
                if let tabVC = childVC as? JTTabBarController {
                    tabbar = tabVC
                }
            }
        }
    }
    
    func openAlertForCamera() {
        let actionControl = UIAlertController(title: "Select Option", message: nil, preferredStyle: .actionSheet)
        actionControl.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action) in
            self.openGalleryCamera(with: .camera)
        }))
        actionControl.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action) in
            self.openGalleryCamera(with: .photoLibrary)
        }))
        actionControl.addAction(UIAlertAction(title: getLocalizedKey(str: "common.cancel"), style: .cancel, handler: nil))
        self.present(actionControl, animated: true, completion: nil)
    }
    
    func openGalleryCamera(with sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        picker.allowsEditing = true
        self.present(picker, animated: true, completion: nil)
    }
    
    func prepareMenuHeader() {
        guestView.isHidden = !_user.isGuestLogin
        if !_user.isGuestLogin {
            imgProfileView.kf.indicatorType = .activity
            imgProfileView.kf.setImage(with: _user.imgUrl, placeholder: _placeImageUser)
            lblUserName.text = _user.fullName
        } else {
            btnLogin.setTitle(getLocalizedKey(str: "account.login"), for: .normal)
        }
    }
    
    func clearSelection() {
        guard arrCategories != nil else {return}
        arrCategories.forEach{$0.isViewEnable = false}
        arrCategories.forEach{$0.subCategories.forEach{$0.isViewEnable = false}}
    }
    
    func setSectionSelectedIdx(ind: Int) {
        clearSelection()
        arrCategories[ind].isViewEnable = true
        self.tableView.reloadData()
    }
    
    func setRowSelectedIdx(ind: Int, section: Int) {
        clearSelection()
        arrCategories[section].subCategories[ind].isViewEnable = true
        self.tableView.reloadData()
    }
    
    func setSelectedInnerIdx(ind: Int, section: Int, innerIdx: Int) {
        clearSelection()
        arrCategories[section].subCategories[ind].innerSubCat[innerIdx].isViewEnable = true
        self.tableView.reloadData()
    }
    
    func prepareProduct(with id: String, name: String, objCat: MainCategory) {
        self.animatedDrawerEffect()
        tabbar.selectedIndex = 0
        let productVC = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "ProductVC") as! ProductVC
        productVC.isFromSlideMenu = true
        productVC.objCategoryId = id
        productVC.catName = name
        productVC.objCategory = objCat
        let nav : UINavigationController = self.tabbar.viewControllers?.first as! UINavigationController
        nav.viewControllers = [productVC]
    }
    
    func prepareNews() {
        self.animatedDrawerEffect()
        tabbar.selectedIndex = 4
        let newsVC = UIStoryboard(name: "Other", bundle: nil).instantiateViewController(withIdentifier: "NewsVC") as! NewsVC
        let nav : UINavigationController = self.tabbar.viewControllers?.last as! UINavigationController
        nav.viewControllers = [newsVC]
    }
    
    func prepareBlogs() {
        self.animatedDrawerEffect()
        tabbar.selectedIndex = 4
        let blogVC = UIStoryboard(name: "Other", bundle: nil).instantiateViewController(withIdentifier: "BlogVC") as! BlogVC
        let nav : UINavigationController = self.tabbar.viewControllers?.last as! UINavigationController
        nav.viewControllers = [blogVC]
    }
    
    func prepareContact() {
        self.animatedDrawerEffect()
        tabbar.selectedIndex = 4
        let contactVC = UIStoryboard(name: "Other", bundle: nil).instantiateViewController(withIdentifier: "ContactUsVC") as! ContactUsVC
        contactVC.isFromSlideMenu = true
        let nav : UINavigationController = self.tabbar.viewControllers?.last as! UINavigationController
        nav.viewControllers = [contactVC]
    }
    
    func prepareAboutPrivacy(isPrivacy: Bool = false) {
        self.animatedDrawerEffect()
        tabbar.selectedIndex = 4
        let aboutVC = UIStoryboard(name: "Other", bundle: nil).instantiateViewController(withIdentifier: "AboutUsVC") as! AboutUsVC
        aboutVC.isPrivacyPolicy = isPrivacy
        let nav : UINavigationController = self.tabbar.viewControllers?.last as! UINavigationController
        nav.viewControllers = [aboutVC]
    }
    
    func prepareChangeLanguage() {
        self.animatedDrawerEffect()
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "languageSegue", sender: nil)
        }
    }
    
    func prepareForLogin() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "loginSegue", sender: nil)
        }
    }
    
    func openCurrencyPicker() {
        let alertController = UIAlertController(title: "Select Currency", message: nil, preferredStyle: .actionSheet)
        for lang in arrCurrency {
            alertController.addAction(UIAlertAction(title: lang.title, style: .default, handler: { (action) in
                self.animatedDrawerEffect()
                self.setCurrency(currId: lang.id)
            }))
        }
        alertController.addAction(UIAlertAction(title: getLocalizedKey(str: "common.cancel"), style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    func prepareForLogout() {
        let alertController = UIAlertController(title: getLocalizedKey(str: "account.logout"), message: nil, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: getLocalizedKey(str: "common.ok"), style: .default, handler: { (action) in
            _appDelegator.removeUserAndNavToLogin()
        }))
        alertController.addAction(UIAlertAction(title: getLocalizedKey(str: "common.cancel"), style: .destructive, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let choosedImage = info[.editedImage] as? UIImage {
            self.uploadUserImage(image: choosedImage)
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

//MARK:- UIACTION
extension SlideMenuContainerVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBAction func btnMainCategoryTapped(_ sender: UIButton) {
        let section = sender.tag
        let isSectionSelected = arrCategories[section].isSectionSelected
        arrCategories[section].isSectionSelected = !isSectionSelected
        self.tableView.reloadSections(IndexSet(integer: section), with: .fade)
    }
    
    @IBAction func btnSubCategoryTapped(_ sender: UIButton) {
        guard let indexPath = IndexPath.indexPathForCellContainingView(view: sender, inTableView: tableView) else {return}
        let isRowSelected = arrCategories[indexPath.section].subCategories[indexPath.row].isRowSelected
        arrCategories[indexPath.section].subCategories[indexPath.row].isRowSelected = !isRowSelected
        self.tableView.reloadRows(at: [IndexPath(row: indexPath.row, section: indexPath.section)], with: .fade)
    }
    
    @IBAction func btnMainCategoryItemTapped(_ sender: UIButton) {
        let objCategory = arrCategories[sender.tag]
        self.setSectionSelectedIdx(ind: sender.tag)
//        if objCategory.id == "999" {
//            self.prepareNews()
//        } else if objCategory.id == "1000" {
//            self.prepareBlogs()
//        } else
        if objCategory.id == "1001" {
            self.prepareAboutPrivacy()
        } else if objCategory.id == "1002" {
            self.prepareAboutPrivacy(isPrivacy: true)
        } else if objCategory.id == "1003" {
            self.prepareContact()
        } else if objCategory.id == "1004" {
            self.prepareChangeLanguage()
        } else if objCategory.id == "1005" {
            self.openCurrencyPicker()
        } else if objCategory.id == "1006" {
            self.prepareForLogout()
        } else {
            self.prepareProduct(with: objCategory.id, name: objCategory.name, objCat: objCategory)
        }
    }
    
    @IBAction func btnChooseProfileTapped(_ sender: UIButton) {
        openAlertForCamera()
    }
    
    @IBAction func btnLoginTapped(_ sender: UIButton) {
        panMenuClose()
        self.prepareForLogin()
    }
    
    @IBAction func btnOpenProfileTapped(_ sender: UIButton) {
        panMenuClose()
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "profileSegue", sender: nil)
        }
    }
}

//MARK:- UITableView DataSource & Delegate

extension  SlideMenuContainerVC {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrCategories == nil ? 0 : arrCategories.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrCategories[section].isSectionSelected ? arrCategories[section].subCategories.count : 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let category = arrCategories[indexPath.section]
        return category.subCategories.isEmpty || !category.isSectionSelected ? 0 : category.subCategories[indexPath.row].innerSubCat.isEmpty || !category.subCategories[indexPath.row].isRowSelected ? 45.widthRatio : CGFloat(category.subCategories[indexPath.row].innerSubCat.count + 1) * (45.widthRatio)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return arrCategories.isEmpty ? 0 : 45.widthRatio
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard !arrCategories.isEmpty else {return nil}
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellHeader") as! MenuItemCell
        cell.lblTitle.text = arrCategories[section].name
        cell.btnExpand.tag = section
        cell.btnSection.tag = section
        cell.selectedView.isHidden = !arrCategories[section].isViewEnable
        cell.btnExpand.isHidden = arrCategories[section].subCategories.isEmpty
        cell.lblDivider.isHidden = section == arrCategories.count - 1
        cell.btnExpand.setImage(arrCategories[section].isSectionSelected ? UIImage(named: "ic_minus") : UIImage(named: "ic_plus") , for: .normal)
        cell.contentView.backgroundColor = arrCategories[section].isViewEnable ? #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) : #colorLiteral(red: 0.1215686275, green: 0.1294117647, blue: 0.1411764706, alpha: 1)
        return cell.contentView
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MenuItemCell
        cell.parent = self
        cell.tag = indexPath.section
        cell.selectedSubIndex = indexPath.row
        cell.subCategory = arrCategories[indexPath.section].subCategories[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let innerCell = cell as? MenuItemCell {
            innerCell.prepareUI()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.setRowSelectedIdx(ind: indexPath.row, section: indexPath.section)
            let objCat = arrCategories[indexPath.section].subCategories[indexPath.row]
            self.prepareProduct(with: objCat.id, name: objCat.name, objCat: arrCategories[indexPath.section])
        }
    }
}

//MARK: - API CALL
extension SlideMenuContainerVC {
    
    func getSlideMenuData() {
        KPWebCall.call.getSlideMenuData { [weak self] (json, statusCode) in
            guard let weakself = self else {return}
            arrCategories = []
            if statusCode == 200, let dict = json as? NSDictionary, let status = dict["Status"] as? Bool, status {
                if let slideMenuData = dict["Data"] as? NSDictionary,
                        let arrCat = slideMenuData["Categories"] as? [NSDictionary] {
                    for objCatDict in arrCat {
                        arrCategories.append(MainCategory(dict: objCatDict))
                    }
                }
                weakself.getAppCurrency()
                weakself.addExtraCategories()
            } else {
                weakself.showError(data: json, view: weakself.view)
            }
        }
    }
    
    func getAppCurrency() {
        KPWebCall.call.getAppCurrency(param: ["ApiSecretKey": secretKey, "StoreId": storeId]) { [weak self] (json, statusCode) in
            guard let weakself = self else {return}
            weakself.hideHud()
            if statusCode == 200, let dict = json as? NSDictionary, let status = dict["Status"] as? Bool, status {
                if let langData = dict["Data"] as? NSDictionary, let arrResources = langData["AvailableCurrencies"] as? [NSDictionary] {
                    arrCurrency = []
                    for currency in arrResources {
                        let objCurr = Currency.addUpdateEntity(key: "id", value: currency.getStringValue(key: "Id"))
                        objCurr.initWith(dict: currency)
                        arrCurrency.append(objCurr)
                    }
                    _appDelegator.saveContext()
                }
            }
        }
        self.tableView.reloadData()
    }
    
    func setCurrency(currId: String) {
        showHud()
        KPWebCall.call.setAppCurrency(param: ["ApiSecretKey": secretKey, "StoreId": storeId, "CurrencyId": currId]) { [weak self] (json, statusCode) in
            guard let weakself = self else {return}
            weakself.hideHud()
            if statusCode == 200, let dict = json as? NSDictionary, let status = dict["Status"] as? Bool, status {
                _appDelegator.storeCurrentCurrId(id: currId)
                _appDelegator.navigateUser()
            } else {
                weakself.showError(data: json, view: weakself.view)
            }
        }
    }
    
    func addExtraCategories() {
      // arrCategories.append(MainCategory(id: "999", name: "News"))
      // arrCategories.append(MainCategory(id: "1000", name: "Blogs"))
       arrCategories.append(MainCategory(id: "1001", name: "About Us"))
       arrCategories.append(MainCategory(id: "1002", name: getLocalizedKey(str: "account.fields.acceptprivacypolicy")))
        arrCategories.append(MainCategory(id: "1003", name: getLocalizedKey(str: "pagetitle.contactus")))
        arrCategories.append(MainCategory(id: "1004", name: "Language"))
        arrCategories.append(MainCategory(id: "1005", name: "Currency"))
        if !_user.isGuestLogin {
            arrCategories.append(MainCategory(id: "1006", name: getLocalizedKey(str: "account.logout")))
        }
        self.tableView.reloadData()
    }
    
    func uploadUserImage(image: UIImage) {
        self.showHud()
        KPWebCall.call.uploadUserImage(img: image) { [weak self] (json, statusCode) in
            guard let weakself = self else {return}
            weakself.hideHud()
            if statusCode == 200, let dict = json as? NSDictionary, let status = dict["Status"] as? Bool, status {
                _user = User.addUpdateEntity(key: "guid", value: _user.guid)
                _user.updateUserProfile(dict: dict)
                _appDelegator.saveContext()
                weakself.prepareMenuHeader()
                weakself.showSuccessMsg(data: dict, view: weakself.view)
            } else {
                weakself.showError(data: json, view: weakself.view)
            }
        }
    }
}


//MARK: - UIGesture
extension SlideMenuContainerVC {
    func animatedDrawerEffect() {
        if let container = self.findContainerController(){
            if menuActionType == .close
            {
                container.panMenuOpen()
            }else
            {
                container.panMenuClose()
            }
        }
    }
    
    func menuContainerClose(_ animatedView: UIView) {
        if let container = self.findContainerController(){
            menuActionType = .close
            if SlideMenuOptions.animationStyle == .style1{
                container.menuContainerTrailSpace.constant = SlideMenuOptions.screenFrame.width
                container.menuContainerLedSpace.constant   = -SlideMenuOptions.thresholdLedSpace
            }else{
                container.mainContainerTrailSpace.constant = 0
                container.mainContainerLedSpace.constant = 0
            }
            
            UIView.animate(withDuration: SlideMenuOptions.panAnimationDuration, animations: { () -> Void in
                container.tableView.isUserInteractionEnabled = false
                self.transparentView.isEnabled = false
                self.transparentView.alpha = 0
                container.view.layoutIfNeeded()
                
            }, completion: { (finished) -> Void in
                self.transparentView.isHidden = true
                self.transparentView.isEnabled = true
                container.tableView.isUserInteractionEnabled = true
            })
            
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOfGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    //MARK: - Swipe Getsure code
    
    @objc func swipePanAction(gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
        if !SlideMenuOptions.panGesturesEnabled{
            return
        }
        
        if let navCon: UINavigationController = self.tabbar!.selectedViewController as? UINavigationController{
            if navCon.viewControllers.count != 1 {
                return
            }
        }
        let centerPoint = Point.centerPoint
        
        
        switch gestureRecognizer.state {
        case .began:
            Point.centerPoint = self.mainContainer.center
            break
            
        case .changed:
            let translation: CGPoint = gestureRecognizer.translation(in: self.view)
            moveContainerOnGesture(x: centerPoint.x, translation: translation)
            break
            
        case .ended,.failed,.cancelled:
            let translation: CGPoint = gestureRecognizer.translation(in: self.view)
            let vel: CGPoint = gestureRecognizer.velocity(in: self.view)
            let halfWidth = SlideMenuOptions.screenFrame.width / 2
            self.view.endEditing(true)
            //  recognizer has received touches recognized as the end of the gesture base on menu close/open
            if vel.x > SlideMenuOptions.panVelocity{
                self.panMenuOpen()
            }else if vel.x < -SlideMenuOptions.panVelocity{
                self.panMenuClose()
            }else if  translation.x > halfWidth{
                self.panMenuOpen()
            }else{
                self.panMenuClose()
            }
            
            break
        default:
            break
        }
    }
    //  MenuContainer/MainContainer Constraint update base on moment action
    
    func moveContainerOnGesture(x:CGFloat,translation: CGPoint){
        let ctPoint = (x + translation.x)
        
        let halfWidth = SlideMenuOptions.screenFrame.width / 2
        if ctPoint >= halfWidth {
            if ctPoint - halfWidth > SlideMenuOptions.thresholdLedSpace {
                //Menu Screen rech maximum to open
                if SlideMenuOptions.animationStyle == .style1{
                    if menuContainerLedSpace.constant != 0
                    {
                        self.menuContainerTrailSpace.constant = SlideMenuOptions.pending
                        self.menuContainerLedSpace.constant = 0
                        transparentViewAnimation(x: translation.x)
                        self.view.layoutIfNeeded()
                    }
                }else{
                    if mainContainerLedSpace.constant != SlideMenuOptions.thresholdLedSpace
                    {
                        mainContainerTrailSpace.constant = -SlideMenuOptions.thresholdLedSpace;
                        mainContainerLedSpace.constant = SlideMenuOptions.thresholdLedSpace;
                        menuSlideAnimation(x: translation.x)
                        transparentViewAnimation(x: translation.x)
                        self.view.layoutIfNeeded()
                    }
                }
                
            }else {
                if SlideMenuOptions.animationStyle == .style1{
                    self.menuContainerLedSpace.constant =   (ctPoint - halfWidth) - SlideMenuOptions.screenFrame.width + SlideMenuOptions.pending
                    self.menuContainerTrailSpace.constant =  SlideMenuOptions.screenFrame.width - (ctPoint - halfWidth)
                    transparentViewAnimation(x: translation.x)
                    
                }else{
                    self.mainContainerTrailSpace.constant = -translation.x
                    self.mainContainerLedSpace.constant = translation.x
                    menuSlideAnimation(x: translation.x)
                    transparentViewAnimation(x: translation.x)
                }
                self.view.layoutIfNeeded()
                
            }
            
        }
    }
    
    //  recognizer has received touches recognized as the end of the gesture base on menu close method
    func panMenuClose() {
        menuActionType = .close
        if SlideMenuOptions.animationStyle == .style1{
            menuContainerTrailSpace.constant = SlideMenuOptions.screenFrame.width
            menuContainerLedSpace.constant   = -SlideMenuOptions.thresholdLedSpace
        }else{
            mainContainerTrailSpace.constant = 0
            mainContainerLedSpace.constant = 0
            menuSlideAnimation(x: SlideMenuOptions.pending,isAnimate: false)
        }
        
        UIView.animate(withDuration: SlideMenuOptions.panAnimationDuration, animations: { () -> Void in
            self.transparentView.isEnabled = false
            self.tableView.isUserInteractionEnabled = false
            
            self.transparentView.alpha = 0
            self.view.layoutIfNeeded()
            
        }, completion: { (finished) -> Void in
            self.transparentView.isHidden = true
            self.transparentView.isEnabled = true
            self.tableView.isUserInteractionEnabled = true
        })
    }
    //  recognizer has received touches recognized as the end of the gesture base on menu open method
    
    func panMenuOpen() {
        menuActionType = .open
        
        if SlideMenuOptions.animationStyle == .style1{
            menuContainerTrailSpace.constant = SlideMenuOptions.pending
            menuContainerLedSpace.constant = 0
            
        }else{
            mainContainerTrailSpace.constant = -SlideMenuOptions.thresholdLedSpace
            mainContainerLedSpace.constant = SlideMenuOptions.thresholdLedSpace
            menuSlideAnimation(x: SlideMenuOptions.screenFrame.width,isAnimate: false)
        }
        self.transparentView.isHidden = false
        
        UIView.animate(withDuration: SlideMenuOptions.panAnimationDuration, animations: { () -> Void in
            self.transparentView.isEnabled = false
            self.tableView.isUserInteractionEnabled = false
            
            self.transparentView.alpha = 1
            self.view.layoutIfNeeded()
            
        }, completion: { (finished) -> Void in
            self.tableView.isUserInteractionEnabled = true
            
            self.transparentView.isEnabled = true
        })
    }
    
    //MARK: -  animation method
    //  Menu slide animation with user touch moment code
    
    func menuSlideAnimation(x: CGFloat,isAnimate:Bool = true){
        let progress: CGFloat = (x)/SlideMenuOptions.thresholdLedSpace
        let slideMovement : CGFloat = 100
        var location :CGFloat = (slideMovement * -1) + (slideMovement * progress)
        location = location > 0 ? 0 : location
        self.menuContainerLedSpace.constant = location
        self.menuContainerTrailSpace.constant =  abs(location) + SlideMenuOptions.pending
        if isAnimate{
            UIView.animate(withDuration: 0.1) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    //  Transparent view alpha animation with user touch moment code
    func transparentViewAnimation(x: CGFloat){
        let progress: CGFloat = (x)/SlideMenuOptions.thresholdLedSpace
        self.transparentView.isHidden = false
        
        UIView.animate(withDuration: 0.1) {
            self.transparentView.alpha = progress
        }
    }
    
}

//MARK: - Slider Menu UI
extension SlideMenuContainerVC {
    
    func prepareSlideMenuUI() {
        // Pan Gesture Recognizer code
        let corner :UIScreenEdgePanGestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(SlideMenuContainerVC.swipePanAction(gestureRecognizer:)))
        corner.edges = UIRectEdge.left
        mainContainer.addGestureRecognizer(corner)
        
        //transparentView Code
        addTransparentControlUI()
    }
    func addTransparentControlUI() {
        transparentView =  UIControl()
        transparentView.alpha = 0
        transparentView.isHidden = true
        transparentView.addTarget(self, action: #selector(ParentViewController.shutterAction(_:)), for: UIControl.Event.touchUpInside)
        
        
        if SlideMenuOptions.animationStyle == .style1{
            transparentView.frame =  CGRect(x: 0, y: 0, width: SlideMenuOptions.screenFrame.width, height: SlideMenuOptions.screenFrame.height)
            transparentView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
            self.view.addSubview(self.transparentView)
            self.view.bringSubviewToFront(menuContainer)
        }else{
            transparentView.frame =  CGRect(x: SlideMenuOptions.thresholdLedSpace, y: 0, width: SlideMenuOptions.pending, height: SlideMenuOptions.screenFrame.height)
            transparentView.backgroundColor =   UIColor.clear
            
            self.view.addSubview(self.transparentView)
        }
    }
}

