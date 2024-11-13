//
//  AppState.swift
//  SegmentAnywhere
//
//  Created by hansoong choong on 28/3/24.
//

import SwiftUI

struct AppState {
    var isEditing: Bool = false
    var currentMenuType: EditMenuType = .mask
    var imageState: ImageState = .empty
    var loadingInfo: LoadingInfo = .empty
    var showEffectList : [Bool] = [Bool](repeating: false, count: EffectConstants.moreEffects.count)
    var showColorList : [Bool] = [Bool](repeating: true, count: ColorConstants.basicColorFilter.count)
}
