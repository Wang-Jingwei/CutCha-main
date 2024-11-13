//
//  DumpDistort.swift
//  SegmentAnywhere
//
//  Created by hansoong choong on 21/5/24.
//

import SwiftUI

struct BumpDistortView: View {
    @EnvironmentObject var effectFilter:EffectFilterViewModel
    @State var radius: Double = 1.0
    @State var xyRatio : [CGPoint] = [.init(x: 0.5, y: 0.5)]
    @State var scale: Double = 0.5
    
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
                    FilterSlider(value: $scale, range: (-4, 4), label: "Scale",
                                 defaultValue: 0.5, rangeDisplay: (-4, 4), decimalPlace: 1)
//                    .border(Color.checkgreen.opacity(0.5))
                }
                .onChange(of: radius) {
                    valueChanged()
                }
                .onChange(of: xyRatio) {
                    valueChanged()
                }
                .onChange(of: scale) {
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
        let effect: CIFilterEffect = .bumpDistort(position: xyRatio[0], radius: radius, scale: scale)
        effectFilter.setEffect(effect: effect)
    }
}
