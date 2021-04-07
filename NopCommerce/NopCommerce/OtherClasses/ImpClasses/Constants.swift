import UIKit
import Foundation

/*---------------------------------------------------
Screen Size
---------------------------------------------------*/
let _screenSize     = UIScreen.main.bounds.size
let _screenFrame    = UIScreen.main.bounds

/*---------------------------------------------------
 Constants
 ---------------------------------------------------*/
let _defaultCenter  = NotificationCenter.default
let _userDefault    = UserDefaults.standard
let _appDelegator   = UIApplication.shared.delegate! as! AppDelegate
let _application    = UIApplication.shared

/*---------------------------------------------------
 Facebook
 ---------------------------------------------------*/
let _facebookPermission              = ["public_profile", "email", "user_friends"]
let _facebookMeUrl                   = "me"
let _facebookAlbumUrl                = "me/albums"
let _facebookUserField: [String:Any] = ["fields" : "id,first_name,last_name,gender,birthday,email,education,work,picture.height(700)"]
let _facebookJobSchoolField          = ["fields" : "education,work"]
let _facebookAlbumField              = ["fields":"id,name,count,picture"]
let _facebookPhotoField              = ["fields":"id,picture"]

/*---------------------------------------------------
 Privacy and Terms URL
---------------------------------------------------*/
let _aboutUsUrl        = "https://www.google.com"
let _privacyUrl        = "https://www.google.com"
let _helpUrl           = "https://www.google.com"
let _termsUrl          = "https://www.google.com"
let _multipzUrl        = "http://multipz.com/about-us"

/*---------------------------------------------------
 MARK: Paging Structure
 ---------------------------------------------------*/
struct LoadMore{
    var index: Int = 1
    var isLoading: Bool = false
    var limit: Int = 16
    var isAllLoaded = false
    
    var offset: Int{
        return index * limit
    }
}

/*---------------------------------------------------
 Current loggedIn User
 ---------------------------------------------------*/
var _user: User!
var arrLang: [Language]!
var arrCurrency: [Currency]!
let _deviceType = "ios"
var storeId    = "1"
var secretKey   = "v119k108w110v104d106g120g110z111"
var customerGUID = "00000000-0000-0000-0000-000000000000"
var languageId = "1"
var currencyId = "1"
let _deviceId = UIDevice.current.identifierForVendor!.uuidString

/*---------------------------------------------------
 Date Formatter and number formatter
 ---------------------------------------------------*/
let _serverFormatter: DateFormatter = {
    let df = DateFormatter()
    df.timeZone = TimeZone(abbreviation: "UTC")
    df.dateFormat = "yyyy-MM-dd HH:mm:ss"
    df.locale = Locale(identifier: "en_US_POSIX")
    return df
}()

let _deviceFormatter: DateFormatter = {
    let df = DateFormatter()
    df.timeZone = TimeZone.current
    df.dateFormat = "yyyy-MM-dd"
    return df
}()

let _numberFormatter:NumberFormatter = {
    let format = NumberFormatter()
    format.locale = Locale(identifier: "en_US")
    format.numberStyle = .decimal
    format.allowsFloats = true
    format.minimumFractionDigits = 3
    format.maximumFractionDigits = 3
    return format
}()

/*---------------------------------------------------
 Place Holder image
 ---------------------------------------------------*/
let _placeImage = UIImage(named: "ic_placeholder")
let _placeImageUser = UIImage(named: "ic_profilePic")

let kActivityButtonImageName = ""
let kActivitySmallImageName = ""

/*---------------------------------------------------
 User Default and Notification keys
 ---------------------------------------------------*/
let NopCurrlanguage         = "NopCurrlanguage"
let NopCurrCurrency         = "NopCurrCurrency"


/*---------------------------------------------------
 Custom print
 ---------------------------------------------------*/
func kprint(items: Any...) {
    #if DEBUG
        for item in items {
            print(item)
        }
    #endif
}

/*---------------------------------------------------
 Settings Version Maintenance
 ---------------------------------------------------*/
func getAppVersionAndBuild() -> String{
    if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String,
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String{
        return "Version - \(version)(\(build))"
    }else{
        return ""
    }
}

func getAppversion() -> String{
    if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String{
        return version
    }else{
        return ""
    }
}

func setAppSettingsBundleInformation(){
    if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String,
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String{
        _userDefault.set(build, forKey: "application_build")
        _userDefault.set(version, forKey: "application_version")
        _userDefault.synchronize()
    }
}

/*---------------------------------------------------
 Device Extention
 ---------------------------------------------------*/
extension UIDevice {
    var iPhoneX: Bool {
        return UIScreen.main.nativeBounds.height == 2436
    }
    class func isiPhone4() -> Bool {
        return _screenSize.height == 480.0 && UIDevice.current.userInterfaceIdiom == .phone
    }
}

//MARK:- Constant
//-------------------------------------------------------------------------------------------
// Common
//-------------------------------------------------------------------------------------------
let _statusBarHeight           : CGFloat = _appDelegator.window!.rootViewController!.topLayoutGuide.length
let _navigationHeight          : CGFloat = _statusBarHeight + 44
let _btmNavigationHeight       : CGFloat = _bottomAreaSpacing + 64
let _btmNavigationHeightSearch : CGFloat = _bottomAreaSpacing + 64 + 45
let _bottomAreaSpacing         : CGFloat = _appDelegator.window!.rootViewController!.bottomLayoutGuide.length
let _vcTransitionTime                    = 0.3
let _tabBarHeight              : CGFloat = 49
let _imageFadeTransitionTime   : Double  = 0.3

