//
//  SwiftUIView.swift
//  SegmentAnywhere
//
//  Created by hansoong choong on 18/4/24.
//

import SwiftUI
import Vision

struct MKSymbolShape: InsettableShape {
    var insetAmount = 0.0
    var systemName: String = ""
    var imgName: String = ""
    
    var trimmedImage: UIImage {
        let cfg = UIImage.SymbolConfiguration(pointSize: 256.0)
        // get the symbol
        let img = !systemName.isEmpty ? UIImage(systemName: systemName, withConfiguration: cfg)?.withTintColor(.black, renderingMode: .alwaysOriginal) : UIImage(named: imgName)
        guard let imgA = img else {
            fatalError("No image found")
        }
        
        // we want to "strip" the bounding box empty space
        // get a cgRef from imgA
        guard let cgRef = imgA.cgImage else {
            fatalError("Could not get cgImage!")
        }
        // create imgB from the cgRef
        let imgB = UIImage(cgImage: cgRef, scale: imgA.scale, orientation: imgA.imageOrientation)
            .withTintColor(.black, renderingMode: .alwaysOriginal)
        
        // now render it on a white background
        let resultImage = UIGraphicsImageRenderer(size: imgB.size).image { ctx in
            UIColor.white.setFill()
            ctx.fill(CGRect(origin: .zero, size: imgB.size))
            imgB.draw(at: .zero)
        }
        
        return resultImage
    }
    
    func path(in rect: CGRect) -> Path {
        // cgPath returned from Vision will be in rect 0,0 1.0,1.0 coordinates
        //  so we want to scale the path to our view bounds
        
        let inputImage = self.trimmedImage
        guard let cgPath = detectVisionContours(from: inputImage) else { return Path() }
        let scW: CGFloat = (rect.width - CGFloat(insetAmount)) / cgPath.boundingBox.width
        let scH: CGFloat = (rect.height - CGFloat(insetAmount)) / cgPath.boundingBox.height
        
        // we need to invert the Y-coordinate space
        var transform = CGAffineTransform.identity
            .scaledBy(x: scW, y: -scH)
            .translatedBy(x: 0.0, y: -cgPath.boundingBox.height)
        
        if let imagePath = cgPath.copy(using: &transform) {
            return Path(imagePath)
        } else {
            return Path()
        }
    }
    
    func inset(by amount: CGFloat) -> some InsettableShape {
        var shape = self
        shape.insetAmount += amount
        return shape
    }
    
    func detectVisionContours(from sourceImage: UIImage) -> CGPath? {
        let inputImage = CIImage.init(cgImage: sourceImage.cgImage!)
        let contourRequest = VNDetectContoursRequest()
        contourRequest.revision = VNDetectContourRequestRevision1
        contourRequest.contrastAdjustment = 1.0
        contourRequest.maximumImageDimension = 512
        
        let requestHandler = VNImageRequestHandler(ciImage: inputImage, options: [:])
        try! requestHandler.perform([contourRequest])
        return contourRequest.results?.first?.normalizedPath
    }
}
