//
//  UIColorEditImageViewExtension.swift
//  SegmentAnywhere
//
//  Created by hansoong choong on 24/5/24.
//

import SwiftUI

extension UIKitColorEditImageView {
    
    @ViewBuilder
    var getEffectView : some View {
        switch effectFilter.currentEffectItem.ciFilterEffect {
          
        // basic
        case .lightControls:
            LightControl()
        case .colorControls:
            ColorControl()
        case .vignetteEffect:
            VignetteControl()
        case.detailsControl:
            DetailsControl()
        case .gaussianBlur:
            GaussianView()
        case.curve:
            CurveControl()
            
        // distort
        case .bumpDistort:
            BumpDistortView()
        case .droste:
            DrosteView()
        case .glassLozenge:
            GlassLozengeView()
        case .holeDistort:
            HoleDistortView()
        case .lightTunnel:
            LightTunnelView()
        case .circularWrap:
            CircularWrapView()
        case .torusLens:
            TorusLensView()
        case .twirlDistort:
            TwirlDistort()
            
            //style
        case .bloom:
            BloomView()
        case .comicEffect:
            ComicEffectView()
        case .crystallize:
            CrystallizeView()
        case .edges:
            EdgesView()
        case .edgeWork:
            EdgeWorkView()
        case .gaborGradients:
            GaborGradientsView()
        case .gloom:
            GloomView()
        case .heightFieldFromMask:
            HeightFieldFromMaskView()
        case .hexagonalPixellate:
            HexagonalPixellateView()
        case .highlightShadowAdjust:
            HighlightShadowAdjustView()
        case .pixellate:
            PixellateView()
        case .pointillize:
            PointillizeView()
        case .sobelGradients:
            SobelGradientsView()
            
        //blur
        case .bokehBlur:
            BokehBlurView()
        case .zoomBlur:
            ZoomBlurView()
        case .motionBlur:
            MotionBlurView()
        case .morphologyRectangleMinimum:
            MorRectMinView()
        case .morphologyRectangleMaximum:
            MorRectMaxView()
        case .morphologyMinimum:
            MorMinView()
        case .morphologyMaximum:
            MorMaxView()
        case .morphologyGradient:
            MorGradientView()
        case .discBlur:
            DiscBlurView()
        case .boxBlur:
            BoxBlurView()
            
        //tile
        case .affineClamp:
            AffineClampView()
        case .affineTile:
            AffineTileView()
            
        case .twelvefoldReflectedTile:
            TwelvefoldReflectedTileView()
        case .eightfoldReflectedTile:
            EightfoldReflectedTileView()
        case .sixfoldReflectedTile:
            SixfoldReflectedTileView()
        case .fourfoldReflectedTile:
            FourfoldReflectedTileView()
        case .glideReflectedTile:
            GlideReflectedTileView()
            
        case .sixfoldRotatedTile:
            SixfoldRotatedTileView()
        case .fourfoldRotatedTile:
            FourfoldRotatedTileView()
            
        case .fourfoldTranslatedTile:
            FourfoldTranslatedTileView()
            
        case .triangleTile:
            TriangleTileView()
        case .triangleKaleidoscope:
            TriangleKaleidoscopeView()
        case .kaleidoscope:
            KaleidoscopeView()
        
        case .opTile:
            OpTileView()
        case .parallelogramTile:
            ParallelogramTileView()
        
        case .perspectiveTile:
            PerspectiveTileView()
        default:
            EmptyView()
        }
    }
}
