//
//  TextManager.swift
//  SegmentAnywhere
//
//  Created by hansoong choong on 12/4/24.
//

import SwiftUI

struct TextManager {
    var textOptions = [TextOption()]
    var currentTextIndex : Int = 0
    var snapshotImage : UIImage?
    var shareAction : ShareAction = .NONE
    
    var fontSize : Int = 70
    var scaleEffectWidth : Double = 0
    var scaleEffectHeight : Double = 0
    var shadowRadius : Int = 5
    var shadowXDirection : Double = 0.0
    var shadowYDirection : Double = 5.0
    var textBorderWidth : Int = 10
    var backBorderWidth : Int = 5
    
    var objectAngle = Angle(degrees: 0.0)
    var previousObjectAngle = Angle(degrees: 0.0)
}
