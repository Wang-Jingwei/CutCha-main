//
//  Config.swift
//
//  Created by Chen Qizhi on 2019/10/15.
//

import UIKit

public enum QCropper {
    public enum Config {
        public static var croppingImageShortSideMaxSize: CGFloat = 1280
        public static var croppingImageLongSideMaxSize: CGFloat = 5120 // 1280 * 4

        public static var highlightColor = UIColor(red: 0.996, green: 0.678, blue: 0.22, alpha: 1.00)

        public static var resourceBundle = Bundle(for: CropperViewController.self)
    }
}
