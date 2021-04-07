//  Created by iOS Development Company on 13/01/16.
//  Copyright © 2016 The App Developers. All rights reserved.
//

import UIKit

enum LHTFont: String {
    
    case robotoRegular = "Roboto-Regular"
    case robotoMedium = "Roboto-Medium"
    case robotoSemibold = "Roboto-Semibold"
    case robotoBold = "Roboto-Bold"
    
    case openSansRegular = "OpenSans"
    case openSansMedium = "OpenSans-Medium"
    case openSansSemibold = "OpenSans-Semibold"
    case openSansBold = "OpenSans-Bold"
    
    case poppinsRegular = "Poppins-Regular"
    
}

extension UIFont {
    
    class func LHTFontWith(_ name: LHTFont, size: CGFloat) -> UIFont{
        return UIFont.systemFont(ofSize: size)//UIFont(name: name.rawValue, size: size)!
    }
}
