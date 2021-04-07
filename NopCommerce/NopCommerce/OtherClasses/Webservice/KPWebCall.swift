//  Created by iOS Development Company on 12/12/16.
//  Copyright © 2016 iOS Development Company. All rights reserved.
//

import Foundation

// MARK: Web Operation
class AccessTokenAdapter: RequestAdapter {
    private let accessToken: String
    
    init(accessToken: String) {
        self.accessToken = accessToken
    }
    
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var urlRequest = urlRequest
        urlRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        return urlRequest
    }
}
//http://xitstaging-001-site8.mysitepanel.net/Api/Client/
//http://mobileapi.rebuildsucceeded.com/api/client/
#if DEBUG
let _baseUrl = "http://mobileapi.rebuildsucceeded.com/api/client/" // Dev URL
#else
let _baseUrl = "http://mobileapi.rebuildsucceeded.com/api/client/" // Live Url
#endif


typealias WSBlock = (_ json: Any?, _ flag: Int) -> ()
typealias WSProgress = (Progress) -> ()?
typealias WSFileBlock = (_ path: String?, _ error: Error?) -> ()

class KPWebCall:NSObject{
    
    static var call: KPWebCall = KPWebCall()
    
    let manager: SessionManager
    var networkManager: NetworkReachabilityManager = NetworkReachabilityManager()!
    var headers: HTTPHeaders = [
        "Content-Type": "application/json",
    ]
    var toast: ValidationToast!
    var paramEncode: ParameterEncoding = JSONEncoding.default
    let timeOutInteraval: TimeInterval = 60
    var successBlock: (String, HTTPURLResponse?, AnyObject?, WSBlock) -> Void
    var errorBlock: (String, HTTPURLResponse?, NSError, WSBlock) -> Void
    
    override init() {
        manager = Alamofire.SessionManager.default
        
        // Will be called on success of web service calls.
        successBlock = { (relativePath, res, respObj, block) -> Void in
            // Check for response it should be there as it had come in success block
            if let response = res{
                kprint(items: "Response Code: \(response.statusCode)")
                kprint(items: "Response(\(relativePath)): \(String(describing: respObj))")
                
                if response.statusCode == 200 {
                    block(respObj, response.statusCode)
                } else {
                    if response.statusCode == 401{
                        block([_appName: kInternetDown] as AnyObject, response.statusCode)
                    }else {
                        block(respObj, response.statusCode)
                    }
                }
            } else {
                // There might me no case this can get execute
                block(nil, 404)
            }
        }
        
        // Will be called on Error during web service call
        errorBlock = { (relativePath, res, error, block) -> Void in
            // First check for the response if found check code and make decision
            if let response = res {
                kprint(items: "Response Code: \(response.statusCode)")
                kprint(items: "Error Code: \(error.code)")
                if let data = error.userInfo["com.alamofire.serialization.response.error.data"] as? NSData {
                    let errorDict = (try? JSONSerialization.jsonObject(with: data as Data, options: JSONSerialization.ReadingOptions.mutableContainers)) as? NSDictionary
                    if errorDict != nil {
                        kprint(items: "Error(\(relativePath)): \(errorDict!)")
                        block(errorDict!, response.statusCode)
                    } else {
                        let code = response.statusCode
                        block(nil, code)
                    }
                } else if response.statusCode == 401{
                    block([_appName: kInternetDown] as AnyObject, response.statusCode)
                }else {
                    block(nil, response.statusCode)
                }
                // If response not found rely on error code to find the issue
            } else if error.code == -1009  {
                kprint(items: "Error(\(relativePath)): \(error)")
                block([_appName: kInternetDown] as AnyObject, error.code)
                return
            } else if error.code == -1003  {
                kprint(items: "Error(\(relativePath)): \(error)")
                block([_appName: kHostDown] as AnyObject, error.code)
                return
            } else if error.code == -1001  {
                kprint(items: "Error(\(relativePath)): \(error)")
                block([_appName: kTimeOut] as AnyObject, error.code)
                return
            } else if error.code == 1004  {
                kprint(items: "Error(\(relativePath)): \(error)")
                block([_appName: kInternetDown] as AnyObject, error.code)
                return
            } else {
                kprint(items: "Error(\(relativePath)): \(error)")
                block(nil, error.code)
            }
        }
        super.init()
        addInterNetListner()
    }
    
    deinit {
        networkManager.stopListening()
    }
}

// MARK: Other methods
extension KPWebCall{
    func getFullUrl(relPath : String) throws -> URL{
        do{
            if relPath.lowercased().contains("http") || relPath.lowercased().contains("www"){
                return try relPath.asURL()
            }else{
                return try (_baseUrl+relPath).asURL()
            }
        }catch let err{
            throw err
        }
    }
    
    func setAccesTokenToHeader(token:String){
        manager.adapter = AccessTokenAdapter(accessToken: token)
    }
    
    func removeAccessTokenFromHeader(){
        manager.adapter = nil
    }
}

// MARK: - Request, ImageUpload and Dowanload methods
extension KPWebCall{
    
    func getRequest(relPath: String, param: [String: Any]?, headerParam: HTTPHeaders?, timeout: TimeInterval? = nil, block: @escaping WSBlock)-> DataRequest? {
        do{
            kprint(items: "Url: \(try getFullUrl(relPath: relPath))")
            kprint(items: "Param: \(String(describing: param))")
            var req = try URLRequest(url: getFullUrl(relPath: relPath), method: HTTPMethod.get, headers: (headerParam ?? headers))
            req.timeoutInterval = timeout ?? timeOutInteraval
            let encodedURLRequest = try paramEncode.encode(req, with: param)
            return Alamofire.request(encodedURLRequest).responseJSON { (resObj) in
                switch resObj.result{
                case .success:
                    if let resData = resObj.data{
                        do {
                            let res = try JSONSerialization.jsonObject(with: resData, options: []) as AnyObject
                            self.successBlock(relPath, resObj.response, res, block)
                        } catch let errParse{
                            kprint(items: errParse)
                            self.errorBlock(relPath, resObj.response, errParse as NSError, block)
                        }
                    }
                    break
                case .failure(let err):
                    kprint(items: err)
                    self.errorBlock(relPath, resObj.response, err as NSError, block)
                    break
                }
            }
        }catch let error{
            kprint(items: error)
            errorBlock(relPath, nil, error as NSError, block)
            return nil
        }
    }
    
    func postRequest(relPath: String, param: [String: Any]?, headerParam: HTTPHeaders?, timeout: TimeInterval? = nil, block: @escaping WSBlock)-> DataRequest?{
        do{
            kprint(items: "Url: \(try getFullUrl(relPath: relPath))")
            kprint(items: "Param: \(String(describing: param))")
            var req = try URLRequest(url: getFullUrl(relPath: relPath), method: HTTPMethod.post, headers: (headerParam ?? headers))
            req.timeoutInterval = timeout ?? timeOutInteraval
            let encodedURLRequest = try paramEncode.encode(req, with: param)
            
            return Alamofire.request(encodedURLRequest).responseJSON { (resObj) in
                switch resObj.result{
                case .success:
                    if let resData = resObj.data{
                        do {
                            let res = try JSONSerialization.jsonObject(with: resData, options: []) as AnyObject
                            self.successBlock(relPath, resObj.response, res, block)
                        } catch let errParse{
                            kprint(items: errParse)
                            self.errorBlock(relPath, resObj.response, errParse as NSError, block)
                        }
                    }
                    break
                case .failure(let err):
                    kprint(items: err)
                    self.errorBlock(relPath, resObj.response, err as NSError, block)
                    break
                }
            }
        }catch let error{
            kprint(items: error)
            errorBlock(relPath, nil, error as NSError, block)
            return nil
        }
    }
    
    func uploadImage(relPath: String,img: UIImage?, param: [String: Any]?, withName : String = "FileData" ,comress: CGFloat,headerParam: HTTPHeaders?, block: @escaping WSBlock, progress: WSProgress?){
        do{
            kprint(items: "Url: \(try getFullUrl(relPath: relPath))")
            kprint(items: "Param: \(String(describing: param))")
            manager.upload(multipartFormData: { (formData) in
                if let image = img {
                    formData.append(image.jpegData(compressionQuality: comress)!, withName: withName, fileName: "image.jpeg", mimeType: "image/jpeg")
                }
                if let _ = param{
                    for (key, value) in param!{
                        formData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue, allowLossyConversion: false)!, withName: key)
                    }
                }
            }, to: try getFullUrl(relPath: relPath), method: HTTPMethod.post, headers: (headerParam ?? headers), encodingCompletion: { encoding in
                switch encoding{
                case .success(let req, _, _):
                    req.uploadProgress(closure: { (prog) in
                        progress?(prog)
                    }).responseJSON { (resObj) in
                        switch resObj.result{
                        case .success:
                            if let resData = resObj.data{
                                do {
                                    let res = try JSONSerialization.jsonObject(with: resData, options: []) as AnyObject
                                    self.successBlock(relPath, resObj.response, res, block)
                                } catch let errParse{
                                    kprint( items: errParse)
                                    self.errorBlock(relPath, resObj.response, errParse as NSError, block)
                                }
                            }
                            break
                        case .failure(let err):
                            kprint( items: err)
                            self.errorBlock(relPath, resObj.response, err as NSError, block)
                            break
                        }
                    }
                    break
                case .failure(let err):
                    kprint( items: err)
                    self.errorBlock(relPath, nil, err as NSError, block)
                    break
                }
            })
        }catch let err{
            self.errorBlock(relPath, nil, err as NSError, block)
        }
    }
    
    
    func uploadVideo(relPath: String, vidFileUrl: URL, param: [String: Any]?, name : String ,headerParam: HTTPHeaders?, block: @escaping WSBlock, progress: WSProgress?){
        do{
            kprint(items: "Url: \(try getFullUrl(relPath: relPath))")
            kprint(items: "Param: \(String(describing: param))")
            manager.upload(multipartFormData: { (formData) in
                formData.append(vidFileUrl, withName: name, fileName: "video.mp4", mimeType: "video/mp4")
                if let _ = param{
                    for (key, value) in param!{
                        formData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue, allowLossyConversion: false)!, withName: key)
                    }
                }
            }, to: try getFullUrl(relPath: relPath), method: HTTPMethod.post, headers: (headerParam ?? headers), encodingCompletion: { encoding in
                switch encoding{
                case .success(let req, _, _):
                    req.uploadProgress(closure: { (prog) in
                        progress?(prog)
                    }).responseJSON { (resObj) in
                        switch resObj.result{
                        case .success:
                            if let resData = resObj.data{
                                do {
                                    let res = try JSONSerialization.jsonObject(with: resData, options: []) as AnyObject
                                    self.successBlock(relPath, resObj.response, res, block)
                                } catch let errParse{
                                    kprint( items: errParse)
                                    self.errorBlock(relPath, resObj.response, errParse as NSError, block)
                                }
                            }
                            break
                        case .failure(let err):
                            kprint( items: err)
                            self.errorBlock(relPath, resObj.response, err as NSError, block)
                            break
                        }
                    }
                    break
                case .failure(let err):
                    kprint( items: err)
                    self.errorBlock(relPath, nil, err as NSError, block)
                    break
                }
            })
        }catch let err{
            self.errorBlock(relPath, nil, err as NSError, block)
        }
    }
    
    func uploadAudio(relPath: String, audioFileUrl: URL, param: [String: Any]?, name : String ,headerParam: HTTPHeaders?, block: @escaping WSBlock, progress: WSProgress?){
        do{
            kprint(items: "Url: \(try getFullUrl(relPath: relPath))")
            kprint(items: "Param: \(String(describing: param))")
            manager.upload(multipartFormData: { (formData) in
                formData.append(audioFileUrl, withName: name, fileName: "audio.m4a", mimeType: "audio/m4a")
                if let _ = param{
                    for (key, value) in param!{
                        formData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue, allowLossyConversion: false)!, withName: key)
                    }
                }
            }, to: try getFullUrl(relPath: relPath), method: HTTPMethod.post, headers: (headerParam ?? headers), encodingCompletion: { encoding in
                switch encoding{
                case .success(let req, _, _):
                    req.uploadProgress(closure: { (prog) in
                        progress?(prog)
                    }).responseJSON { (resObj) in
                        switch resObj.result{
                        case .success:
                            if let resData = resObj.data{
                                do {
                                    let res = try JSONSerialization.jsonObject(with: resData, options: []) as AnyObject
                                    self.successBlock(relPath, resObj.response, res, block)
                                } catch let errParse{
                                    kprint( items: errParse)
                                    self.errorBlock(relPath, resObj.response, errParse as NSError, block)
                                }
                            }
                            break
                        case .failure(let err):
                            kprint( items: err)
                            self.errorBlock(relPath, resObj.response, err as NSError, block)
                            break
                        }
                    }
                    break
                case .failure(let err):
                    kprint( items: err)
                    self.errorBlock(relPath, nil, err as NSError, block)
                    break
                }
            })
        }catch let err{
            self.errorBlock(relPath, nil, err as NSError, block)
        }
    }
    
    func uploadUserImages(relPath: String,imgs: [UIImage?],param: [String: Any]?, keyStr : [String], headerParam: HTTPHeaders?, block: @escaping WSBlock, progress: WSProgress?){
        do{
            manager.upload(multipartFormData: { (formData) in
                for (idx,img) in imgs.enumerated(){
                    if let _ = img{
                        formData.append(img!.jpegData(compressionQuality: 1.0)!, withName: keyStr[idx], fileName: "image.jpeg", mimeType: "image/jpeg")
                    }
                }
                if let _ = param{
                    for (key, value) in param!{
                        formData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue, allowLossyConversion: false)!, withName: key)
                    }
                }
            }, to: try getFullUrl(relPath: relPath), method: HTTPMethod.post, headers: (headerParam ?? headers), encodingCompletion: { encoding in
                switch encoding{
                case .success(let req, _, _):
                    req.uploadProgress(closure: { (prog) in
                        progress?(prog)
                    }).responseJSON { (resObj) in
                        switch resObj.result{
                        case .success:
                            if let resData = resObj.data{
                                do {
                                    let res = try JSONSerialization.jsonObject(with: resData, options: []) as AnyObject
                                    self.successBlock(relPath, resObj.response, res, block)
                                } catch let errParse{
                                    kprint(items: errParse)
                                    self.errorBlock(relPath, resObj.response, errParse as NSError, block)
                                }
                            }
                            break
                        case .failure(let err):
                            kprint(items: err)
                            self.errorBlock(relPath, resObj.response, err as NSError, block)
                            break
                        }
                    }
                    break
                case .failure(let err):
                    kprint(items: err)
                    self.errorBlock(relPath, nil, err as NSError, block)
                    break
                }
            })
        }catch let err{
            self.errorBlock(relPath, nil, err as NSError, block)
        }
    }
    
    func dowanloadFile(relPath : String, saveFileUrl: URL, progress: WSProgress?, block: @escaping WSFileBlock){
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            return (saveFileUrl, [.removePreviousFile, .createIntermediateDirectories])
        }
        do{
            manager.download(try getFullUrl(relPath: relPath), to: destination).downloadProgress { (prog) in
                progress?(prog)
            }.response { (responce) in
                if let path = responce.destinationURL?.path{
                    block(path, responce.error)
                }else{
                    block(nil, responce.error)
                }
            }.resume()
        }catch{
            block(nil, nil)
        }
    }
}


// MARK: - Internet Availability
extension KPWebCall{
    func addInterNetListner() {
        networkManager.startListening()
        networkManager.listener = { (status) -> Void in
            if status == NetworkReachabilityManager.NetworkReachabilityStatus.notReachable{
                print("No InterNet")
                if self.toast == nil{
                    self.toast = KPValidationToast.shared.showStatusMessageForInterNet(message: kInternetDown)
                }
            } else {
               print("Internet Avail")
               if self.toast != nil{
                   self.toast.animateOut(duration: 0.2, delay: 0.2, completion: { () -> () in
                       self.toast.removeFromSuperview()
                       self.toast = nil
                   })
               }
            }
        }
    }
    
    func isInternetAvailable() -> Bool {
        if networkManager.isReachable{
            return true
        }else{
            return false
        }
    }
}

//MARK :- Entry
extension KPWebCall {
    
    func getLoginForm(param: [String: Any], block: @escaping WSBlock) {
        kprint(items: "------------ Get Login Form ----------")
        let relPath = "GetLoginForm"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func getSignUpForm(param: [String: Any], block: @escaping WSBlock) {
        kprint(items: "------------ Get SignUp Form ----------")
        let relPath = "GetRegisterForm"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func loginUser(param: [String: Any], block: @escaping WSBlock) {
        kprint(items: "------------ Login User ----------")
        let relPath = "Login"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func loginGuest(block: @escaping WSBlock) {
        kprint(items: "------------ Login Guest ----------")
        let relPath = "GetGuestCustomerGuid"
        _ = postRequest(relPath: relPath, param: ["ApiSecretKey": secretKey], headerParam: nil, block: block)
    }
    
    func changePassword(param: [String: Any], block: @escaping WSBlock) {
        kprint(items: "------------ Change Password ----------")
        let relPath = "ChangePassword"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func recoverPassword(param: [String: Any], block: @escaping WSBlock) {
        kprint(items: "------------ Recover Password ----------")
        let relPath = "PasswordRecovery"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func checkEmailAvail(param: [String: Any], block: @escaping WSBlock) {
        kprint(items: "------------ Email Avail ----------")
        let relPath = "CheckEmailIdAvailability"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func checkUserNameAvail(param: [String: Any], block: @escaping WSBlock) {
        kprint(items: "------------ UserName Avail ----------")
        let relPath = "CheckUsernameAvailability"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func registerUser(param: [String: Any], block: @escaping WSBlock) {
        kprint(items: "------------ Register User ----------")
        let relPath = "Register"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func getUserProfileData(block: @escaping WSBlock) {
        kprint(items: "------------ Get User Profile ----------")
        let relPath = "Info"
        _ = postRequest(relPath: relPath, param: ["ApiSecretKey": secretKey, "CustomerGUID": _user.guid], headerParam: nil, block: block)
    }
    
    func updateUserProfileData(param: [String: Any], block: @escaping WSBlock) {
        kprint(items: "------------ Get User Profile ----------")
        let relPath = "InfoEdit"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func getSlideMenuData(block: @escaping WSBlock) {
        kprint(items: "------------ Get SlideMenu Data ----------")
        let relPath = "TopMenu"
        _ = postRequest(relPath: relPath, param: ["ApiSecretKey": secretKey, "CustomerGUID": _user.guid, "LanguageId": languageId, "StoreId": storeId], headerParam: nil, block: block)
    }
    
    func uploadUserImage(img: UIImage ,block: @escaping WSBlock) {
        kprint(items: "------------ Upload User Image ----------")
        let relPath = "UploadAvatarByBinary"
        uploadImage(relPath: relPath, img: img, param: ["ApiSecretKey": secretKey, "CustomerGUID": _user.guid], comress: 1.0, headerParam: nil, block: block, progress: nil)
    }
    
    func getAppLanguages(param: [String: Any], block: @escaping WSBlock) {
        kprint(items: "------------ Get Languages ----------")
        let relPath = "GetLanguage"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func getAppCurrency(param: [String: Any], block: @escaping WSBlock) {
        kprint(items: "------------ Get Currency ----------")
        let relPath = "GetCurrency"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func setAppCurrency(param: [String: Any], block: @escaping WSBlock) {
        kprint(items: "------------ Set Currency ----------")
        let relPath = "SetCurrency"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func setAppLanguage(param: [String: Any], block: @escaping WSBlock) {
        kprint(items: "------------ Set Languages ----------")
        let relPath = "SetLanguage"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func getLangaugeResourceString(param: [String: Any], block: @escaping WSBlock) {
        kprint(items: "------------ Get Language Resources ----------")
        let relPath = "GetLanguageResourceString"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
}

//MARK :- Home
extension KPWebCall {
    
    func getCategory(param: [String: Any], block: @escaping WSBlock) {
        kprint(items: "------------ Get Categories ----------")
        let relPath = "GetHomePageCategory"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func getHomeWelcomeText(param: [String: Any], block: @escaping WSBlock) {
        kprint(items: "------------ Get Home Welcome Text ----------")
        let relPath = "TopicDetails"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func getNivoSlider(param: [String: Any], block: @escaping WSBlock) {
        kprint(items: "------------ Get Nivo Slider ----------")
        let relPath = "NivoSlider"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func getFeaturedList(param: [String: Any], block: @escaping WSBlock) {
        kprint(items: "------------ Get Featured List ----------")
        let relPath = "HomePageProducts"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func getBestSellerList(param: [String: Any], block: @escaping WSBlock) {
        kprint(items: "------------ Get Best Seller List ----------")
        let relPath = "BestSellers"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func getProductsByCategory(param: [String: Any], block: @escaping WSBlock) {
        kprint(items: "------------ Get Product By Category ----------")
        let relPath = "GetProductByCategory"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func getProductsDetails(param: [String: Any], block: @escaping WSBlock) {
        kprint(items: "------------ Get Product Details ----------")
        let relPath = "ProductDetail"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func addToCartAndWishList(param: [String: Any], block: @escaping WSBlock) {
        kprint(items: "------------ Add To Cart & WishList ----------")
        let relPath = "CatalogAddProductToCart"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func addProductToCartAndWishList(param: [String: Any], block: @escaping WSBlock) {
        kprint(items: "------------ Add To WishList ----------")
        let relPath = "DetailAddProductToCart"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func changeProductAttribute(param: [String: Any], block: @escaping WSBlock) {
        kprint(items: "------------ Change Product Attribute ----------")
        let relPath = "Product_AttributeChange"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func loadFilterData(param: [String: Any], block: @escaping WSBlock) {
        kprint(items: "------------ Load Filter Data ----------")
        let relPath = "LoadFilter2"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func getProductReviews(param: [String: Any], block: @escaping WSBlock) {
        kprint(items: "------------ Get Product Reviews ----------")
        let relPath = "ProductReviews"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func getRelatedProductBought(param: [String: Any], block: @escaping WSBlock) {
        kprint(items: "------------ Get Related Product Bought ----------")
        let relPath = "ProductAlsoPurchased"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func addProductReview(param: [String: Any], block: @escaping WSBlock) {
        kprint(items: "------------ Add Product Review ----------")
        let relPath = "AddProductReview"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func notifyStockProduct(strPath: String,param: [String: Any], block: @escaping WSBlock) {
        kprint(items: "------------ Subcribe/Unsubscripe Product ----------")
        let relPath = "\(strPath)"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
}

//MARK :- Cart
extension KPWebCall {
    
    func getCartItemData(param: [String: Any], block: @escaping WSBlock) {
        kprint(items: "------------ Get Cart Data ----------")
        let relPath = "Cart"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func updateCartData(param: [String: Any], block: @escaping WSBlock) {
          kprint(items: "------------ Update Cart Data ----------")
          let relPath = "UpdateCartWithMultipleItems"
          _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
      }
      
      func moveToWishList(param: [String: Any], block: @escaping WSBlock) {
          kprint(items: "------------ Move Cart To WishList ----------")
          let relPath = "MoveCartItemsToWishList"
          _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
      }
      
      func removeFromCart(param: [String: Any], block: @escaping WSBlock) {
          kprint(items: "------------ Remove From Cart ----------")
          let relPath = "RemoveFromCart"
          _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
      }
    
    func getOrderAmount(param: [String: Any], block: @escaping WSBlock) {
        kprint(items: "------------ Get Order Total ----------")
        let relPath = "OrderTotal"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func getCountryList(param: [String: Any], block: @escaping WSBlock) {
        kprint(items: "------------ Get Country List ----------")
        let relPath = "GetAllCountries"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func getProvinceList(param: [String: Any], block: @escaping WSBlock) {
        kprint(items: "------------ Get Province List ----------")
        let relPath = "GetAllStateByCountryId"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func getEstimateShipping(param: [String: Any], block: @escaping WSBlock) {
        kprint(items: "------------ Get Estimate Shipping ----------")
        let relPath = "EstimateShipping"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func applyCheckOutAttribute(param: [String: Any], block: @escaping WSBlock) {
        kprint(items: "------------ Set CheckOut Attribute ----------")
        let relPath = "SetCheckOutAttribute"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func applyRemoveGiftCard(relPath: String ,param: [String: Any], block: @escaping WSBlock) {
        kprint(items: "------------ Apply Remove Gift Card ----------")
        let relPath = "\(relPath)"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func applyRemoveDiscount(relPath: String ,param: [String: Any], block: @escaping WSBlock) {
        kprint(items: "------------ Apply Remove Discount ----------")
        let relPath = "\(relPath)"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func getBillingAddress(param: [String: Any], block: @escaping WSBlock) {
        kprint(items: "------------ Get Billing Address ----------")
        let relPath = "GetBillingAddress"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func selectAddress(relPath: String, param: [String: Any], block: @escaping WSBlock) {
        kprint(items: "------------ Select Address ----------")
        let relPath = "\(relPath)"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func selectShippingMethod(param: [String: Any], block: @escaping WSBlock) {
        kprint(items: "------------ Select Shipping Method ----------")
        let relPath = "SelectShippingMethod"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func selectPaymentMethod(param: [String: Any], block: @escaping WSBlock) {
        kprint(items: "------------ Select Payment Method ----------")
        let relPath = "SelectPaymentMethod"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func addBillingAddress(relPath: String, param: [String: Any], block: @escaping WSBlock) {
        kprint(items: "------------ Add Billing Address ----------")
        let relPath = "\(relPath)"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func getOrderSummary(param: [String: Any], block: @escaping WSBlock) {
        kprint(items: "------------ Get Order Summary ----------")
        let relPath = "OrderSummary"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func getOrderPaymentDetail(param: [String: Any], block: @escaping WSBlock) {
        kprint(items: "------------ Get Order Payment Detail ----------")
        let relPath = "UpdateOrderPaymentDetail"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func getConfirmOrderList(param: [String: Any], block: @escaping WSBlock) {
        kprint(items: "------------ Get Confirm Order List ----------")
        let relPath = "ConfirmOrder2"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
}

//MARK :- WishList
extension KPWebCall {
    
    func getWishListData(param: [String: Any], block: @escaping WSBlock) {
        kprint(items: "------------ Get WishList Data ----------")
        let relPath = "WishList"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func updateWishListData(param: [String: Any], block: @escaping WSBlock) {
        kprint(items: "------------ Update WishList Data ----------")
        let relPath = "UpdateWishlistWithMultipleItems"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func moveToCart(param: [String: Any], block: @escaping WSBlock) {
        kprint(items: "------------ Move WishList To Cart ----------")
        let relPath = "MoveWishListItemsToCart"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func removeFromWishList(param: [String: Any], block: @escaping WSBlock) {
        kprint(items: "------------ Remove From WishList ----------")
        let relPath = "RemoveFromWishList"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func emailWishListToFriend(param: [String: Any], block: @escaping WSBlock) {
        kprint(items: "------------ Email WishList ----------")
        let relPath = "EmailWishList"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
}

//MARK :- Order
extension KPWebCall {
    
    func getOrderList(param: [String: Any], block: @escaping WSBlock) {
        kprint(items: "------------ Get Order List ----------")
        let relPath = "GetOrder"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func getOrderDetail(param: [String: Any], block: @escaping WSBlock) {
        kprint(items: "------------ Get Order Details ----------")
        let relPath = "GetOrderDetail"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func getOrderProductImages(param: [String: Any], block: @escaping WSBlock) {
        kprint(items: "------------ Get Order Product Images ----------")
        let relPath = "GetProductsPictures"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func reOrderItems(param: [String: Any], block: @escaping WSBlock) {
        kprint(items: "------------ Re Order Items ----------")
        let relPath = "ReOrder"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func getReturnOrderList(param: [String: Any], block: @escaping WSBlock) {
        kprint(items: "------------ Get Return Order List ----------")
        let relPath = "OrderReturnRequest"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func returnOrder(param: [String: Any], block: @escaping WSBlock) {
        kprint(items: "------------ Return Order ----------")
        let relPath = "ReturnRequestSubmit"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
}

//MARK :- Other
extension KPWebCall {
    
    func getDownloadedProducts(param: [String: Any], block: @escaping WSBlock) {
        kprint(items: "------------ Get Downloaded Products ----------")
        let relPath = "DownloadableProducts"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func getBackInStocks(param: [String: Any], block: @escaping WSBlock) {
        kprint(items: "------------ Get Stock Products ----------")
        let relPath = "BackInStockSubscriptionsList"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func deleteStocks(param: [String: Any], block: @escaping WSBlock) {
        kprint(items: "------------ Delete Stock ----------")
        let relPath = "DeleteCustomerSubscriptions"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func getRewardPoints(param: [String: Any], block: @escaping WSBlock) {
        kprint(items: "------------ Get Reward Points ----------")
        let relPath = "CustomerRewardPoints"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func submitContactUs(param: [String: Any], block: @escaping WSBlock) {
        kprint(items: "------------ Submit Contact Data ----------")
        let relPath = "ContactUsSend"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func searchProduct(param: [String: Any], block: @escaping WSBlock) {
        kprint(items: "------------ Search Product ----------")
        let relPath = "SearchProduct"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
}

