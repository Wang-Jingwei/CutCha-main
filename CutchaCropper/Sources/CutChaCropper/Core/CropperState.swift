//
//  CropperState.swift
//
//  Created by Chen Qizhi on 2019/10/15.
//

import UIKit

/// To restore cropper state
public struct CropperState: Codable, Equatable {
    var viewFrame: CGRect
    var angle: CGFloat
    var rotationAngle: CGFloat
    var straightenAngle: CGFloat
    var flipAngle: CGFloat
    var imageOrientationRawValue: Int
    var scrollViewTransform: CGAffineTransform
    var scrollViewCenter: CGPoint
    var scrollViewBounds: CGRect
    var scrollViewContentOffset: CGPoint
    var scrollViewMinimumZoomScale: CGFloat
    var scrollViewMaximumZoomScale: CGFloat
    var scrollViewZoomScale: CGFloat
    var cropBoxFrame: CGRect
    var photoTranslation: CGPoint
    var imageViewTransform: CGAffineTransform
    var imageViewBoundsSize: CGSize
}
