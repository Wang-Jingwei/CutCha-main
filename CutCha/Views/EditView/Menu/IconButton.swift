//
//  IconButton.swift
//  colorful-room
//
//  Created by macOS on 7/15/20.
//  Copyright © 2020 PingAK9. All rights reserved.
//

import SwiftUI

struct IconButton: View {
    var imageType : IconImageType
    var imageSource : String
    var size : CGFloat
    var customImgSize : CGFloat
    var colorStyle : Color
    var multiColor : Bool = false
    
    init(_ imageType : IconImageType, _ imageSource: String = "", size: CGFloat = UILayout.ColorButtonSize, customImgSize: CGFloat = UILayout.CustomIconImgSize, colorStyle: Color = .white.opacity(0.7), multiColor: Bool = false) {
        self.imageType = imageType
        self.imageSource = imageSource
        self.size = size
        self.colorStyle = colorStyle
        self.customImgSize = customImgSize
        self.multiColor = multiColor
    }
    
    var body: some View {
        imageIcon
            .frame(width: self.size, height: self.size, alignment: .center)
//            .border(Color.checkcyan.opacity(0.5))
            
    }
    
    @ViewBuilder
    var imageIcon : some View {
        if self.imageType == .custom {
            Image(self.imageSource)
                .renderingMode(.original)
                .resizable()
                .scaledToFit()
                .foregroundStyle(colorStyle)
                .frame(width: customImgSize, height: customImgSize)
                
        } else {
            Image(systemName: self.imageSource)
                .font(.appButtonNormalFont)
                .symbolRenderingMode(self.multiColor ? .multicolor : .monochrome)
                .foregroundStyle(colorStyle)
        }
    }
    
    enum IconImageType {
        case custom
        case systemImage
    }
}
