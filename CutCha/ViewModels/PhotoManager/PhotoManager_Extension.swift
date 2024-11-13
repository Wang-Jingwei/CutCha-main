//
//  PhotoManager_Extension.swift
//  SegmentAnywhere
//
//  Created by hansoong choong on 25/3/24.
//

import SwiftUI
import Vision
import Foundation

/// move some functions here
extension PhotoManager {
    
    // MARK: current Image and mask
    
    func updateDisplayImage(usingModel filterModel : FilterModel) {
        if filterModel is PolynomialTransformer {
            let cgImage = (filterModel as! PolynomialTransformer).outputImage
            updateDisplayImage(cgImage: cgImage!)
        } else if filterModel is MorphologyTransformer {
            let cgImage = (filterModel as! MorphologyTransformer).outputImage
            updateDisplayImage(cgImage: cgImage!)
        } else if filterModel is HistogramSpecifier {
            let cgImage = (filterModel as! HistogramSpecifier).outputImage
            updateDisplayImage(cgImage: cgImage!)
        } else if filterModel is EffectFilterViewModel {
            updateDisplayImage(effectFilter: filterModel as! EffectFilterViewModel)
        } else if filterModel is LUTViewModel {
            let lutFilterModel = filterModel as! LUTViewModel
            let uiImage: UIImage
            if lutFilterModel.isModified {
                uiImage = lutFilterModel.applyLUTFilter(inputUIImage: lastFilteringImage!)!
            }else{
                uiImage = lutFilterModel.currentLUTItem.getLUTImage(inputImage: lastFilteringImage!)
            }
            updateDisplayImage(cgImage:uiImage.cgImage!)
        } else if filterModel is FillBackgroundViewModel {
            updateDisplayImage(fillVM:filterModel as! FillBackgroundViewModel)
        }
    }
    
    func getFillRect() -> CGRect {
        
        switch self.masking.maskFillOption {
        case .MASK_ONLY:
            return maskBoundary
        case .INVERSE_MASK:
            if let cgpath = getContourPath(from: self.maskImage?.imageColorInvert(), fromFill: true) {
                let maskBoundary = getMaskBoundary(cgPath: cgpath)
                if maskBoundary == .zero || maskBoundary.isInfinite || maskBoundary.isNull || maskBoundary.isEmpty {
                    return .init(origin: .zero, size: lastFilteringImage!.size)
                }
                return maskBoundary
            }
            return .init(origin: .zero, size: lastFilteringImage!.size)
        default:
            return .init(origin: .zero, size: lastFilteringImage!.size)
        }
    }
    
    func getGradiantStrokePath() -> CGPath {
        
        switch self.masking.maskFillOption {
        case .MASK_ONLY:
            if let cgPath = getContourPath(from: self.maskImage, fromFill: true) {
                
                var transform = CGAffineTransform.identity
                    .scaledBy(x: lastFilteringImage!.size.width, y: lastFilteringImage!.size.height)
                    .concatenating(CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: lastFilteringImage!.size.height))
                
                if let maskPath = cgPath.copy(using: &transform) {
                    return maskPath
                }
            }
        case .INVERSE_MASK:
            if let cgPath = getContourPath(from: self.maskImage?.imageColorInvert(), fromFill: true) {
                var transform = CGAffineTransform.identity
                    .scaledBy(x: lastFilteringImage!.size.width, y: lastFilteringImage!.size.height)
                    .concatenating(CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: lastFilteringImage!.size.height))
                
                if let maskPath = cgPath.copy(using: &transform) {
                    return maskPath
                }
            }
        default:
            let finalPath = CGMutablePath()
            finalPath.addRect(.init(origin: .zero, size: lastFilteringImage!.size))
            return finalPath
        }
        return Path().cgPath
    }
    
    func updateDisplayImage(fillVM : FillBackgroundViewModel) {
        
        var filteredImage : UIImage
        
        if case let .color(color) = fillVM.currentFillItem.fillEffect {
            if fillVM.strokeOnly {
                let fakePattern = GradientPattern.init(colors: [color])
                filteredImage = fakePattern.image(path: getGradiantStrokePath(),
                                                     lineWidth : CGFloat(fillVM.lineWidth),
                                                     with: lastFilteringImage!.size,
                                                     baseImage: lastFilteringImage)
                currentDisplayImage = filteredImage
                return
            } else {
                let baseImage = fillVM.keepBackground ? lastFilteringImage : nil
                filteredImage = UIColor(color).image(lastFilteringImage!.size, baseImage: baseImage)
            }
        } else if case let .gradient(pattern) = fillVM.currentFillItem.fillEffect {
            if fillVM.strokeOnly {
                filteredImage = pattern.image(path: getGradiantStrokePath(),
                                              lineWidth : CGFloat(fillVM.lineWidth),
                                              with: lastFilteringImage!.size,
                                              baseImage: lastFilteringImage)
                currentDisplayImage = filteredImage
                return
            } else {
                let baseImage = fillVM.keepBackground ? lastFilteringImage : nil
                filteredImage = pattern.image(in: getFillRect(), with: lastFilteringImage!.size, baseImage: baseImage)
            }
        } else if case .image(_) = fillVM.currentFillItem.fillEffect {
            let patternImage = fillVM.patternImage
            filteredImage = patternImage.image(in: .init(origin: .zero, size: lastFilteringImage!.size),
                                               with: lastFilteringImage!.size,
                                               baseImage: lastFilteringImage,
                                               blendMode: fillVM.blendMode,
                                               alpha: fillVM.opacity)
        } else {
            filteredImage = lastFilteringImage!
        }
        //try? PhotoManager.shared.write(filteredImage.cgImage, to: URL(filePath: "/Users/hansoong/Downloads/test.png"))
        if let bwMask = getBWMask() {
            
            let ciFilteredImage = CIImage(cgImage: filteredImage.cgImage!)
            
            let sourceMask = bwMask.colorToAlpha()
            let maskCI = CIImage(cgImage: sourceMask.cgImage!)
                .applyingGaussianBlur(sigma: Double(masking.gaussianSigma))
                .cropped(to: .init(origin: .zero, size: sourceMask.size))
            
            
            let sourceImage : UIImage = lastFilteringImage!
            let current = CIImage(cgImage: sourceImage.cgImage!)
            let resultImage = ImageFilter.shared.blendWithMask(input: ciFilteredImage,
                                                               mask: maskCI,
                                                               background: current)
            if let cgImage = resultImage.convertCIImageToCGImage() {
                currentDisplayImage = UIImage(cgImage: cgImage)
            }
        } else {
            currentDisplayImage = filteredImage
        }
    }
    
    func updateDisplayImage(effectFilter : EffectFilterViewModel) {

        if let bwMask = getBWMask() {
            
            var filteredImage : UIImage
            
            if case .gaussianBlur = effectFilter.currentEffectItem.ciFilterEffect {
                let ciMask = convertUItoCI(from: bwMask)
                filteredImage = effectFilter
                    .getEffectImage(effect: effectFilter.currentEffectItem.ciFilterEffect,
                                    inputImage: lastFilteringImage!,
                                    ciMaskImage: ciMask)
            } else {
                filteredImage = effectFilter
                    .getEffectImage(effect: effectFilter.currentEffectItem.ciFilterEffect,
                                    inputImage: lastFilteringImage!)
            }
            let ciFilteredImage = CIImage(cgImage: filteredImage.cgImage!)

            let sourceMask = bwMask.colorToAlpha()
            let maskCI = CIImage(cgImage: sourceMask.cgImage!)
                .applyingGaussianBlur(sigma: Double(masking.gaussianSigma))
                .cropped(to: .init(origin: .zero, size: sourceMask.size))
            
            
            let sourceImage : UIImage = lastFilteringImage!
            let current = CIImage(cgImage: sourceImage.cgImage!)
            let resultImage = ImageFilter.shared.blendWithMask(input: ciFilteredImage,
                                                               mask: maskCI,
                                                               background: current)
            if let cgImage = resultImage.convertCIImageToCGImage() {
                currentDisplayImage = UIImage(cgImage: cgImage)
            }
        } else {
            let filteredImage = effectFilter
                .getEffectImage(effect: effectFilter.currentEffectItem.ciFilterEffect, inputImage: lastFilteringImage!)
            currentDisplayImage = filteredImage
        }
    }
    
    func updateDisplayImage(cgImage : CGImage) {
        let sourceImage : UIImage = lastFilteringImage!
        let filteredImage : UIImage = ImageFilter.shared.redraw(UIImage(cgImage: cgImage))!
        
        if let bwMask = getBWMask() {
            let sourceMask = bwMask.colorToAlpha()
            let ciFilteredImage = CIImage(cgImage: filteredImage.cgImage!)
            let maskCI = CIImage(cgImage: sourceMask.cgImage!)
                .applyingGaussianBlur(sigma: Double(masking.gaussianSigma))
                .cropped(to: .init(origin: .zero, size: sourceMask.size))
                
            let current = CIImage(cgImage: sourceImage.cgImage!)
            let resultImage = ImageFilter.shared.blendWithMask(input: ciFilteredImage,
                                                               mask: maskCI,
                                                               background: current)
            if let cgImage = resultImage.convertCIImageToCGImage() {
                currentDisplayImage = UIImage(cgImage: cgImage)
            }
        } else {
            currentDisplayImage = filteredImage
        }
    }
    
    func updateImageMask(currentMaskImage: UIImage?) {
        if currentMaskImage != nil {
            let context = CIContext()
            let filterMaskToAlpha = CIFilter(name: "CIMaskToAlpha")
            let ciMaskImage = CIImage(cgImage: currentMaskImage!.cgImage!)
            filterMaskToAlpha!.setValue(ciMaskImage, forKey: "inputImage")
            let output = filterMaskToAlpha!.outputImage!
            let cgMask = context.createCGImage(output, from: ciMaskImage.extent)
            self.currentMaskImageBA = UIImage(cgImage: cgMask!)
        } else {
            self.currentMaskImageBA = nil
        }
    }
    
    func getCurrentMask(opaque : Bool = false) -> UIImage? {
        let canvasSize = currentDisplayImage!.size
        let middle = CGPoint(x: canvasSize.width/2, y: canvasSize.height/2)
        UIGraphicsBeginImageContextWithOptions(canvasSize, opaque, 1.0)
        // Get the current context
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(UIColor.white.cgColor)
        context.setStrokeColor(UIColor.white.cgColor)
        context.setLineCap(.round)
        context.setLineJoin(.round)
        if currentMaskImageBA != nil {
            currentMaskImageBA?.draw(in: .init(center: middle, size: canvasSize))
        }
        
        for line in lines {
            context.beginPath()
            context.addLines(between: line.points)
            context.setLineWidth(CGFloat(line.brushSize))
            
            if line.isPlus {
                context.setBlendMode(.normal)
            } else {
                context.setBlendMode(.clear)
            }
            context.strokePath()
        }
        
        // Save the context as a new UIImage
        let myImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return myImage
    }
    
    // MARK:  in painting
    func applyInPainting() {
        Task {
            if let currentDisplayImage = self.currentDisplayImage {
                DispatchQueue.main.async {
                    self.inPainting.inPaintingInfo = .loading(AppInfo.inPaintingFilterInfo)
                }
                
                let inputImage = currentDisplayImage
                if let mask = maskImage {
                    if let inPaintingBaseImage = await LaMaInpainting.shared.inference(
                        inputImage: inputImage,
                        maskImage: mask,
                        maskBoundary : maskBoundary,
                        expandBorder: self.masking.maskExpand) {
                        DispatchQueue.main.async {
                            self.inPainting.inPaintingBaseImage = inPaintingBaseImage
                            self.inPainting.inPaintingInfo = .empty
                        }
                    }
                    else {
                        DispatchQueue.main.async {
                            self.inPainting.inPaintingInfo = .empty
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.inPainting.inPaintingInfo = .empty
                    }
                }
            }
        }
    }
    
    func finishInPainting() {
        if let image = self.inPainting.inPaintingResultImage {
            self.currentDisplayImage = image
            self.prepareEdgeSAM()
            
            self.inPainting = InPainting()
        }
    }
    
    // MARK: functions
    func write(_ cgimage: CGImage?, to url: URL, isGray:Bool = false) throws {
        if let cgimage = cgimage {
            let cicontext = CIContext()
            let ciimage = CIImage(cgImage: cgimage)
            if isGray {
                try cicontext.writeJPEGRepresentation(of: ciimage, to: url, colorSpace: ciimage.colorSpace!)
            } else {
                try cicontext.writePNGRepresentation(of: ciimage, to: url, format: .RGBA8, colorSpace: ciimage.colorSpace!)
            }
        }
    }
    
    func getContourPath(from image: UIImage?, fromFill: Bool = false) -> CGPath? {
        //let _ = print("image = \(image?.size)")
        if let cgImage = image?.cgImage {
            //try? write(cgImage, to: URL(fileURLWithPath: "/Users/hansoong/Downloads/mask.png"))
            let inputImage = CIImage.init(cgImage: cgImage)
            let filter = CIFilter(name: "CIColorInvert")!
            filter.setValue(inputImage, forKey: kCIInputImageKey)
            if let invertImage = filter.outputImage {
                let contourRequest = VNDetectContoursRequest.init()
                contourRequest.revision = VNDetectContourRequestRevision1
                contourRequest.contrastAdjustment = 1.0
                contourRequest.maximumImageDimension = 512
                let requestHandler = VNImageRequestHandler.init(ciImage: invertImage, options: [:])
                
                try? requestHandler.perform([contourRequest])
                guard let results = contourRequest.results else {
                    return nil
                }
                let finalPath = CGMutablePath()
                
                let vnContours = results.flatMap { contour in
                    (0..<contour.contourCount).compactMap {
                        try? contour.contour(at: $0)
                    }
                }
                var needRedraw = false
                for contour in vnContours {
                    let size = contour.normalizedPath.boundingBox.size
                    if min(size.width, size.height) > 0.01 {
                        finalPath.addPath(contour.normalizedPath)
                    } else {
                        needRedraw = true
                    }
                }
                if needRedraw && (!fromFill) {
                    maskImage = ImageFilter.shared.redraw(pathToImage(finalPath, size: image!.size), image!.size)!
                }
                //let _ = print("image.size = \(maskImage!.size)")
                //try? write(maskImage!.cgImage, to: URL(fileURLWithPath: "/Users/hansoong/Downloads/newMask.png"))
                return finalPath
            }
        }
        return nil
    }
    
    ///Mark undo
    func undoImage() {
        var key = imageCahceKeys.last
        var formatError : Bool = false
        if key != nil {
            /// crop undo mask contain image and mask
            if key!.lastPathComponent.contains(UndoInfo.suffix) {
                if imageCahceKeys.count < 2 {
                    formatError = true
                } else {
                    let keys = Array(imageCahceKeys.suffix(2))
                    
                    if !keys.first!.lastPathComponent.contains(UndoInfo.suffix) {
                        formatError = true
                    }
                    
                    if imageCache.image(for: keys.first!) == nil {
                        formatError = true
                    }
                    
                }
                if !formatError {
                    ///get image and mask
                    if let image = imageCache.image(for: key!) {
                        maskImage = image
                        currentMaskImageBA = getBAMask()
                        imageCache.removeImage(for: key!)
                        imageCahceKeys.removeLast()
                        key = imageCahceKeys.last
                    } else {
                        formatError = true
                    }
                }
            }
            
            if !formatError {
                if let lastKey = key {
                    ///get image only
                    
                    if let image = imageCache.image(for: lastKey) {
                        if image.size == currentDisplayImage?.size {
                            undoImageForALL(image)
                            imageCache.removeImage(for: lastKey)
                            imageCahceKeys.removeLast()
                        } else {
                            undoEnabled = false
                            appState.imageState = .loading(.init(totalUnitCount: 10))
                            DispatchQueue.main.asyncAfter(deadline: .now() + UILayout.DisplayImageDelay) { [self] in
                                undoImageForALL(image)
                                imageCache.removeImage(for: lastKey)
                                imageCahceKeys.removeLast()
                                appState.imageState = .success
                                undoEnabled = true
                                
                            }
                        }
                    } else {
                        formatError = true
                    }
                }
            }
        }
        if formatError {
            imageCache.removeAllImages()
            imageCahceKeys = []
        }
    }
    
    func undoImageForALL(_ image : UIImage) {
        lastFilteringImage = image
        currentDisplayImage = image
        polynomialTransformer!.sourceImage = image
        iconCurrentDisplayImage = currentDisplayImage!.maxLength(to: ViewModel.IconSize)
    }
    
    func processImage() {
        let url = imageCache.generateRandomURLWithLength(length: 10)
        imageCahceKeys.append(url)
        imageCache.insertImage(lastFilteringImage!, for: url)
        lastFilteringImage = currentDisplayImage
        iconCurrentDisplayImage = currentDisplayImage!.maxLength(to: ViewModel.IconSize)
    }
    
    ///private helper
    private func pathToImage(_ path: CGPath, size: CGSize) -> UIImage {
        
        let renderer = UIGraphicsImageRenderer(size: imageSize)

        let img = renderer.image { context in
            let rectangle = CGRect(origin: .zero, size: imageSize)

            context.cgContext.setFillColor(UIColor.black.cgColor)
            context.cgContext.addRect(rectangle)
            context.cgContext.drawPath(using: .fill)
            
            var transform = CGAffineTransform(scaleX:imageSize.width , y: imageSize.height)
                .concatenating(flipped(size: imageSize))
            let drawPath = path.copy(using: &transform)!
            
            context.cgContext.setFillColor(UIColor.white.cgColor)
            context.cgContext.addPath(drawPath)
            context.cgContext.drawPath(using: .fill)
        }
            return img
    }
    
    private func flipped(size: CGSize) -> CGAffineTransform {
        let mirror = CGAffineTransform(scaleX: 1, y: -1)
        let translate = CGAffineTransform(translationX: 0, y: size.height)
        return mirror.concatenating(translate)
    }
}
