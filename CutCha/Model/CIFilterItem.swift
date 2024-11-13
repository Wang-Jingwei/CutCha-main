//
//  EffectItem.swift
//  SegmentAnywhere
//
//  Created by hansoong choong on 20/5/24.
//

import Foundation
import SwiftUI

public struct EffectConstants {
    
    ///basic filter
    static let supportFilters:[CIFilterItem] = [
        CIFilterItem("Light", iconName: "sun.max", ciFilter: CIFilterEffect.lightControls()),
        CIFilterItem("Color", iconName: "slider.horizontal.3", ciFilter: CIFilterEffect.colorControls()),
        CIFilterItem("Blur", iconName:"drop.circle", ciFilter: CIFilterEffect.gaussianBlur()),
        CIFilterItem("Curve", iconName:"point.topleft.down.to.point.bottomright.curvepath",
                     ciFilter: CIFilterEffect.curve, rotation: .degrees(90)),
        CIFilterItem("Detail", iconName:"triangleshape", ciFilter: CIFilterEffect.detailsControl()),
        CIFilterItem("Vignette", iconName: "square.arrowtriangle.4.outward", ciFilter: CIFilterEffect.vignetteEffect()),
        
    ]
    
    /// more filters
    //style
    static let bloom = CIFilterItem("CIBloom", iconName: "Bloom", ciFilter: CIFilterEffect.bloom())
    static let comicEffect = CIFilterItem("CIComicEffect", iconName: "Comic", ciFilter: CIFilterEffect.comicEffect)
    static let crystallize = CIFilterItem("CICrystallize", iconName: "Crystallize", ciFilter: CIFilterEffect.crystallize())
    static let edges = CIFilterItem("CIEdges", iconName: "Edge", ciFilter: CIFilterEffect.edges())
    static let edgeWork = CIFilterItem("CIEdgeWork", iconName: "EdgeWork", ciFilter: CIFilterEffect.edgeWork())
    static let garborGradients = CIFilterItem("CIGaborGradients", iconName: "Gabor", ciFilter: CIFilterEffect.gaborGradients)
    static let gloom = CIFilterItem("CIGloom", iconName: "Gloom", ciFilter: CIFilterEffect.gloom())
    static let heightFieldFromMask = CIFilterItem("CIHeightFieldFromMask", iconName: "HeightField", ciFilter: CIFilterEffect.heightFieldFromMask())
    static let hexagonalPixellate = CIFilterItem("CIHexagonalPixellate", iconName: "HexPixellate", ciFilter: CIFilterEffect.hexagonalPixellate())
    static let highlightShadowAdjust = CIFilterItem("CIHighlightShadowAdjust", iconName: "Highlight", ciFilter: CIFilterEffect.highlightShadowAdjust())
    //static let lineOverlay = EffectItem("CILineOverlay", edit: EffectCoreImage.lineOverlay())
    static let pixellate = CIFilterItem("CIPixellate", iconName: "Pixellate", ciFilter: CIFilterEffect.pixellate())
    static let pointillize = CIFilterItem("CIPointillize", iconName: "Pointillize", ciFilter: CIFilterEffect.pointillize())
    static let sobelGradients = CIFilterItem("CISobelGradients", iconName: "Sobel", ciFilter: CIFilterEffect.sobelGradients)
    
    //distort
    static let bumpDistortion = CIFilterItem("CIBumpDistortion", iconName: "Bump", ciFilter: CIFilterEffect.bumpDistort())
    static let droste = CIFilterItem("CIDroste", iconName: "Droste", ciFilter: CIFilterEffect.droste())
    static let glassLozenge = CIFilterItem("CIGlassLozenge", iconName: "GlassLozenge", ciFilter: CIFilterEffect.glassLozenge())
    static let holeDistort = CIFilterItem("CIHoleDistortion", iconName: "Hole", ciFilter: CIFilterEffect.holeDistort())
    static let lightTunnel = CIFilterItem("CILightTunnel", iconName: "LightTunnel", ciFilter: CIFilterEffect.lightTunnel())
    static let circularWrap = CIFilterItem("CICircularWrap", iconName: "CircularWrap", ciFilter: CIFilterEffect.circularWrap())
    static let torusLens = CIFilterItem("CITorusLens", iconName: "TorusLens", ciFilter: CIFilterEffect.torusLens())
    static let twirlDistort = CIFilterItem("CITwirlDistort", iconName: "Twirl", ciFilter: CIFilterEffect.twirlDistort())
    
    //blur
    static let bokehBlur = CIFilterItem("CIBokehBlur", iconName: "Bokeh", ciFilter: CIFilterEffect.bokehBlur())
    static let zoomBlur = CIFilterItem("CIZoomBlur", iconName: "Zoom", ciFilter: CIFilterEffect.zoomBlur())
    //static let noiseReduction = CIFilterItem("CINoiseReduction", iconName: "Noise Reduce", ciFilter: CIFilterEffect.noiseReduction())
    static let motionBlur = CIFilterItem("CIMotionBlur", iconName: "Motion", ciFilter: CIFilterEffect.motionBlur())
    static let morphologyRectangleMinimum = CIFilterItem("CIMorphologyRectangleMinimum", iconName: "MorpRectMin", ciFilter: CIFilterEffect.morphologyRectangleMinimum())
    static let morphologyRectangleMaximum = CIFilterItem("CIMorphologyRectangleMaximum", iconName: "MorpRectMax", ciFilter: CIFilterEffect.morphologyRectangleMaximum())
    static let morphologyMinimum = CIFilterItem("CIMorphologyMinimum", iconName: "MorpMin", ciFilter: CIFilterEffect.morphologyMinimum())
    static let morphologyMaximum = CIFilterItem("CIMorphologyMaximum", iconName: "MorpMax", ciFilter: CIFilterEffect.morphologyMaximum())
    static let discBlur = CIFilterItem("CIDiscBlur", iconName: "Disc", ciFilter: CIFilterEffect.discBlur())
    static let boxBlur = CIFilterItem("CIBoxBlur", iconName: "Box", ciFilter: CIFilterEffect.boxBlur())
    
    //tile
    static let affineClamp = CIFilterItem("CIAffineClamp", iconName: "Clamp", ciFilter: CIFilterEffect.affineClamp())
    static let affineTile = CIFilterItem("CIAffineTile", iconName: "Tile", ciFilter: CIFilterEffect.affineTile())
    static let twelvefoldReflectedTile = CIFilterItem("CITwelvefoldReflectedTile", iconName: "Reflect 12",
                                         ciFilter: CIFilterEffect.twelvefoldReflectedTile())
    static let eightfoldReflectedTile = CIFilterItem("CIEightfoldReflectedTile", iconName: "Reflect 8",
                                         ciFilter: CIFilterEffect.eightfoldReflectedTile())
    static let sixfoldReflectedTile = CIFilterItem("CISixfoldReflectedTile", iconName: "Reflect 6",
                                         ciFilter: CIFilterEffect.sixfoldReflectedTile())
    static let fourfoldReflectedTile = CIFilterItem("CIFourfoldReflectedTile", iconName: "Reflect 4",
                                         ciFilter: CIFilterEffect.fourfoldReflectedTile())
    static let sixfoldRotatedTile = CIFilterItem("CISixfoldRotatedTile", iconName: "Rotate 6",
                                         ciFilter: CIFilterEffect.sixfoldRotatedTile())
    static let fourfoldRotatedTile = CIFilterItem("CIFourfoldRotatedTile", iconName: "Rotate 4",
                                         ciFilter: CIFilterEffect.fourfoldRotatedTile())
    static let fourfoldTranslatedTile = CIFilterItem("CIFourfoldTranslatedTile", iconName: "Translate 4",
                                         ciFilter: CIFilterEffect.fourfoldTranslatedTile())
    static let glideReflectedTile = CIFilterItem("CIGlideReflectedTile", iconName: "Glide",
                                         ciFilter: CIFilterEffect.glideReflectedTile())
    static let kaleidoscope = CIFilterItem("CIKaleidoscope", iconName: "Kaleidoscope",
                                         ciFilter: CIFilterEffect.kaleidoscope())
    static let opTile = CIFilterItem("CIGlideReflectedTile", iconName: "Optical",
                                         ciFilter: CIFilterEffect.opTile())
    static let parallelogramTile = CIFilterItem("CIParallelogramTile", iconName: "Parallelogram",
                                         ciFilter: CIFilterEffect.parallelogramTile())
    static let triangleTile = CIFilterItem("CITriangleTile", iconName: "Triangle",
                                         ciFilter: CIFilterEffect.triangleTile())
    static let triangleKaleidoscope = CIFilterItem("CITriangleKaleidoscope", iconName: "Kaleidoscope 3",
                                         ciFilter: CIFilterEffect.triangleKaleidoscope())
    static let perspectiveTile = CIFilterItem("CIPerspectiveTile", iconName: "Perspective",
                                         ciFilter: CIFilterEffect.perspectiveTile())
    
    static let moreEffects =
    [
        CIFilterItem("Blur", iconName: "drop.circle",
                     items: [zoomBlur, motionBlur, bokehBlur, discBlur, boxBlur,
                             morphologyMaximum, morphologyMinimum,
                             morphologyRectangleMaximum, morphologyRectangleMinimum]),
        
        CIFilterItem("Distort", iconName: "water.waves",
                     items: [bumpDistortion, droste, glassLozenge, holeDistort,
                             lightTunnel, circularWrap, torusLens, twirlDistort]),
        
        CIFilterItem("Style", iconName: "theatermask.and.paintbrush",
                     items: [edges, garborGradients, sobelGradients,
                             crystallize, hexagonalPixellate, pixellate, pointillize,
                             highlightShadowAdjust, bloom, gloom, heightFieldFromMask,
                             edgeWork, comicEffect]),
        
        CIFilterItem("Tile", iconName: "rectangle.grid.3x2",
                     items: [
                              triangleTile,
                              triangleKaleidoscope,
                              kaleidoscope,
                              
                              opTile,
                              affineClamp,
                              affineTile,
                              
                              twelvefoldReflectedTile,
                              eightfoldReflectedTile,
                              sixfoldReflectedTile,
                              fourfoldReflectedTile,
                              glideReflectedTile,
                              
                              sixfoldRotatedTile,
                              fourfoldRotatedTile,
                              
                              fourfoldTranslatedTile,
                              parallelogramTile,
                              perspectiveTile
                            ])
    ]
}

struct CIFilterItem : Hashable, Identifiable {
    var id: String
    
    static func == (lhs: CIFilterItem, rhs: CIFilterItem) -> Bool {
        lhs.name == rhs.name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    var name:String
    var iconName: String
    var ciFilterEffect:CIFilterEffect
    var index : Int = 0
    var items : [CIFilterItem] = []
    var rotation : Angle = .zero

    static var noneEffect = CIFilterItem("", ciFilter: CIFilterEffect.none)
    
    init(_ name:String,
         iconName: String = "",
         ciFilter:CIFilterEffect = .none,
         items : [CIFilterItem] = [],
         rotation : Angle = .zero
    ) {
        self.name = name
        self.iconName = iconName
        self.ciFilterEffect = ciFilter
        self.items = items
        self.id = name
        self.rotation = rotation
    }
}

public enum CIFilterEffect {
    case none
    
    ///basic
    case lightControls(exposure: Double = 0, brightness: Double = 0, contrast: Double = 0, gamma: Double = 0)
    case gaussianBlur(radius: Double = 5)
    case curve
    case colorControls(hue: Double = 0, saturation: Double = 0, temperature: Double = 0)
    case detailsControl(radius : Double = 1, sharpness: Double = 0, noiseReduction: Double = 0)
    case vignetteEffect(position: CGPoint = .init(x: 0.5, y: 0.5),
                        radius: Double = 1,
                        intensity: Double = 1,
                        fallOff: Double = 0.5)
    /// more
    //distort
    case bumpDistort(position: CGPoint = .init(x: 0.5, y: 0.5),
                     radius: Double = 30,
                     scale: Double = 0.5)
    
    case droste(position: [CGPoint] = [.init(x: 0.2, y: 0.2), .init(x: 0.8, y: 0.8)],
                zoom: Double = 1,
                periodicity : Double = 1,
                strands: Double = 1,
                rotation:Double = 0)
    
    case glassLozenge(position: [CGPoint] = [.init(x: 0.5, y: 0.2), .init(x: 0.5, y: 0.8)],
                      radius: Double = 30,
                      refraction : Double = 1.7)
    
    case holeDistort(position: CGPoint = .init(x: 0.5, y: 0.5),
                     radius: Double = 15)
    
    case lightTunnel(position: CGPoint = .init(x: 0.5, y: 0.5),
                     radius: Double = 30, rotation: Double = 180)
    
    case circularWrap(position: CGPoint = .init(x: 0.5, y: 0.5),
                     radius: Double = 100, angle: Double = 180)
    
    case torusLens(position: CGPoint = .init(x: 0.5, y: 0.5),
                   radius: Double = 30, refraction : Double = 1.7,
                   width: Double = 30)
    
    case twirlDistort(position: CGPoint = .init(x: 0.5, y: 0.5),
                      radius: Double = 30, rotation: Double = 180)
    /// style
    case bloom(radius: Double = 30, intensity : Double = 1)
    
    case comicEffect
    
    case crystallize(position: CGPoint = .init(x: 0.5, y: 0.5), radius: Double = 4)
    
    case edges(intensity: Double = 2)
    
    case edgeWork(radius: Double = 2)
    
    case gaborGradients
    
    case gloom(radius: Double = 3, intensity : Double = 10)
    
    case heightFieldFromMask(radius: Double = 4)
    
    case hexagonalPixellate(position: CGPoint = .init(x: 0.5, y: 0.5), scale: Double = 4)
    
    case highlightShadowAdjust(shadowRadus: Double = 1, shadowAmount: Double = 1)
    
    case pixellate(position: CGPoint = .init(x: 0.5, y: 0.5), scale: Double = 4)
    
    case pointillize(position: CGPoint = .zero, radius: Double = 4)
    
    case sobelGradients
    
    /// blur
    case bokehBlur(radius : Double = 5, ringSize: Double = 0.5, ringAmount : Double = 0.5)
    
    case zoomBlur(position: CGPoint = .init(x: 0.5, y: 0.5), amount: Double = 10)
    
    case motionBlur(radius: Double = 5, angle : Double = 45)
    
    case morphologyRectangleMinimum(width: Double = 5, height: Double = 5)
    
    case morphologyRectangleMaximum(width: Double = 5, height: Double = 5)
    
    case morphologyMinimum(radius: Double = 5)
    
    case morphologyMaximum(radius: Double = 5)
    
    case morphologyGradient(radius: Double = 5)
    
    case discBlur(radius: Double = 5)
    
    case boxBlur(radius: Double = 5)

    //tile
    case affineClamp(width: Double = 30, angle: Double = 0, position: CGPoint = .init(x: 0.5, y: 0.5))
    case affineTile(width: Double = 30, angle: Double = 0, position: CGPoint = .init(x: 0.5, y: 0.5))
    
    case twelvefoldReflectedTile(width: Double = 30, angle: Double = 0, position: CGPoint = .init(x: 0.5, y: 0.5))
    case eightfoldReflectedTile(width: Double = 30, angle: Double = 0, position: CGPoint = .init(x: 0.5, y: 0.5))
    case sixfoldReflectedTile(width: Double = 30, angle: Double = 0, position: CGPoint = .init(x: 0.5, y: 0.5))
    case fourfoldReflectedTile(width: Double = 30, angle: Double = 0, position: CGPoint = .init(x: 0.5, y: 0.5))
    case glideReflectedTile(width: Double = 30, angle: Double = 0, position: CGPoint = .init(x: 0.5, y: 0.5))
    
    case sixfoldRotatedTile(width: Double = 30, angle: Double = 0, position: CGPoint = .init(x: 0.5, y: 0.5))
    case fourfoldRotatedTile(width: Double = 30, angle: Double = 0, position: CGPoint = .init(x: 0.5, y: 0.5))
    
    case fourfoldTranslatedTile(width: Double = 30, angle: Double = 0, acuteAngle: Double = 45,
                                position: CGPoint = .init(x: 0.5, y: 0.5))
    case parallelogramTile(width: Double = 30, angle: Double = 0, acuteAngle: Double = 45,
                                position: CGPoint = .init(x: 0.5, y: 0.5))
    
    case kaleidoscope(count: Double = 6, angle: Double = 0, position: CGPoint = .init(x: 0.5, y: 0.5))
    case opTile(width: Double = 30, scale: Double = 1, angle: Double = 0,
                                position: CGPoint = .init(x: 0.5, y: 0.5))
    
    case triangleTile(width: Double = 30, angle: Double = 0, position: CGPoint = .init(x: 0.5, y: 0.5))
    case triangleKaleidoscope(width: Double = 30, angle: Double = 0, decay: Double = 0.85,
                              position: CGPoint = .init(x: 0.5, y: 0.5))
    case perspectiveTile(positions : [CGPoint] = [.init(x: 0.2, y: 0.2), .init(x: 0.8, y: 0.2),
                                                  .init(x: 0.2, y: 0.8), .init(x: 0.8, y: 0.8)])
    
    var preferHeight: CGFloat {
        switch self {
        case .curve, .lightControls, .colorControls, .detailsControl, .droste, .bokehBlur:
            245
        default:
            UILayout.MenuOptionBarHeight + UILayout.EditMenuBarHeight + (UILayout.EditMaskButtonHightLightHeight + UILayout.UndoResetToggleButtonImgSize)/2
        }
    }
}
