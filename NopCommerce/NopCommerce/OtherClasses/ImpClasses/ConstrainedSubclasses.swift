//  Created by iOS Development Company on 01/03/16.
//  Copyright © 2016 The App Developers. All rights reserved.
//

import UIKit


//MARK: - Constained Classes for All device support
/// Below all calssed reduces text of button and Lavel according to device screen size
class KPFixButton: UIButton {
    override func awakeFromNib() {
        if let img = self.imageView{
            let btnsize = self.frame.size
            let imgsize = img.frame.size
            let verPad = ((btnsize.height - (imgsize.height * _widthRatio)) / 2)
            self.imageEdgeInsets = UIEdgeInsets(top: verPad, left: 0, bottom: verPad, right: 0)
            self.imageView?.contentMode = .scaleAspectFit
        }
        if let afont = titleLabel?.font {
            titleLabel?.font = afont.withSize(afont.pointSize * _widthRatio)
        }
    }
}

class KPWidthButton: UIButton {
    
    @IBInspectable public var borderWidth: CGFloat {
        get { return self.layer.borderWidth }
        set { self.layer.borderWidth = newValue }
    }
    @IBInspectable public var borderColor: UIColor {
        get { return self.layer.borderColor == nil ? UIColor.clear : UIColor(cgColor: self.layer.borderColor!) }
        set { self.layer.borderColor = newValue.cgColor }
    }
    
    override func awakeFromNib() {
        if let img = self.imageView{
            let btnsize = self.frame.size
            let imgsize = img.frame.size
            let verPad = (((btnsize.height * _widthRatio) - (imgsize.height * _widthRatio)) / 2)
            self.imageEdgeInsets = UIEdgeInsets(top: verPad, left: 0, bottom: verPad, right: 0)
            self.imageView?.contentMode = .scaleAspectFit
        }
        if let afont = titleLabel?.font {
            titleLabel?.font = afont.withSize(afont.pointSize * _widthRatio)
        }
    }
}

//for arabic layout support in collection view
class CustomCollectionViewLayout: UICollectionViewFlowLayout {
    override var flipsHorizontallyInOppositeLayoutDirection: Bool{
        return _appDelegator.isArabic
    }
}

class JPWidthTextField: UITextField {
    @IBInspectable var letterSpace : CGFloat = 0{
        didSet{
            letterSpace = letterSpace * _widthRatio
        }
    }
    
    let padding = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 5)
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if let afont = font {
            font = afont.withSize(afont.pointSize * _widthRatio)
        }
        
        if let place = placeholder{
            self.addCharactersSpacingInPlaceHolder(spacing: letterSpace, text: place)
        }
        
        if let txt = text{
            self.addCharactersSpacingInTaxt(spacing: letterSpace, text: txt)
        }
        self.textAlignment = _appDelegator.isArabic ? .right : .left
    }
}

class JPHeightTextField: UITextField {
    @IBInspectable var letterSpace : CGFloat = 0{
        didSet{
            letterSpace = letterSpace * _heightRatio
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        if let afont = font {
            font = afont.withSize(afont.pointSize * _heightRatio)
        }
        
        if let place = placeholder{
            self.addCharactersSpacingInPlaceHolder(spacing: letterSpace, text: place)
        }
        if let txt = text{
            self.addCharactersSpacingInTaxt(spacing: letterSpace, text: txt)
        }
    }
}


class JPWidthTextView: UITextView {
    @IBInspectable var letterSpace : CGFloat = 0{
        didSet{
            letterSpace = letterSpace * _heightRatio
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        if let afont = font {
            font = afont.withSize(afont.pointSize * _widthRatio)
        }
        if let txt = text{
            self.addCharactersSpacingInTaxt(spacing: letterSpace, text: txt)
        }
    }
}

class JPTextView: UITextView {
    
    @IBInspectable public var borderWidth: CGFloat {
           get { return self.layer.borderWidth }
           set { self.layer.borderWidth = newValue }
       }
       @IBInspectable public var borderColor: UIColor {
           get { return self.layer.borderColor == nil ? UIColor.clear : UIColor(cgColor: self.layer.borderColor!) }
           set { self.layer.borderColor = newValue.cgColor }
       }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tintColor = UIColor.hexStringToUIColor(hexStr: "2D2D41", alpha: 1.0)
        textColor = UIColor.hexStringToUIColor(hexStr: "2D2D41", alpha: 1.0)
        textContainerInset = UIEdgeInsets(top: 12, left: _appDelegator.isArabic ? 0 : 7, bottom: 0, right: _appDelegator.isArabic ? 7 : 0)
        font = UIFont.systemFont(ofSize: 16.widthRatio)
        self.textAlignment = _appDelegator.isArabic ? .right : .left
    }
}

class JPWidthButton: UIButton {
    @IBInspectable var letterSpace : CGFloat = 0{
        didSet{
            letterSpace = letterSpace * _widthRatio
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        if let afont = titleLabel?.font {
            titleLabel?.font = afont.withSize(afont.pointSize * _widthRatio)
        }
        if let title = titleLabel?.text{
            titleLabel?.addCharactersSpacing(spacing: letterSpace, text: title)
        }
    }
}

class JPHeightButton: UIButton {
    @IBInspectable var letterSpace : CGFloat = 0{
        didSet{
            letterSpace = letterSpace * _heightRatio
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        if let afont = titleLabel?.font {
            titleLabel?.font = afont.withSize(afont.pointSize * _heightRatio)
        }
        if let title = titleLabel?.text{
            titleLabel?.addCharactersSpacing(spacing: letterSpace, text: title)
        }
    }
}

class KPWidthAttriLabel: UILabel {
    
    @IBInspectable var letterSpace : CGFloat = 0 {
        didSet{
            letterSpace = letterSpace * _widthRatio
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if let att = self.attributedText{
            let str = att.string as NSString
            let range = str.range(of: att.string)
            let newAttriString = NSMutableAttributedString(attributedString: att)
            att.enumerateAttributes(in: range, options: [], using: { (attri, range, pointer) in
                if let font = attri[NSAttributedString.Key.font] as? UIFont{
                    let newFont = font.withSize(font.pointSize * _widthRatio)
                    newAttriString.addAttributes([NSAttributedString.Key.font: newFont], range: range)
                }
            })
            self.attributedText = newAttriString
        }
        if let _ = text{
            //            addCharactersSpacing(spacing: letterSpace, text: title)
        }
    }
}


class JPWidthLabel: UILabel {
    @IBInspectable var letterSpace : CGFloat = 0 {
        didSet{
            letterSpace = letterSpace * _widthRatio
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        font = font.withSize(font.pointSize * _widthRatio)
        if let title = text{
            addCharactersSpacing(spacing: letterSpace, text: title)
        }
    }
} 

class JPHeightLabel: UILabel {
    @IBInspectable var letterSpace : CGFloat = 0{
        didSet{
            letterSpace = letterSpace * _heightRatio
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        font = font.withSize(font.pointSize * _heightRatio)
        if let title = text{
            addCharactersSpacing(spacing: letterSpace, text: title)
        }
    }
}

class KPWidthAttriButton: JPWidthButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if let att = self.currentAttributedTitle{
            let str = att.string as NSString
            let range = str.range(of: att.string)
            let newAttriString = NSMutableAttributedString(attributedString: att)
            att.enumerateAttributes(in: range, options: [], using: { (attri, range, pointer) in
                if let font = attri[NSAttributedString.Key.font] as? UIFont{
                    let newFont = font.withSize(font.pointSize * _widthRatio)
                    newAttriString.addAttributes([NSAttributedString.Key.font: newFont], range: range)
                }
            })
            self.setAttributedTitle(newAttriString, for: UIControl.State.normal)
        }
        
        if let afont = titleLabel?.font {
            titleLabel?.font = afont.withSize(afont.pointSize * _widthRatio)
        }
    }
}

/// This View contains collection of Horizontal and Vertical constrains. Who's constant value varies by size of device screen size.
class ConstrainedControl: UIControl {
    
    // MARK: Outlets
    @IBOutlet var horizontalConstraints: [NSLayoutConstraint]?
    @IBOutlet var verticalConstraints: [NSLayoutConstraint]?
    
    // MARK: Awaken
    override func awakeFromNib() {
        super.awakeFromNib()
        constraintUpdate()
    }
    
    func constraintUpdate() {
        if let hConts = horizontalConstraints {
            for const in hConts {
                let v1 = const.constant
                let v2 = v1 * _widthRatio
                const.constant = v2
            }
        }
        if let vConst = verticalConstraints {
            for const in vConst {
                let v1 = const.constant
                let v2 = v1 * _heightRatio
                const.constant = v2
            }
        }
    }
}


class ConstrainedView: UIView {
    
    // MARK: Outlets
    @IBOutlet var horizontalConstraints: [NSLayoutConstraint]?
    @IBOutlet var verticalConstraints: [NSLayoutConstraint]?
    
    // MARK: Awaken
    override func awakeFromNib() {
        super.awakeFromNib()
        constraintUpdate()
    }
    
    func constraintUpdate() {
        if let hConts = horizontalConstraints {
            for const in hConts {
                let v1 = const.constant
                let v2 = v1 * _widthRatio
                const.constant = v2
            }
        }
        if let vConst = verticalConstraints {
            for const in vConst {
                let v1 = const.constant
                let v2 = v1 * _heightRatio
                const.constant = v2
            }
        }
    }
}

class GenericTableViewCell: ConstrainedTableViewCell {
    
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var lblSubtitle: UILabel!
    @IBOutlet var imgv: UIImageView!
    @IBOutlet var lblSeprator : UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}

/// This Collection view cell contains collection of Horizontal and Vertical constrains. Who's constant value varies by size of device screen size.
class ConstrainedCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var horizontalConstraints: [NSLayoutConstraint]?
    @IBOutlet var verticalConstraints: [NSLayoutConstraint]?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        constraintUpdate()
    }
    
    // This will update constaints and shrunk it as device screen goes lower.
    func constraintUpdate() {
        if let hConts = horizontalConstraints {
            for const in hConts {
                let v1 = const.constant
                let v2 = v1 * _widthRatio
                const.constant = v2
            }
        }
        if let vConst = verticalConstraints {
            for const in vConst {
                let v1 = const.constant
                let v2 = v1 * _heightRatio
                const.constant = v2
            }
        }
    }
}

/// This Header view cell contains tableview of Horizontal and Vertical constrains. Who's constant value varies by size of device screen size.
class ConstrainedHeaderTableView: UITableViewHeaderFooterView {
    
    @IBOutlet var horizontalConstraints: [NSLayoutConstraint]?
    @IBOutlet var verticalConstraints: [NSLayoutConstraint]?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        constraintUpdate()
    }
    
    // This will update constaints and shrunk it as device screen goes lower.
    func constraintUpdate() {
        if let hConts = horizontalConstraints {
            for const in hConts {
                let v1 = const.constant
                let v2 = v1 * _widthRatio
                const.constant = v2
            }
        }
        if let vConst = verticalConstraints {
            for const in vConst {
                let v1 = const.constant
                let v2 = v1 * _heightRatio
                const.constant = v2
            }
        }
    }
}



/// This Table view cell contains collection of Horizontal and Vertical constrains. Who's constant value varies by size of device screen size.
class ConstrainedTableViewCell: UITableViewCell {
    
    @IBOutlet var horizontalConstraints: [NSLayoutConstraint]?
    @IBOutlet var verticalConstraints: [NSLayoutConstraint]?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        constraintUpdate()
    }
    
    // This will update constaints and shrunk it as device screen goes lower.
    func constraintUpdate() {
        if let hConts = horizontalConstraints {
            for const in hConts {
                let v1 = const.constant
                let v2 = v1 * _widthRatio
                const.constant = v2
            }
        }
        if let vConst = verticalConstraints {
            for const in vConst {
                let v1 = const.constant
                let v2 = v1 * _heightRatio
                const.constant = v2
            }
        }
    }
}
