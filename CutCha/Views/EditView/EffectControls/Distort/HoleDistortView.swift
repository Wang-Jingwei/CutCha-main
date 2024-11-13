//
//  HoleDistortView.swift
//  SegmentAnywhere
//
//  Created by hansoong choong on 23/5/24.
//

import SwiftUI

struct HoleDistortView: View {
    @EnvironmentObject var effectFilter:EffectFilterViewModel
    @State var radius: Double = 1.0
    @State var xyRatio : [CGPoint] = [.init(x: 0.5, y: 0.5)]
    
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
                }
                .onChange(of: radius) {
                    valueChanged()
                }
                .onChange(of: xyRatio) {
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
        let effect: CIFilterEffect = .holeDistort(position: xyRatio[0], radius: radius)
        effectFilter.setEffect(effect: effect)
    }
}
