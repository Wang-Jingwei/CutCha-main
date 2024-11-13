//
//  UIColor+hex.swift
//  Example
//
//  Created by Danil Kristalev on 02.11.2021.
//  Copyright © 2021 Exyte. All rights reserved.
//

import UIKit
import SwiftUI

extension UIColor {
    public convenience init?(hex: String) {
        let r, g, b: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 6 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
                    g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
                    b = CGFloat(hexNumber & 0x0000ff) / 255

                    self.init(red: r, green: g, blue: b, alpha: 1)
                    return
                }
            }
        }

        return nil
    }
}

extension Color {
    static func hex(_ hex: String) -> Color {
        guard let uiColor = UIColor(hex: hex) else {
            return Color.red
        }
        return Color(uiColor)
    }
}

extension UIColor {
    func image(_ size: CGSize = CGSize(width: 1, height: 1), baseImage: UIImage? = nil) -> UIImage {
        var colorImage =  UIGraphicsImageRenderer(size: size).image { rendererContext in
            self.setFill()
            rendererContext.fill(CGRect(origin: .zero, size: size))
        }
        
        if baseImage != nil {
            UIGraphicsBeginImageContext(size)

            let areaSize = CGRect(origin: .zero, size: size)
            baseImage!.draw(in: areaSize)

            colorImage.draw(in: areaSize, blendMode: .normal, alpha: 0.8)

            colorImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
        }
        return colorImage
    }
}

extension Color {
    var components: (red: CGFloat, green: CGFloat, blue: CGFloat, opacity: CGFloat) {

        #if canImport(UIKit)
        typealias NativeColor = UIColor
        #elseif canImport(AppKit)
        typealias NativeColor = NSColor
        #endif

        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var o: CGFloat = 0

        guard NativeColor(self).getRed(&r, green: &g, blue: &b, alpha: &o) else {
            // You can handle the failure here as you want
            return (0, 0, 0, 0)
        }

        return (r, g, b, o)
    }

    var hex: String {
        String(
            format: "#%02x%02x%02x%02x",
            Int(components.red * 255),
            Int(components.green * 255),
            Int(components.blue * 255),
            Int(components.opacity * 255)
        )
    }
    
    func toOpacity(_ opacity : CGFloat) -> Self {
        let r = self.components.red
        let g = self.components.green
        let b = self.components.blue
        return Color(red: r, green: g, blue: b).opacity(opacity)
    }
    
    static func average(of color1: Color, and color2: Color) -> Color {
        let uiColor1 = UIColor(color1)
        let uiColor2 = UIColor(color2)
        
        var red1: CGFloat = 0, green1: CGFloat = 0, blue1: CGFloat = 0, alpha1: CGFloat = 0
        var red2: CGFloat = 0, green2: CGFloat = 0, blue2: CGFloat = 0, alpha2: CGFloat = 0
        
        uiColor1.getRed(&red1, green: &green1, blue: &blue1, alpha: &alpha1)
        uiColor2.getRed(&red2, green: &green2, blue: &blue2, alpha: &alpha2)
        
        let averageRed = (red1 + red2) / 2
        let averageGreen = (green1 + green2) / 2
        let averageBlue = (blue1 + blue2) / 2
        
        return Color(red: averageRed, green: averageGreen, blue: averageBlue)
    }
}
