//
//  TorusLensView.swift
//  SegmentAnywhere
//
//  Created by hansoong choong on 23/5/24.
//

import SwiftUI

struct TorusLensView: View {
    @EnvironmentObject var effectFilter:EffectFilterViewModel
    @State var xyRatio : [CGPoint] = [.init(x: 0.5, y: 0.5)]
    @State var radius: Double = 1
    @State var refraction: Double = 1.7
    @State var width: Double = 1
    
    var body: some View {
        let currentImage = effectFilter.photoManager.currentDisplayImage!
        let maxLength = min(currentImage.size.width, currentImage.size.height)
        GeometryReader { geo in
            HStack {
                TrackPad(xyRatio: $xyRatio)
                    .frame(width: geo.size.height, height: geo.size.height)
                VStack {   //
                    FilterSlider(value: $radius, range: (1, maxLength), label: "Radius",
                                 defaultValue: 1, rangeDisplay: (1, maxLength))
//                    .border(Color.checkgreen.opacity(0.5))
                    FilterSlider(value: $refraction, range: (1, 3), label: "Refraction",
                                 defaultValue: 1, rangeDisplay: (1, 100), decimalPlace: 2)
//                    .border(Color.checkgreen.opacity(0.5))
                    FilterSlider(value: $width, range: (1, maxLength), label: "Width",
                                 defaultValue: 1, rangeDisplay: (1, maxLength))
//                    .border(Color.checkgreen.opacity(0.5))
                }
                .onChange(of: xyRatio) {
                    valueChanged()
                }
                .onChange(of: radius) {
                    valueChanged()
                }
                .onChange(of: refraction) {
                    valueChanged()
                }
                .onChange(of: width) {
                    valueChanged()
                }
                .onAppear {
                    radius = maxLength / 2
                    width = maxLength / 4
                }
            }
//            .border(Color.checkcyan.opacity(0.5))
        }
    }
    
    func valueChanged() {
        let effect: CIFilterEffect = .torusLens(position: xyRatio[0], radius: radius, 
                                                 refraction: refraction, width: width)
        effectFilter.setEffect(effect: effect)
    }
}
