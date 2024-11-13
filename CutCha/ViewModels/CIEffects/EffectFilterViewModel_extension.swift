//
//  EffectFilterViewModel_extension.swift
//  SegmentAnywhere
//
//  Created by hansoong choong on 23/5/24.
//

import SwiftUI
import CoreML
import CoreImage

extension EffectFilterViewModel {
    
    //style
    func bloom(inputImage: CIImage, radius: Double, intensity : Double) -> CIImage {
        let bloomFilter = CIFilter.bloom()
        bloomFilter.inputImage = inputImage
        bloomFilter.radius = Float(radius)
        bloomFilter.intensity = Float(intensity)
        return bloomFilter.outputImage!.cropped(to: inputImage.extent)
    }
    
    func comicEffect(inputImage: CIImage) -> CIImage {
        let comicEffectFilter = CIFilter.comicEffect()
        comicEffectFilter.inputImage = inputImage
        return comicEffectFilter.outputImage!.cropped(to: inputImage.extent)
    }
    
    func crystalize(inputImage: CIImage, position: CGPoint, radius: Double) -> CIImage {
        let filter = CIFilter.crystallize()
        filter.inputImage = inputImage
        
        filter.center = .init(x: inputImage.extent.width * position.x,
                              y: inputImage.extent.height * (1 - position.y))
        filter.radius = Float(radius)
        
        return filter.outputImage!.cropped(to: inputImage.extent)
    }
    
    func edges(inputImage: CIImage, intensity: Double) -> CIImage {
        let filter = CIFilter.edges()
        filter.inputImage = inputImage
        filter.intensity = Float(intensity)
        return filter.outputImage!.cropped(to: inputImage.extent)
    }
    
    func edgeWork(inputImage: CIImage, radius: Double) -> CIImage {
        let filter = CIFilter.edgeWork()
        filter.inputImage = inputImage
        filter.radius = Float(radius)
        return filter.outputImage!.cropped(to: inputImage.extent)
    }
    
    func garborGradients(inputImage: CIImage) -> CIImage {
        let filter = CIFilter.gaborGradients()
        filter.inputImage = inputImage
        return filter.outputImage!.cropped(to: inputImage.extent)
    }
    
    func gloom(inputImage: CIImage, radius: Double, intensity : Double) -> CIImage {
        let filter = CIFilter.gloom()
        filter.inputImage = inputImage
        filter.radius = Float(radius)
        filter.intensity = Float(intensity)
        return filter.outputImage!.cropped(to: inputImage.extent)
    }
    
    func heightFieldFromMask(inputImage: CIImage, radius: Double) -> CIImage {
        let filter = CIFilter.heightFieldFromMask()
        filter.inputImage = inputImage
        filter.radius = Float(radius)
        return filter.outputImage!.cropped(to: inputImage.extent)
    }
    
    func hexagonalPixellate (inputImage: CIImage, position: CGPoint, scale: Double) -> CIImage {
        let filter = CIFilter.hexagonalPixellate()
        filter.inputImage = inputImage
        filter.center = .init(x: inputImage.extent.width * position.x,
                              y: inputImage.extent.height * (1 - position.y))
        filter.scale = Float(scale)
        return filter.outputImage!.cropped(to: inputImage.extent)
    }
    
    func highlightShadowAdjust(inputImage: CIImage, shadowRadius: Double, shadowAmount: Double) -> CIImage {
        let filter = CIFilter.highlightShadowAdjust()
        filter.inputImage = inputImage
        filter.radius = Float(shadowRadius)
        filter.shadowAmount = Float(shadowAmount)
        return filter.outputImage!.cropped(to: inputImage.extent)
    }
    
    func lineOverlay(inputImage: CIImage, nrNoiseLevel: Double, nrSharpness: Double,
                     edgeIntensity: Double, threshold: Double, contrast: Double) -> CIImage {
        let filter = CIFilter.lineOverlay()
        filter.inputImage = inputImage
        filter.nrNoiseLevel = Float(nrNoiseLevel)
        filter.nrSharpness = Float(nrSharpness)
        filter.edgeIntensity = Float(edgeIntensity)
        filter.threshold = Float(threshold)
        filter.contrast = Float(contrast)
        return filter.outputImage!.cropped(to: inputImage.extent)
    }
    
    func pixellate(inputImage: CIImage, position: CGPoint, scale: Double) -> CIImage {
        let filter = CIFilter.pixellate()
        filter.inputImage = inputImage
        filter.center = .init(x: inputImage.extent.width * position.x,
                              y: inputImage.extent.height * (1 - position.y))
        filter.scale = Float(scale)
        return filter.outputImage!.cropped(to: inputImage.extent)
    }
    
    func pointillize(inputImage: CIImage, position: CGPoint, radius: Double) -> CIImage {
        let filter = CIFilter.pointillize()
        filter.inputImage = inputImage
        filter.center = .init(x: inputImage.extent.width * position.x,
                              y: inputImage.extent.height * (1 - position.y))
        filter.radius = Float(radius)
        return filter.outputImage!.cropped(to: inputImage.extent)
    }
    
    func sobelGradients(inputImage: CIImage) -> CIImage {
        let sobel = CIFilter.sobelGradients()
        sobel.inputImage = inputImage
        return sobel.outputImage!.cropped(to: inputImage.extent)
    }
}

extension EffectFilterViewModel {
    ///blur
    func bokehBlur(inputImage: CIImage, radius: Double, ringSize : Double, ringAmount: Double) -> CIImage {
        let bokehBlurFilter = CIFilter.bokehBlur()
        bokehBlurFilter.inputImage = inputImage
        bokehBlurFilter.ringSize = Float(ringSize)
        bokehBlurFilter.ringAmount = Float(ringAmount)
        bokehBlurFilter.softness = 1
        bokehBlurFilter.radius = Float(radius)
        return bokehBlurFilter.outputImage!.cropped(to: inputImage.extent)
    }
    
    func gaussianBlur(inputImage: CIImage, radius: Double) -> CIImage {
        let gaussianBlurFilter = CIFilter.gaussianBlur()
        gaussianBlurFilter.inputImage = inputImage
        gaussianBlurFilter.radius = Float(radius)
        return gaussianBlurFilter.outputImage!.cropped(to: inputImage.extent)
    }
    
    func maskedVariableBlur(inputImage: CIImage, maskImage: CIImage, radius: Double) -> CIImage {
        let filter = CIFilter.maskedVariableBlur()
        filter.inputImage = inputImage
        filter.mask = maskImage
        filter.radius = Float(radius)
        return filter.outputImage!.cropped(to: inputImage.extent)
    }
    
    func boxBlur(inputImage: CIImage, radius : Double) -> CIImage {
        let boxBlurFilter = CIFilter.boxBlur()
        boxBlurFilter.inputImage = inputImage
        boxBlurFilter.radius = Float(radius)
        return boxBlurFilter.outputImage!.cropped(to: inputImage.extent)
    }
    
    func discBlur(inputImage: CIImage, radius : Double) -> CIImage {
        let discBlurFilter = CIFilter.discBlur()
        discBlurFilter.inputImage = inputImage
        discBlurFilter.radius = Float(radius)
        return discBlurFilter.outputImage!.cropped(to: inputImage.extent)
    }
    
//    func medianBlur(inputImage: CIImage) -> CIImage {
//        let medianBlurFilter = CIFilter.median()
//        medianBlurFilter.inputImage = inputImage
//        return medianBlurFilter.outputImage!.cropped(to: inputImage.extent)
//    }
    
    func morphologyGradient(inputImage: CIImage, radius: Double) -> CIImage {
        let morphologyGradientFilter = CIFilter.morphologyGradient()
        morphologyGradientFilter.inputImage = inputImage
        morphologyGradientFilter.radius = Float(radius)
        return morphologyGradientFilter.outputImage!.cropped(to: inputImage.extent)
    }
    
    func morphologyMaximum(inputImage: CIImage, radius: Double) -> CIImage {
        let morphologyMaximumFilter = CIFilter.morphologyMaximum()
        morphologyMaximumFilter.inputImage = inputImage
        morphologyMaximumFilter.radius = Float(radius)
        return morphologyMaximumFilter.outputImage!.cropped(to: inputImage.extent)
    }
    
    func morphologyMinimum(inputImage: CIImage, radius: Double) -> CIImage {
        let morphologyMinimumFilter = CIFilter.morphologyMinimum()
        morphologyMinimumFilter.inputImage = inputImage
        morphologyMinimumFilter.radius = Float(radius)
        return morphologyMinimumFilter.outputImage!.cropped(to: inputImage.extent)
    }
    
    func morphologyRectangleMaximum(inputImage: CIImage, width: Double, height: Double) -> CIImage {
        let morphologyRectangleMaximumFilter = CIFilter.morphologyRectangleMaximum()
        morphologyRectangleMaximumFilter.inputImage = inputImage
        morphologyRectangleMaximumFilter.width = Float(width)
        morphologyRectangleMaximumFilter.height = Float(height)
        return morphologyRectangleMaximumFilter.outputImage!.cropped(to: inputImage.extent)
    }
    
    func morphologyRectangleMinimum(inputImage: CIImage, width: Double, height: Double) -> CIImage {
        let morphologyRectangleMinimumFilter = CIFilter.morphologyRectangleMinimum()
        morphologyRectangleMinimumFilter.inputImage = inputImage
        morphologyRectangleMinimumFilter.width = Float(width)
        morphologyRectangleMinimumFilter.height = Float(height)
        return morphologyRectangleMinimumFilter.outputImage!.cropped(to: inputImage.extent)
    }
    
    func motionBlur(inputImage: CIImage, radius: Double, angle: Double) -> CIImage {
        let motionBlurFilter = CIFilter.motionBlur()
        motionBlurFilter.inputImage = inputImage
        motionBlurFilter.angle = Float(Angle.degrees(angle).radians)
        motionBlurFilter.radius = Float(radius)
        return motionBlurFilter.outputImage!.cropped(to: inputImage.extent)
    }
    
    func noiseReduction(inputImage: CIImage, noiseLevel: Double, sharpness: Double) -> CIImage {
        let noiseReductionfilter = CIFilter.noiseReduction()
        noiseReductionfilter.inputImage = inputImage
        noiseReductionfilter.noiseLevel = Float(noiseLevel)
        noiseReductionfilter.sharpness = Float(sharpness)
        return noiseReductionfilter.outputImage!.cropped(to: inputImage.extent)
    }
    
    func zoomBlur(inputImage: CIImage, position: CGPoint, amount: Double) -> CIImage {
        let zoomBlurFilter = CIFilter.zoomBlur()
        zoomBlurFilter.inputImage = inputImage
        zoomBlurFilter.amount = Float(amount)
        zoomBlurFilter.center = .init(x: inputImage.extent.width * position.x,
                                      y: inputImage.extent.height * (1 - position.y))
        return zoomBlurFilter.outputImage!.cropped(to: inputImage.extent)
    }
    
}


extension EffectFilterViewModel {
    ///color
    func lightControls(inputImage: CIImage, exposure: Double, brightness: Double, contrast: Double, gamma: Double) -> CIImage {
        
        let colorControlsFilter = CIFilter.colorControls()
        colorControlsFilter.inputImage = inputImage
        colorControlsFilter.brightness = Float(brightness)
        colorControlsFilter.contrast = Float(contrast)
        
        let exposureAdjustFilter = CIFilter.exposureAdjust()
        exposureAdjustFilter.inputImage = colorControlsFilter.outputImage!
        exposureAdjustFilter.ev = Float(exposure)
        
        return gammaAdjust(inputImage: exposureAdjustFilter.outputImage!, power: gamma)
    }
    
    func colorControls(inputImage: CIImage, hue: Double,saturation: Double, temperature: Double) -> CIImage {

        let hueImage = hueAdjust(inputImage: inputImage, angle: hue)
        
        let colorControlsFilter = CIFilter.colorControls()
        colorControlsFilter.inputImage = hueImage
        colorControlsFilter.saturation = Float(saturation)
        return tempatureAndTint(inputImage: colorControlsFilter.outputImage!, temperatureAdd: temperature)
    }
    
    func detailsFilter(inputImage: CIImage, radius: Double, sharpness : Double, noiseReduction: Double) -> CIImage {
        let sharpeneseImage = sharpenLuminance(inputImage: inputImage, radius: radius, sharpness: sharpness)
        let noiseReductionfilter = CIFilter.noiseReduction()
        noiseReductionfilter.inputImage = sharpeneseImage
        noiseReductionfilter.noiseLevel = Float(noiseReduction)
        return noiseReductionfilter.outputImage!.cropped(to: inputImage.extent)
    }
    
    func sharpenLuminance(inputImage: CIImage, radius: Double, sharpness : Double) -> CIImage {
        let sharpenLuminance = CIFilter.sharpenLuminance()
        sharpenLuminance.inputImage = inputImage
        sharpenLuminance.radius = Float(radius)
        sharpenLuminance.sharpness = Float(sharpness)
        return sharpenLuminance.outputImage!.cropped(to: inputImage.extent)
    }
    
    func vignetteEffect(inputImage: CIImage, position: CGPoint,
                        radius: Double, intensity: Double, fallOff : Double) -> CIImage {
        let vignetteFilter = CIFilter.vignetteEffect()
        vignetteFilter.inputImage = inputImage
        vignetteFilter.intensity = Float(intensity)
        vignetteFilter.radius = Float(radius)
        vignetteFilter.falloff = Float(fallOff)
        vignetteFilter.center = .init(x: inputImage.extent.width * position.x,
                                     y: inputImage.extent.height * (1 - position.y))
        return vignetteFilter.outputImage!.cropped(to: inputImage.extent)
    }
    
    func tempatureAndTint(inputImage: CIImage, temperatureAdd: Double) -> CIImage {
        let tempatureAndTintFilter = CIFilter.temperatureAndTint()
        tempatureAndTintFilter.inputImage = inputImage
        tempatureAndTintFilter.neutral = CIVector(x: 6500 + temperatureAdd, y: 0)
        tempatureAndTintFilter.targetNeutral = CIVector(x: 6500, y: 0)
        return tempatureAndTintFilter.outputImage!.cropped(to: inputImage.extent)
    }
    
    func gammaAdjust(inputImage: CIImage, power: Double) -> CIImage {
        let gammaAdjustFilter = CIFilter.gammaAdjust()
        gammaAdjustFilter.inputImage = inputImage
        gammaAdjustFilter.power = Float(power)
        return gammaAdjustFilter.outputImage!.cropped(to: inputImage.extent)
    }
    
    func hueAdjust(inputImage: CIImage, angle: Double) -> CIImage {
        let hueAdjustFilter = CIFilter.hueAdjust()
        hueAdjustFilter.inputImage = inputImage
        hueAdjustFilter.angle = Float(Angle.degrees(angle).radians)
        return hueAdjustFilter.outputImage!.cropped(to: inputImage.extent)
    }
}

extension EffectFilterViewModel {
    func affineClamp(inputImage: CIImage, width: Double, angle:Double, position: CGPoint) -> CIImage {
        let cropRect = cropRect(inputImage: inputImage, size: width, position: position)
        let cropImage = inputImage.cropped(to: cropRect)
        let rad = Angle(degrees: angle).radians
        let affineClamp = CIFilter.affineClamp()
        affineClamp.inputImage = cropImage
        affineClamp.transform = CGAffineTransform(a: cos(rad),
                                                  b: -sin(rad), c: sin(rad),
                                                  d: cos(rad), tx: 0.0, ty: 0.0)
        return affineClamp.outputImage!.cropped(to: inputImage.extent)
    }
    
    func affineTile(inputImage: CIImage, width: Double, angle:Double, position: CGPoint) -> CIImage {
        let cropRect = cropRect(inputImage: inputImage, size: width, position: position)
        let cropImage = inputImage.cropped(to: cropRect)
        let rad = Angle(degrees: angle).radians
        let affineTile = CIFilter.affineTile()
        affineTile.inputImage = cropImage
        affineTile.transform = CGAffineTransform(a: cos(rad),
                                                  b: -sin(rad), c: sin(rad),
                                                  d: cos(rad), tx: 0.0, ty: 0.0)
        return affineTile.outputImage!.cropped(to: inputImage.extent)
    }
    
    func twelvefoldReflectedTile(inputImage: CIImage, width: Double, angle:Double, position: CGPoint) -> CIImage {
        let twelvefoldReflectedTile = CIFilter.twelvefoldReflectedTile()
        twelvefoldReflectedTile.inputImage = inputImage
        twelvefoldReflectedTile.center = CGPoint(x: position.x * inputImage.extent.width,
                                                y: (1 - position.y) * inputImage.extent.height)
        twelvefoldReflectedTile.width = Float(width)
        twelvefoldReflectedTile.angle = Float(Angle(degrees: angle).radians)
        return twelvefoldReflectedTile.outputImage!.cropped(to: inputImage.extent)
    }
    
    func eightfoldReflectedTile(inputImage: CIImage, width: Double, angle:Double, position: CGPoint) -> CIImage {
        let eightFoldReflectedTile = CIFilter.eightfoldReflectedTile()
        eightFoldReflectedTile.inputImage = inputImage
        eightFoldReflectedTile.center = CGPoint(x: position.x * inputImage.extent.width,
                                                y: (1 - position.y) * inputImage.extent.height)
        eightFoldReflectedTile.width = Float(width)
        eightFoldReflectedTile.angle = Float(Angle(degrees: angle).radians)
        return eightFoldReflectedTile.outputImage!.cropped(to: inputImage.extent)
    }
    
    func sixfoldReflectedTile(inputImage: CIImage, width: Double, angle:Double, position: CGPoint) -> CIImage {
        let sixfoldReflectedTile = CIFilter.sixfoldReflectedTile()
        sixfoldReflectedTile.inputImage = inputImage
        sixfoldReflectedTile.center = CGPoint(x: position.x * inputImage.extent.width,
                                                y: (1 - position.y) * inputImage.extent.height)
        sixfoldReflectedTile.width = Float(width)
        sixfoldReflectedTile.angle = Float(Angle(degrees: angle).radians)
        return safeOutputImage(outputImage: sixfoldReflectedTile.outputImage, inputImage: inputImage)
    }
    
    func fourfoldReflectedTile(inputImage: CIImage, width: Double, angle:Double, position: CGPoint) -> CIImage {
        let fourFoldReflectedTile = CIFilter.fourfoldReflectedTile()
        fourFoldReflectedTile.inputImage = inputImage
        fourFoldReflectedTile.center = CGPoint(x: position.x * inputImage.extent.width,
                                                y: (1 - position.y) * inputImage.extent.height)
        fourFoldReflectedTile.width = Float(width)
        fourFoldReflectedTile.angle = Float(Angle(degrees: angle).radians)
        return fourFoldReflectedTile.outputImage!.cropped(to: inputImage.extent)
    }
    
    func sixfoldRotatedTile(inputImage: CIImage, width: Double, angle:Double, position: CGPoint) -> CIImage {
        let sixfoldRotatedTile = CIFilter.sixfoldRotatedTile()
        sixfoldRotatedTile.inputImage = inputImage
        sixfoldRotatedTile.center = CGPoint(x: position.x * inputImage.extent.width,
                                                y: (1 - position.y) * inputImage.extent.height)
        sixfoldRotatedTile.width = Float(width)
        sixfoldRotatedTile.angle = Float(Angle(degrees: angle).radians)
        return sixfoldRotatedTile.outputImage!.cropped(to: inputImage.extent)
    }
    
    func fourfoldRotatedTile(inputImage: CIImage, width: Double, angle:Double, position: CGPoint) -> CIImage {
        let fourfoldRotatedTile = CIFilter.fourfoldRotatedTile()
        fourfoldRotatedTile.inputImage = inputImage
        fourfoldRotatedTile.center = CGPoint(x: position.x * inputImage.extent.width,
                                                y: (1 - position.y) * inputImage.extent.height)
        fourfoldRotatedTile.width = Float(width)
        fourfoldRotatedTile.angle = Float(Angle(degrees: angle).radians)
        return fourfoldRotatedTile.outputImage!.cropped(to: inputImage.extent)
    }
    
    func fourfoldTranslatedTile(inputImage: CIImage, width: Double, angle:Double, acuteAngle: Double,
                                position: CGPoint) -> CIImage {
        let fourfoldTranslatedTile = CIFilter.fourfoldTranslatedTile()
        fourfoldTranslatedTile.inputImage = inputImage
        fourfoldTranslatedTile.center = CGPoint(x: position.x * inputImage.extent.width,
                                                y: (1 - position.y) * inputImage.extent.height)
        fourfoldTranslatedTile.width = Float(width)
        fourfoldTranslatedTile.angle = Float(Angle(degrees: angle).radians)
        fourfoldTranslatedTile.acuteAngle = Float(Angle(degrees: acuteAngle).radians)
        return fourfoldTranslatedTile.outputImage!.cropped(to: inputImage.extent)
    }
    
    func glideReflectedTile(inputImage: CIImage, width: Double, angle:Double, position: CGPoint) -> CIImage {
        let glideReflectedTile = CIFilter.glideReflectedTile()
        glideReflectedTile.inputImage = inputImage
        glideReflectedTile.center = CGPoint(x: position.x * inputImage.extent.width,
                                                y: (1 - position.y) * inputImage.extent.height)
        glideReflectedTile.width = Float(width)
        glideReflectedTile.angle = Float(Angle(degrees: angle).radians)
        return glideReflectedTile.outputImage!.cropped(to: inputImage.extent)
    }
    
    func kaleidoscope(inputImage: CIImage, count: Double, angle:Double, position: CGPoint) -> CIImage {
        let kaleidoscope = CIFilter.kaleidoscope()
        kaleidoscope.inputImage = inputImage
        kaleidoscope.center = CGPoint(x: position.x * inputImage.extent.width,
                                                y: (1 - position.y) * inputImage.extent.height)
        kaleidoscope.count = Int(count)
        kaleidoscope.angle = Float(Angle(degrees: angle).radians)
        return kaleidoscope.outputImage!.cropped(to: inputImage.extent)
    }
    
    func triangleTile(inputImage: CIImage, width: Double, angle:Double, position: CGPoint) -> CIImage {
        let triangleTile = CIFilter.triangleTile()
        triangleTile.inputImage = inputImage
        triangleTile.center = CGPoint(x: position.x * inputImage.extent.width,
                                                y: (1 - position.y) * inputImage.extent.height)
        triangleTile.width = Float(width)
        triangleTile.angle = Float(Angle(degrees: angle).radians)
        return triangleTile.outputImage!.cropped(to: inputImage.extent)
    }
    
    func triangleKaleidoscope(inputImage: CIImage, width: Double, decay: Double,
                              angle:Double, position: CGPoint) -> CIImage {
        let triangleKaleidoscope = CIFilter.triangleKaleidoscope()
        triangleKaleidoscope.inputImage = inputImage
        triangleKaleidoscope.point = CGPoint(x: position.x * inputImage.extent.width,
                                                y: (1 - position.y) * inputImage.extent.height)
        triangleKaleidoscope.size = Float(width)
        triangleKaleidoscope.decay = Float(decay)
        triangleKaleidoscope.rotation = Float(Angle(degrees: angle).radians)
        return triangleKaleidoscope.outputImage!.cropped(to: inputImage.extent)
    }
    
    func opTile(inputImage: CIImage, width: Double, scale: Double, angle:Double, position: CGPoint) -> CIImage {
        let opTile = CIFilter.opTile()
        opTile.inputImage = inputImage
        opTile.center = CGPoint(x: position.x * inputImage.extent.width,
                                                y: (1 - position.y) * inputImage.extent.height)
        opTile.width = Float(width)
        opTile.scale = Float(scale)
        opTile.angle = Float(Angle(degrees: angle).radians)
        return opTile.outputImage!.cropped(to: inputImage.extent)
    }
    
    func parallelogramTile(inputImage: CIImage, width: Double, angle:Double, acuteAngle: Double,
                                position: CGPoint) -> CIImage {
        let parallelogramTile = CIFilter.parallelogramTile()
        parallelogramTile.inputImage = inputImage
        parallelogramTile.center = CGPoint(x: position.x * inputImage.extent.width,
                                                y: (1 - position.y) * inputImage.extent.height)
        parallelogramTile.width = Float(width)
        parallelogramTile.angle = Float(Angle(degrees: angle).radians)
        parallelogramTile.acuteAngle = Float(Angle(degrees: acuteAngle).radians)
        return parallelogramTile.outputImage!.cropped(to: inputImage.extent)
    }
    
    func perspectiveTile(inputImage: CIImage, positions: [CGPoint]) -> CIImage {
        if positions.count != 4 { return inputImage }
        let perspectiveTile = CIFilter.perspectiveTile()
        perspectiveTile.inputImage = inputImage
        perspectiveTile.topLeft = CGPoint(x: positions[0].x * inputImage.extent.width,
                                                y: (1 - positions[0].y) * inputImage.extent.height)
        perspectiveTile.topRight = CGPoint(x: positions[1].x * inputImage.extent.width,
                                                y: (1 - positions[1].y) * inputImage.extent.height)
        perspectiveTile.bottomLeft = CGPoint(x: positions[2].x * inputImage.extent.width,
                                                y: (1 - positions[2].y) * inputImage.extent.height)
        perspectiveTile.bottomRight = CGPoint(x: positions[3].x * inputImage.extent.width,
                                                y: (1 - positions[3].y) * inputImage.extent.height)
        return perspectiveTile.outputImage!.cropped(to: inputImage.extent)
    }
    
    func safeOutputImage(outputImage: CIImage?, inputImage: CIImage) -> CIImage {
        if outputImage == nil { return inputImage }
        return outputImage!.cropped(to: inputImage.extent)
    }
    
    func cropRect(inputImage: CIImage, size: Double, position: CGPoint) -> CGRect {
        let center = CGPoint(x: position.x * inputImage.extent.width, 
                             y: (1 - position.y) * inputImage.extent.height)
        return CGRect(center: center, size: CGSize(width: size, height: size))
            .intersection(inputImage.extent)
    }
}
