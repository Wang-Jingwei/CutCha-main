//
//  TwirlDistort.swift
//  SegmentAnywhere
//
//  Created by hansoong choong on 23/5/24.
//

import SwiftUI

struct TwirlDistort: View {
    @EnvironmentObject var effectFilter:EffectFilterViewModel
    @State var radius: Double = 1.0
    @State var xyRatio : [CGPoint] = [.init(x: 0.5, y: 0.5)]
    @State var rotation: Double = 180
    
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
                    FilterSlider(value: $rotation, range: (0, 360), label: "Rotation",
                                 defaultValue: 180, rangeDisplay: (0, 360))
//                    .border(Color.checkgreen.opacity(0.5))
                }
                .onChange(of: radius) {
                    valueChanged()
                }
                .onChange(of: xyRatio) {
                    valueChanged()
                }
                .onChange(of: rotation) {
                    valueChanged()
                }
                .onAppear {
                    radius = maxLength / 2
                }
            }
//            .border(Color.checkcyan.opacity(0.5))
        }
    }
    
    func valueChanged() {
        let effect: CIFilterEffect = .twirlDistort(position: xyRatio[0], radius: radius, rotation: rotation)
        effectFilter.setEffect(effect: effect)
    }
}
