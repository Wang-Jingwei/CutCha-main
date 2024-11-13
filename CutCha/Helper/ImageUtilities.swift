//
//  ImageUtilities.swift
//  SegmentAnywhere
//
//  Created by hansoong choong on 5/12/23.
//

import SwiftUI

class ImageUtilities : ObservableObject {
    
    static let shared = ImageUtilities()
    
    func createMaskImage(of image: UIImage, 
                                fromMask mask: UIImage,
                                withBackground background: UIImage? = nil,
                                sigma: Double = 0,
                                cropRect : CGRect) -> UIImage? {
        //let _ = print("cropRect = \(cropRect), \(cropRect.maxX), \(cropRect.maxY)")
        guard let imageCG = image.cgImage?.cropping(to: cropRect), let maskCG = mask.cgImage!.cropping(to: cropRect) else { return nil }
        
        let cropUIImage = UIImage(cgImage: imageCG)
        let imageCI = CIImage(cgImage: cropUIImage.cgImage!)
        let maskCI = CIImage(cgImage: maskCG).applyingGaussianBlur(sigma: sigma)
        
        let background = background?.cgImage != nil ? CIImage(cgImage: background!.cgImage!) : CIImage.empty()
        let context = CIContext()
        guard let filter = CIFilter(name: "CIBlendWithMask") else { return nil }
        filter.setValue(imageCI, forKey: "inputImage")
        filter.setValue(maskCI, forKey: "inputMaskImage")
        filter.setValue(background, forKey: "inputBackgroundImage")
        
        guard let maskedImage = context.createCGImage(filter.outputImage!, from: maskCI.extent) else {
            return nil
        }
        return UIImage(cgImage: maskedImage)
//        if cropRect != .zero {
//            return UIImage(cgImage: maskedImage!)
//        }
//        return UIImage(cgImage: maskedImage)
    }
    
    func uiImagePngData(of image: UIImage,
                        fromMask mask: UIImage,
                        withBackground background: UIImage? = nil,
                        sigma: Double = 0,
                        cropRect : CGRect) -> Data {
        if let maskImage = createMaskImage(of: image,
                                           fromMask: mask,
                                           withBackground: background, 
                                           sigma: sigma, cropRect: cropRect) {
            return maskImage.pngData()!
        }
        return Data()
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))

        return path
    }
}
