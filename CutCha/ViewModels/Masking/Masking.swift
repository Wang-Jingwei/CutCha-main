//
//  Masking.swift
//  SegmentAnywhere
//
//  Created by hansoong choong on 28/3/24.
//

import SwiftUI

struct Masking {
    var maskToolOption : MaskToolOption = .SELECT_MASK
    var maskAnimation : MaskAnimation = .ANT_WALKING
    var maskFillOption : MaskFillOption = .FULL_IMAGE
    var plusSelection : Bool = true
    var maskExpand : Int = 15
    var gaussianSigma : Int = 2
    var stepBack : Bool = false ///undo
}
