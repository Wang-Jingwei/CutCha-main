//
//  TextOption.swift
//  SegmentAnywhere
//
//  Created by hansoong choong on 12/4/24.
//

import Foundation
import SwiftUI

struct TextOption : Identifiable {
    var id = UUID()
    
    var isFontSelect : Bool = false
    
    var boxRect: CGRect = .zero
    var currentBoxRect: CGRect = .zero
    var elementTranslate : CGSize = .zero
    var boxSize: CGSize = CGSize(width: 300, height: 100)
    
    var inputText: String = "Add Text"
    var fontSize: Int = 70
    
    var foreColor: Color = .white
    var fontIsDisable: Bool = false
//    var backColor: Color = .lightGray
    var backColor: Color = Color.hex("F86818")
    var lastBackColor : Color = Color.hex("F86818")
    var backShape : ShapeOption = .capsule
    var backIsDisable : Bool = true
    var scaleEffect : CGSize = .init(width: 0, height: 0)
    
    var shadowColor : Color = Color.appDarkGray
    var lastShadowColor : Color = Color.appDarkGray
    var shadowRadius : Int = 5
    var shadowYDirection : Double = 5.0
    var shadowXDirection : Double = 0.0
    var shadowIsDisable : Bool = false
    
    var borderColor : Color = Color.appMain
    var lastBorderColor : Color = Color.appMain
    var backBorderWidth : Int = 0
    var borderGap : Int = 5
    var borderIsDisable : Bool = true
    var fontName : String = "ArialRoundedMTBold"
    
    var textBorderColor : Color = Color.appMain
    var textBorderIsDisable : Bool = false
    var textBorderWidth : Int = 10
    var lastTextBorderColor : Color = Color.appMain
    
    var objectAngle : Angle = Angle(degrees: 0.0)
    var previousObjectAngle : Angle = Angle(degrees: 0.0)
    var anchorPt : UnitPoint = .zero
}
