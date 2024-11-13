//
//  CircularWrapView.swift
//  SegmentAnywhere
//
//  Created by hansoong choong on 28/5/24.
//

import SwiftUI

struct CircularWrapView: View {
    @EnvironmentObject var effectFilter:EffectFilterViewModel
    @State var radius: Double = 90.0
    @State var xyRatio : [CGPoint] = [.init(x: 0.5, y: 0.5)]
    @State var angle: Double = 180
    
    var body: some View {
        let currentImage = effectFilter.photoManager.currentDisplayImage!
        let maxLength = min(currentImage.size.width, currentImage.size.height)
//        GeometryReader { geo in
//            HStack {
//                TrackPad(xyRatio: $xyRatio)
//                    .frame(width: geo.size.height, height: geo.size.height)
                VStack {   //
                    FilterSlider(value: $radius, range: (1, maxLength), label: "Radius",
                                 defaultValue: 100, rangeDisplay: (1, maxLength))
                    Spacer().frame(maxHeight: UILayout.CommonGap)
//                    .border(Color.checkgreen.opacity(0.5))
                    FilterSlider(value: $angle, range: (0, 360), label: "Angle",
                                 defaultValue: 180, rangeDisplay: (0, 360))
//                    .border(Color.checkgreen.opacity(0.5))
                }
                .onChange(of: radius) {
                    valueChanged()
                }
//                .onChange(of: xyRatio) {
//                    valueChanged()
//                }
                .onChange(of: angle) {
                    valueChanged()
                }
                .onAppear {
                    radius = maxLength
                    //valueChanged()
                }
//            }.border(Color.checkcyan.opacity(0.5))
//        }
    }
    
    func valueChanged() {
        let effect: CIFilterEffect = .circularWrap(position: xyRatio[0], radius: radius, angle: angle)
        effectFilter.setEffect(effect: effect)
    }
}

