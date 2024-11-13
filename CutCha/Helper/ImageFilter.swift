//
//  ImageFilter.swift
//  SegmentAnywhere
//
//  Created by hansoong choong on 13/5/24.
//

import SwiftUI

class ImageFilter {
    static let shared = ImageFilter()
    
    ///mask blend
    func blendWithMask(input : CIImage, mask:CIImage, background: CIImage) -> CIImage {
        let filter = CIFilter(name: "CIBlendWithMask")!
        filter.setValue(input, forKey: "inputImage")
        filter.setValue(mask, forKey: "inputMaskImage")
        filter.setValue(background, forKey: "inputBackgroundImage")
        return filter.outputImage!
    }
    
    ///this is important to make uiimage into default color space
    func redraw(_ uiImage : UIImage, _ newSize : CGSize? = nil) -> UIImage? {
        let drawSize : CGSize = newSize ?? uiImage.size
            
        UIGraphicsBeginImageContextWithOptions(drawSize, false, 1.0)
        uiImage.draw(in: .init(origin: .zero, size: drawSize))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

