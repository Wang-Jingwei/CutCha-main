//
//  TopBar.swift
//
//  Created by Chen Qizhi on 2019/10/15.
//

import UIKit

class TopBar: UIView {
    let topBarIconSize : CGFloat = 40
    
    lazy var flipButton: UIButton = {
        let button = textButton("FLIP")
        return button
    }()
    
    lazy var rotateButton: UIButton = {
        let button = textButton("ROTATE")
        return button
    }()
    
    lazy var blurBackgroundView: UIVisualEffectView = {
        let vev = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        vev.alpha = 0
        vev.backgroundColor = .clear
        vev.frame = self.bounds
        vev.isUserInteractionEnabled = false
        vev.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin, .flexibleRightMargin, .flexibleBottomMargin, .flexibleHeight, .flexibleWidth]
        return vev
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(blurBackgroundView)
        addSubview(flipButton)
        addSubview(rotateButton)
        
        flipButton.left = self.left
        rotateButton.left = self.width - flipButton.width
        flipButton.centerY = self.height/2
        rotateButton.centerY = self.height/2
    }
    
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func textButton(_ text: String) -> UIButton {
        let button = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 30, height: 15)))
        let font = UIFont.systemFont(ofSize: 13, weight: .regular)
        button.titleLabel?.font = font
        button.titleLabel?.textColor = UIColor(white: 1, alpha: 1)
        button.setTitle(text, for: .normal)
        return button
    }
}
