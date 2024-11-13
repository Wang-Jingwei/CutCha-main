//
//  SwiftUIView.swift
//  
//
//  Created by hansoong choong on 8/4/22.
//

import CoreImage
//import AppKit
import AVFoundation

let TOLL = 0.0001

extension CIImage {
    
    /// if amount < 0 then is shrink
    func expandBoder(amount : CGFloat, toSize size: CGSize) -> CIImage {
        if abs(amount) < TOLL { return self }
        /// expand mask
        let amount = amount
        let filterName = amount > 0 ? "CIMorphologyMaximum" : "CIMorphologyMinimum"
        let expandMaskCIImage = self.applyingFilter(filterName, parameters: [
            kCIInputRadiusKey: abs(amount)
        ])
        
        if let cgExpandMask = expandMaskCIImage.convertCIImageToCGImage() {
            return CIImage(cgImage: (cgExpandMask.resize(size: size))!)
        }
        
        return self
    }
    
    func convertCIImageToCGImage() -> CGImage? {
        let context = CIContext(options: nil)
        return context.createCGImage(self, from: self.extent)
    }
    
    @objc func saveJPEG(_ name:String, inDirectoryURL:URL? = nil, quality:CGFloat = 1.0) -> String? {
        
        var destinationURL = inDirectoryURL
        
        if destinationURL == nil {
            destinationURL = try? FileManager.default.url(for:.documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        }
        
        if var destinationURL = destinationURL {
            
            destinationURL = destinationURL.appendingPathComponent(name)
            
            if let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) {
                
                do {
                    
                    let context = CIContext()
                    
                    try context.writeJPEGRepresentation(of: self, to: destinationURL, colorSpace: colorSpace, options: [kCGImageDestinationLossyCompressionQuality as CIImageRepresentationOption : quality])
                    
                    return destinationURL.path
                    
                } catch {
                    return nil
                }
            }
        }
        
        return nil
    }
                
    func getOrientation() -> Int32 {
       let pros = self.properties
       
       if let orientation = pros["Orientation"] {
           return (orientation as? Int32) ?? 1
       }
       return 1
    }
    
}

extension CVPixelBuffer {
    func maxSize(length: Int) -> CVPixelBuffer {
        let (scaleWidth, scaleHeight) = getProcessSize(maxLength: length)
        
        if scaleWidth > 0 {
            return resizePixelBuffer(self, width: scaleWidth, height: scaleHeight)!
        }
        return self
    }
    
    func getProcessSize(maxLength: Int) -> (Int, Int) {
        let width = CVPixelBufferGetWidth(self)
        let height = CVPixelBufferGetHeight(self)

        if width > height {
            if width > maxLength {
                return (maxLength, Int(maxLength * height / width))
            }
        } else {
            if height > maxLength {
                return (Int(maxLength * width / height), maxLength)
            }
        }
        
        return (-1, -1)
    }
}
