//
//  LaMaInpainting.swift
//  SegmentAnywhere
//
//  Created by hansoong choong on 9/1/24.
//

import CoreML
import Foundation
import SwiftUI
import UIKit
import CoreImage
import Accelerate.vImage
import CoreGraphics
import Foundation
import VideoToolbox

//typealias CoreLaMa = LaMa //LaMa1024
//typealias CoreLamaInput = LaMaInput //LaMa1024Input
//public let CoreLaMaCropSize : CGFloat = 800 //1024

typealias CoreLaMa = LaMa1024
typealias CoreLamaInput = LaMa1024Input
public let CoreLaMaCropSize : CGFloat = 1024

class LaMaInpainting: ObservableObject {
    static let shared = LaMaInpainting()
    
    func inference(inputImage : UIImage, maskImage mask:UIImage, 
                   maskBoundary : CGRect, expandBorder : Int = 15) async -> UIImage? {
        let fixedLength = max(inputImage.size.width, inputImage.size.height)
        let newSize : CGSize = .init(width: fixedLength, height: fixedLength)
        let resizeInputImage = inputImage.resizedFixRatioTopLeft(to: newSize)
        let resizeMask = mask.resizedFixRatioTopLeft(to: newSize)
        //let _ = print("mask boundary = \(maskBoundary), \(maskBoundary.size)")
        do {
            let ciContext = CIContext()
            /// expand mask
            let expandBorder = expandBorder
            let expandMaskCIImage = CIImage(image: resizeMask)!.applyingFilter("CIMorphologyMaximum", parameters: [
                kCIInputRadiusKey: expandBorder
            ])
            let cgExpandMask = ciContext.createCGImage(expandMaskCIImage, from: expandMaskCIImage.extent)
            let cgMaskFinal = cgExpandMask?.resize(size: resizeMask.size)
            
            let cropSize = CGSize.init(width: CoreLaMaCropSize, height: CoreLaMaCropSize)
            
            ///always assume input image and mask size = AIConstants.lamaCropSize
            var cropX = max(0, maskBoundary.center.x - cropSize.width / 2)
            var cropY = max(0, maskBoundary.center.y - cropSize.height / 2)
            //let _ = print("maskBoundary = \(maskBoundary)")
            //let _ = print("1. cropXY = \(cropX), \(cropY)")
            if cropX + cropSize.width >= resizeInputImage.size.width {
                cropX = max(0, resizeInputImage.size.width - cropSize.width)
            }
            if cropY + cropSize.height >= resizeInputImage.size.height {
                cropY = max(0, resizeInputImage.size.height - cropSize.height)
            }
            
            //let _ = print("2. cropXY = \(cropX), \(cropY)")
            
            let cropRect = CGRect(x: cropX, y: cropY, width: cropSize.width, height: cropSize.height)
            //let _ = print("cropRect = \(cropRect)")
            let inputCGImage = resizeInputImage.cgImage?.cropping(to: cropRect)
            let inputCGMaskImage = cgMaskFinal?.cropping(to: cropRect)
            let input = try CoreLamaInput(imageWith: inputCGImage!, maskWith: inputCGMaskImage!)
            
            let mlconfig = MLModelConfiguration()
            mlconfig.setValue(1, forKey: "experimentalMLE5EngineUsage")
            mlconfig.computeUnits = .all
            
            let lama = try? CoreLaMa(configuration: mlconfig)
            let output = try await lama?.prediction(input: input)
            let inPaintingUIImage = UIImage(pixelBuffer: output!.output)
            
            UIGraphicsBeginImageContextWithOptions(resizeInputImage.size, false, 1.0)
            resizeInputImage.draw(in: .init(origin: .zero, size: resizeInputImage.size))
            inPaintingUIImage?.draw(in: cropRect)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return image?.crop(using: getCropSize(imageSize: inputImage.size, newSize: newSize))
            
        } catch let error {
            print(error)
            return nil
        }
    }
    
    func getCropSize(imageSize: CGSize, newSize: CGSize) -> CGSize {
        if imageSize.width > imageSize.height {
            let y1 = newSize.width * imageSize.height / imageSize.width
            return .init(width: newSize.width, height: y1)
        } else {
            let x1 = newSize.height * imageSize.width / imageSize.height
            return .init(width: x1, height: newSize.height)
        }
    }
    
    func write(_ cgimage: CGImage, to url: URL) throws {
        let cicontext = CIContext()
        let ciimage = CIImage(cgImage: cgimage)
        try cicontext.writePNGRepresentation(of: ciimage, to: url, format: .RGBA8, colorSpace: ciimage.colorSpace!)
    }
}
