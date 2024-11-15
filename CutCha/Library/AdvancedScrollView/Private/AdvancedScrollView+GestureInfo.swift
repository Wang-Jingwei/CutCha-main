//
//  AdvancedScrollView+GestureInfo.swift
//  
//
//  Created by Dmytro Anokhin on 14/07/2021.
//

import SwiftUI


@available(macOS 10.15, iOS 13.0, *)
struct TapContentGestureInfo {

    var count: Int

    var action: TapContentAction
}


@available(macOS 10.15, iOS 13.0, *)
struct DragContentGestureInfo {

    var action: DragContentAction
}

@available(macOS 10.15, iOS 13.0, *)
struct LongPressContentGestureInfo {

    var action: LongPressContentAction
}
