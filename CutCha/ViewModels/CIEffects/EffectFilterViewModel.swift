//
//  ColorFilterViewModel_Extension.swift
//  SegmentAnywhere
//
//  Created by hansoong choong on 20/5/24.
//

import Foundation
import SwiftUI
import CoreImage

class EffectFilterViewModel: ObservableObject, FilterModel  {
    
    @Published var panelType : PanelType = .basicPanel
    @Published var currentEffectItem:CIFilterItem = CIFilterItem.noneEffect
    var photoManager : PhotoManager
    
    init(photoManager : PhotoManager) {
        self.photoManager = photoManager
        self.photoManager.effectFilter = self
    }
    
    func reset() {
        currentEffectItem = .noneEffect
    }
    
    func updateDisplayImage() {
        self.photoManager.updateDisplayImage(usingModel: self)
    }
    
    func setEffect(effect : CIFilterEffect) {
        self.currentEffectItem.ciFilterEffect = effect
        updateDisplayImage()        
    }
    
    func getEffectImage(effect: CIFilterEffect, inputImage : UIImage, ciMaskImage: CIImage? = nil) -> UIImage {
        var ciImage : CIImage
        
        let ciInputImage = CIImage(cgImage: inputImage.cgImage!)
        
        switch effect {
            
            //distort
            case .bumpDistort(let position, let radius, let scale):
            ciImage = bumpDistortion(inputImage: ciInputImage, position: position, radius: radius, scale: scale)
            
            case .droste(let positions, let zoom, let periodicity, let strands, let rotation):
            ciImage = droste(inputImage: ciInputImage,
                             positions: positions,
                             zoom: zoom,
                             periodicity:periodicity,
                             strands: strands,
                             rotation:rotation)
            
            case .glassLozenge(let positions, let radius, let refraction):
                ciImage = glassLozenge(inputImage: ciInputImage,
                                          positions: positions, radius: radius, refraction: refraction)
            
            case .holeDistort(let position, let radius):
                ciImage = holeDistortion(inputImage: ciInputImage, position: position, radius: radius)
            
            case .lightTunnel(let position, let radius, let rotation):
                ciImage = lightTunnel(inputImage: ciInputImage, position: position, radius: radius, rotation: rotation)
            
            case .circularWrap(let position, let radius, let angle):
                ciImage = circularWrap(inputImage: ciInputImage, position: position, radius: radius, angle: angle)
            
            case .torusLens(let position, let radius, let refraction, let width):
                    ciImage = torusLens(inputImage: ciInputImage, position: position, radius: radius,
                                        refraction:refraction, width: width)
            
            case .twirlDistort(let position, let radius, let rotation):
                    ciImage = twirlDistort(inputImage: ciInputImage, position: position, radius: radius, rotation: rotation)
            
            //style
            case .bloom(let radius, let intensity):
                ciImage = bloom(inputImage: ciInputImage, radius: radius, intensity: intensity)
                
            case .comicEffect:
                ciImage = comicEffect(inputImage: ciInputImage)
                
            case .crystallize(let position, let radius):
                ciImage = crystalize(inputImage: ciInputImage, position: position, radius: radius)
                
            case .edgeWork(let radius):
                ciImage = edgeWork(inputImage: ciInputImage, radius: radius)
                
            case .edges(let intensity):
                ciImage = edges(inputImage: ciInputImage, intensity: intensity)
                
            case .gaborGradients:
                ciImage = garborGradients(inputImage: ciInputImage)
                
            case .gloom(let radius, let intensity):
                ciImage = gloom(inputImage: ciInputImage, radius: radius, intensity: intensity)
                
            case .heightFieldFromMask(let radius):
                ciImage = heightFieldFromMask(inputImage: ciInputImage, radius: radius)
                
            case .hexagonalPixellate(let position, let scale):
                ciImage = hexagonalPixellate(inputImage: ciInputImage, position: position, scale: scale)
                
            case .highlightShadowAdjust(let shadowRadius, let shadowAmount):
                ciImage = highlightShadowAdjust(inputImage: ciInputImage, shadowRadius: shadowRadius,
                                                shadowAmount: shadowAmount)
            case .pixellate(let position, let scale):
                ciImage = pixellate(inputImage: ciInputImage, position: position, scale: scale)
                
            case .pointillize(let position, let radius):
                ciImage = pointillize(inputImage: ciInputImage, position: position, radius: radius)
                
            case .sobelGradients:
                ciImage = sobelGradients(inputImage: ciInputImage)
            
            //blur
            case .bokehBlur(let radius, let ringSize, let ringAmount):
                ciImage = bokehBlur(inputImage: ciInputImage, radius: radius, ringSize: ringSize, ringAmount: ringAmount)
            
            case .gaussianBlur(let radius):
            if let maskImage = ciMaskImage {
                ciImage = maskedVariableBlur(inputImage: ciInputImage, maskImage: maskImage, radius: radius)
            } else {
                ciImage = gaussianBlur(inputImage: ciInputImage, radius: radius)
            }
            
            case .zoomBlur(let postion, let amount):
                ciImage = zoomBlur(inputImage: ciInputImage, position: postion, amount: amount)
                
            case .motionBlur(let radius, let angle):
                ciImage = motionBlur(inputImage: ciInputImage, radius: radius, angle: angle)
                
            case .morphologyRectangleMinimum(let width, let height):
                ciImage = morphologyRectangleMinimum(inputImage: ciInputImage, width: width, height: height)
                
            case .morphologyRectangleMaximum(let width, let height):
                ciImage = morphologyRectangleMaximum(inputImage: ciInputImage, width: width, height: height)
                
            case .morphologyMinimum(let radius):
                ciImage = morphologyMinimum(inputImage: ciInputImage, radius: radius)
                
            case .morphologyMaximum(let radius):
                ciImage = morphologyMaximum(inputImage: ciInputImage, radius: radius)
                
            case .morphologyGradient(let radius):
                ciImage = morphologyGradient(inputImage: ciInputImage, radius: radius)
                
            case .discBlur(let radius):
                ciImage = discBlur(inputImage: ciInputImage, radius: radius)
                
            case .boxBlur(let radius):
                ciImage = boxBlur(inputImage: ciInputImage, radius: radius)
            
            
            //tile
            case .affineClamp(let width, let angle, let position):
                ciImage = affineClamp(inputImage: ciInputImage,
                                      width: width, angle: angle, position: position)
            case .affineTile(let width, let angle, let position):
                ciImage = affineTile(inputImage: ciInputImage,
                                      width: width, angle: angle, position: position)
            
        case .twelvefoldReflectedTile(let width, let angle, let position):
            ciImage = twelvefoldReflectedTile(inputImage: ciInputImage,
                                         width: width, angle: angle, position: position)
        case .eightfoldReflectedTile(let width, let angle, let position):
            ciImage = eightfoldReflectedTile(inputImage: ciInputImage,
                                         width: width, angle: angle, position: position)
        case .sixfoldReflectedTile(let width, let angle, let position):
            ciImage = sixfoldReflectedTile(inputImage: ciInputImage,
                                         width: width, angle: angle, position: position)
            
        case .fourfoldReflectedTile(let width, let angle, let position):
            ciImage = fourfoldReflectedTile(inputImage: ciInputImage,
                                         width: width, angle: angle, position: position)
        
        case .sixfoldRotatedTile(let width, let angle, let position):
            ciImage = sixfoldRotatedTile(inputImage: ciInputImage,
                                         width: width, angle: angle, position: position)
            
        case .fourfoldRotatedTile(let width, let angle, let position):
            ciImage = fourfoldRotatedTile(inputImage: ciInputImage,
                                         width: width, angle: angle, position: position)
            
        case .fourfoldTranslatedTile(let width, let angle, let acuteAngle, let position):
            ciImage = fourfoldTranslatedTile(inputImage: ciInputImage,
                                             width: width, angle: angle, acuteAngle: acuteAngle,
                                             position: position)
            
        case .glideReflectedTile(let width, let angle, let position):
            ciImage = glideReflectedTile(inputImage: ciInputImage,
                                         width: width, angle: angle, position: position)
            
        case .parallelogramTile(let width, let angle, let acuteAngle, let position):
            ciImage = parallelogramTile(inputImage: ciInputImage,
                                             width: width, angle: angle, acuteAngle: acuteAngle,
                                             position: position)
            
        case .kaleidoscope(let count, let angle, let position):
            ciImage = kaleidoscope(inputImage: ciInputImage,
                                         count: count, angle: angle, position: position)
        
        case .triangleTile(let width, let angle, let position):
            ciImage = triangleTile(inputImage: ciInputImage,
                                         width: width, angle: angle, position: position)
            
        case .triangleKaleidoscope(let width, let angle, let decay, let position):
            ciImage = triangleKaleidoscope(inputImage: ciInputImage,
                                           width: width, decay: decay, angle: angle, position: position)
            
        case .opTile(let width, let scale, let angle, let position):
            ciImage = opTile(inputImage: ciInputImage,
                             width: width, scale: scale, angle: angle,
                                             position: position)
        
        case .perspectiveTile(let positions):
            ciImage = perspectiveTile(inputImage: ciInputImage, positions: positions)
            
            //color
            case .lightControls(let exposure, let brightness, let contrast, let gamma):
                    ciImage = lightControls(inputImage: ciInputImage,
                                            exposure: exposure,
                                            brightness: brightness,
                                            contrast: contrast,
                                            gamma: gamma)
            case .colorControls(let hue, let saturation, let temperature):
                    ciImage = colorControls(inputImage: ciInputImage,
                                            hue: hue,
                                            saturation: saturation,
                                            temperature: temperature)
            case .detailsControl(let radius, let sharpness, let noiseReduction):
                ciImage = detailsFilter(inputImage: ciInputImage, radius: radius, sharpness: sharpness, noiseReduction: noiseReduction)
                
            case .vignetteEffect(let position, let radius, let intensity, let fallOff):
                ciImage = vignetteEffect(inputImage: ciInputImage, position: position,
                                         radius: radius, intensity: intensity, fallOff: fallOff)
            default:
                return inputImage
        }
        if let cgImage = ciImage.convertCIImageToCGImage() {
            return UIImage(cgImage: cgImage).resized(to: inputImage.size)
        }
        return inputImage
    }
    ///distort
    func bumpDistortion(inputImage: CIImage, position: CGPoint, radius: Double, scale: Double) -> CIImage {
        let filter = CIFilter.bumpDistortion()
        filter.inputImage = inputImage
        filter.center = .init(x: inputImage.extent.width * position.x,
                              y: inputImage.extent.height * (1 - position.y))
        filter.radius = Float(radius)
        filter.scale = Float(scale)
        return filter.outputImage!.cropped(to: inputImage.extent)
    }
    
    func droste(inputImage: CIImage, positions: [CGPoint], zoom: Double, 
                periodicity: Double, strands: Double, rotation:Double) -> CIImage {
        let filter = CIFilter.droste()
        filter.inputImage = inputImage
        filter.insetPoint1 = CGPoint(
            x: inputImage.extent.size.width * minMax(minValue: 0.05, maxValue: 0.95, value: positions[0].x),
            y: inputImage.extent.size.height * (1 - minMax(minValue: 0.05, maxValue: 0.95, value: positions[0].y))
        )
        filter.insetPoint0 = CGPoint(
            x: inputImage.extent.size.width * minMax(minValue: 0.05, maxValue: 0.95, value: positions[1].x),
            y: inputImage.extent.size.height * (1 - minMax(minValue: 0.05, maxValue: 0.95, value: positions[1].y))
        )
        filter.periodicity = Float(periodicity)
        filter.rotation = Float(Angle.degrees(rotation).radians)
        filter.strands = Float(strands)
        filter.zoom = Float(zoom)
        return filter.outputImage!.cropped(to: inputImage.extent)
    }
    
    func glassLozenge(inputImage: CIImage,positions: [CGPoint],
                      radius: Double, refraction: Double) -> CIImage {
        let filter = CIFilter.glassLozenge()
        filter.inputImage = inputImage
        filter.point0 = CGPoint(
            x: inputImage.extent.size.width * minMax(minValue: 0.05, maxValue: 0.95, value: positions[0].x),
            y: inputImage.extent.size.height * (1 - minMax(minValue: 0.05, maxValue: 0.95, value: positions[0].y))
        )
        filter.point1 = CGPoint(
            x: inputImage.extent.size.width * minMax(minValue: 0.05, maxValue: 0.95, value: positions[1].x),
            y: inputImage.extent.size.height * (1 - minMax(minValue: 0.05, maxValue: 0.95, value: positions[1].y))
        )
        filter.radius = Float(radius)
        filter.refraction = Float(refraction)
        return filter.outputImage!.cropped(to: inputImage.extent)
    }
    
    func holeDistortion(inputImage: CIImage, position: CGPoint, radius: Double) -> CIImage {
        let filter = CIFilter.holeDistortion()
        filter.inputImage = inputImage
        filter.center = .init(x: inputImage.extent.width * position.x,
                              y: inputImage.extent.height * (1 - position.y))
        filter.radius = Float(radius)
        
        return filter.outputImage!.cropped(to: inputImage.extent)
    }
    
    func lightTunnel(inputImage: CIImage, position: CGPoint, radius: Double, rotation: Double) -> CIImage {
        let filter = CIFilter.lightTunnel()
        filter.inputImage = inputImage
        filter.center = .init(x: inputImage.extent.width * position.x,
                               y: inputImage.extent.height * (1 - position.y))
        filter.radius = Float(radius)
        filter.rotation = Float(Angle.degrees(rotation).radians)
        
        return filter.outputImage!.cropped(to: inputImage.extent)
    }
    
    func circularWrap(inputImage: CIImage, position: CGPoint, radius: Double, angle: Double) -> CIImage {
        let filter = CIFilter.circularWrap()
        filter.inputImage = inputImage
        filter.center = .init(x: inputImage.extent.width * position.x,
                              y: inputImage.extent.height * (1 - position.y))
        filter.angle = Float(Angle.degrees(angle).radians)
        filter.radius = Float(radius)
        return filter.outputImage!
    }
    
    func torusLens(inputImage: CIImage, position: CGPoint, radius: Double, refraction: Double, width: Double) -> CIImage {
        let filter = CIFilter.torusLensDistortion()
        filter.inputImage = inputImage
        filter.center = .init(x: inputImage.extent.width * position.x,
                               y: inputImage.extent.height * (1 - position.y))
        filter.radius = Float(radius)
        filter.refraction = Float(refraction)
        filter.width = Float(width)
        return filter.outputImage!.cropped(to: inputImage.extent)
    }
    
    func twirlDistort(inputImage: CIImage, position: CGPoint, radius: Double, rotation: Double) -> CIImage {
        let filter = CIFilter.twirlDistortion()
        filter.inputImage = inputImage
        filter.center = .init(x: inputImage.extent.width * position.x,
                               y: inputImage.extent.height * (1 - position.y))
        filter.radius = Float(radius)
        filter.angle = Float(Angle.degrees(rotation).radians)
        return filter.outputImage!.cropped(to: inputImage.extent)
    }
}

enum PanelType {
    case basicPanel
    case morePanel
}
