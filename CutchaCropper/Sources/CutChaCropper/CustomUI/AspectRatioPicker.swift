//
//  AspectRatioPicker.swift
//  Created by Chen Qizhi on 2019/10/15.
//

import UIKit

enum Box {
    case none
    case vertical
    case horizontal
}

protocol AspectRatioPickerDelegate: AnyObject {
    func aspectRatioPickerDidSelectedAspectRatio(_ aspectRatio: AspectRatio)
}

public class AspectRatioPicker: UIView {

    weak var delegate: AspectRatioPickerDelegate?

    var selectedAspectRatio: AspectRatio = .freeForm {
        didSet {
            let buttonIndex = aspectRatios.firstIndex(of: selectedAspectRatio) ?? 0
            scrollView.subviews.forEach { view in
                if let button = view as? UIButton, button.tag == buttonIndex {
                    button.isSelected = true
                    scrollView.scrollRectToVisible(button.frame.insetBy(dx: -30, dy: 0), animated: true)
                }
            }
        }
    }

    var rotated: Bool = false
    var aspectRatios: [AspectRatio] = [
        .freeForm,
        .ratio(width: 9, height: 16),
        .ratio(width: 8, height: 10),
        .ratio(width: 5, height: 7),
        .ratio(width: 3, height: 4),
        .ratio(width: 3, height: 5),
        .ratio(width: 2, height: 3),
        .ratio(width: 1, height: 1),
        .ratio(width: 16, height: 9),
        .ratio(width: 10, height: 8),
        .ratio(width: 7, height: 5),
        .ratio(width: 4, height: 3),
        .ratio(width: 5, height: 3),
        .ratio(width: 3, height: 2)
        ] {
        didSet {
            reloadScrollView()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(scrollView)
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    lazy var scrollView: UIScrollView = {
        let sv = UIScrollView(frame: self.bounds)
        sv.backgroundColor = .clear
        sv.decelerationRate = .fast
        sv.showsHorizontalScrollIndicator = false
        sv.showsVerticalScrollIndicator = false
        return sv
    }()

    func reloadScrollView() {
        scrollView.subviews.forEach { button in
            if button is UIButton {
                button.removeFromSuperview()
            }
        }
        
        let boxButtonSide: CGFloat = 40
        let scrollViewHeight: CGFloat = 50
        let buttonCount = aspectRatios.count
        let normalFont = UIFont.systemFont(ofSize: 9, weight: .regular)
        let selectedFont = UIFont.systemFont(ofSize: 9, weight: .bold)
        let padding: CGFloat = 20
        let margin = 2.0
        let colorImage = UIImage(color: UIColor(white: 0.5, alpha: 0.4),
                                 size: CGSize(width: 10, height: 10))
        let backgroundImage = colorImage.resizableImage(withCapInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))

        var x: CGFloat = margin
        
        for i in 0 ..< buttonCount {
            let ar = aspectRatios[i]
            let button = boxButton(size: CGSize(width: CGFloat(boxButtonSide * ar.getRatio.0), height: CGFloat(boxButtonSide * ar.getRatio.1)))
            
            button.tag = i
            button.backgroundColor = UIColor.clear
            button.setBackgroundImage(backgroundImage, for: .selected)
            button.layer.masksToBounds = true
            button.titleLabel?.font = normalFont
            button.addTarget(self, action: #selector(aspectRatioButtonPressed(_:)), for: .touchUpInside)

            let title = ar.description
            let normalTitle = NSAttributedString(string: title, attributes: [NSAttributedString.Key.font: normalFont, NSAttributedString.Key.foregroundColor: UIColor(white: 0.6, alpha: 1)])
            let selectedTitle = NSAttributedString(string: title, attributes: [NSAttributedString.Key.font: selectedFont, NSAttributedString.Key.foregroundColor: UIColor(red: 0.996, green: 0.678, blue: 0.22, alpha: 1)])
            button.setAttributedTitle(normalTitle, for: .normal)
            button.setAttributedTitle(selectedTitle, for: .selected)
            button.frame = CGRect(x: x, y: 0, width: CGFloat(boxButtonSide * ar.getRatio.0), height: CGFloat(boxButtonSide * ar.getRatio.1))
            button.top = scrollView.top + (scrollViewHeight-button.height)/2
            x += CGFloat(boxButtonSide * ar.getRatio.0) + padding

            scrollView.addSubview(button)
        }

        scrollView.height = scrollViewHeight
        scrollView.contentSize = CGSize(width: x + padding, height: scrollViewHeight)
    }

    @objc
    func aspectRatioButtonPressed(_ sender: UIButton) {
        if !sender.isSelected {
            scrollView.subviews.forEach { view in
                if let button = view as? UIButton {
                    button.isSelected = false
                }
            }

            if sender.tag < aspectRatios.count {
                selectedAspectRatio = aspectRatios[sender.tag]
            } else {
                selectedAspectRatio = .freeForm
            }

            delegate?.aspectRatioPickerDidSelectedAspectRatio(selectedAspectRatio)
        }
    }

    func boxButton(size: CGSize) -> UIButton {
        let button = UIButton(frame: CGRect(origin: .zero, size: size))

        let normalColorImage = UIImage(color: UIColor(white: 0.14, alpha: 1),
                                       size: CGSize(width: 10, height: 10))
        let normalBackgroundImage = normalColorImage.resizableImage(withCapInsets: UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3))

        let selectedColorImage = UIImage(color: UIColor(white: 0.56, alpha: 1),
                                         size: CGSize(width: 10, height: 10))
        let selectedBackgroundImage = selectedColorImage.resizableImage(withCapInsets: UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3))

        /// ??? "QCropper.checkmark" not work
//        let checkmark = UIImage(systemName: "checkmark.seal.fill", in: QCropper.Config.resourceBundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
//        let checkmark = UIImage(systemName: "checkmark")

        button.tintColor = .black
        button.layer.borderColor = UIColor(white: 0.56, alpha: 1).cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 3
        button.layer.masksToBounds = true
        button.setBackgroundImage(normalBackgroundImage, for: .normal)
        button.setBackgroundImage(selectedBackgroundImage, for: .selected)
        
//        override var isSelected: Bool {
//            didSet {
//                if isSelected {
//                    tintColor = QCropper.Config.highlightColor
//                } else {
//                    tintColor = UIColor(white: 0.725, alpha: 1)
//                }
//            }
//        }

        return button
    }
}
