//
//  Toolbar.swift
//
//  Created by Chen Qizhi on 2019/10/15.
//

import UIKit

class Toolbar: UIView {
    // font size 20pt in swiftui systemImage ->
    let iconImgWidth : CGFloat = 17.0
    let iconImgHeight : CGFloat = 16.67
//    let verticalInset: CGFloat = 10.0
//    let horizontalInset: CGFloat = 20.0
    let iconWidthHeight : CGFloat = 55
    
    
    lazy var flipButton: UIButton = {
        let button = titleButton("FLIP")
        return button
    }()

    lazy var rotateButton: UIButton = {
        let button = titleButton("ROTATE")
        return button
    }()

    lazy var resetButton: UIButton = {
        let button = self.imageButton("xmark-regular-small")
        button.isHidden = true
        return button
    }()

    lazy var doneButton: UIButton = {
        let button = self.imageButton("checkmark-regular-small")
        return button
    }()

    lazy var blurBackgroundView: UIVisualEffectView = {
        let vev = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        vev.alpha = 0.3
        vev.backgroundColor = .clear
        vev.frame = self.bounds
        vev.isUserInteractionEnabled = false
        vev.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin, .flexibleRightMargin, .flexibleBottomMargin, .flexibleHeight, .flexibleWidth]
        return vev
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(blurBackgroundView)
        addSubview(resetButton)
        addSubview(doneButton)
        addSubview(flipButton)
        addSubview(rotateButton)
        
        doneButton.top = 0
        doneButton.right = self.width
        resetButton.top = 0
        resetButton.left = 0
        flipButton.left = self.width * 1/4
        rotateButton.right = self.width * 3/4
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func titleButton(_ title: String, highlight: Bool = false) -> UIButton {
        let font = UIFont.systemFont(ofSize: 12)
        let button = UIButton(frame: CGRect(center: .zero,
                                            size: CGSize(width: title.width(withFont: font) + 20, height: iconWidthHeight)))
        if highlight {
            button.setTitleColor(QCropper.Config.highlightColor, for: .normal)
            button.setTitleColor(QCropper.Config.highlightColor.withAlphaComponent(0.7), for: .highlighted)
        } else {
            button.setTitleColor(UIColor(white: 1, alpha: 1.0), for: .normal)
            button.setTitleColor(UIColor(white: 1, alpha: 0.7), for: .highlighted)
        }
        button.titleLabel?.font = font
        button.setTitle(title, for: .normal)
        button.top = 0

        button.autoresizingMask = [.flexibleRightMargin, .flexibleWidth]
//        button.contentEdgeInsets = UIEdgeInsets(top: verticalInset, left: horizontalInset, bottom: verticalInset, right: horizontalInset)
        return button
    }
    
    func imageButton(_ title: String) -> UIButton {
        let image = UIImage(named: title, in: QCropper.Config.resourceBundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
//        let button = UIButton(frame: CGRect(center: .zero,
//                                            size: CGSize(width: (horizontalInset * 2) + iconSize, height: (verticalInset * 2) + iconSize)))
        let button = UIButton(frame: CGRect(center: .zero,
                                            size: CGSize(width: iconWidthHeight, height: iconWidthHeight)))
        
        let verticalInset = (iconWidthHeight - iconImgHeight)/2
        let horizontalInset = (iconWidthHeight - iconImgWidth)/2
        button.setImage(image, for:.normal)
        button.contentEdgeInsets = UIEdgeInsets(top: verticalInset, left: horizontalInset, bottom: verticalInset, right: horizontalInset)
        button.tintColor = QCropper.Config.highlightColor
        return button
    }
}
