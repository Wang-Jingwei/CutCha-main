//
//  HexagonalPixellateView.swift
//  SegmentAnywhere
//
//  Created by hansoong choong on 24/5/24.
//

import SwiftUI

struct HexagonalPixellateView: View {
    @EnvironmentObject var effectFilter:EffectFilterViewModel
    @State var xyRatio : [CGPoint] = [.init(x: 0.5, y: 0.5)]
    @State var scale: Double = 10
    
    var body: some View {
        let currentImage = effectFilter.photoManager.currentDisplayImage!
        let maxLength = min(currentImage.size.width, currentImage.size.height) / 4
        FilterSlider(value: $scale, range: (1, maxLength), label: "Scale",
                     defaultValue: 10, rangeDisplay: (1, maxLength))
//        .border(Color.checkgreen.opacity(0.5))
        .onChange(of: xyRatio) {
            valueChanged()
        }
        .onChange(of: scale) {
            valueChanged()
        }
        .onAppear {
            valueChanged()
        }
    }

    func valueChanged() {
        let effect: CIFilterEffect = .hexagonalPixellate(position: xyRatio[0], scale: scale)
        effectFilter.setEffect(effect: effect)
    }
}

//var body: some View {
//    let currentImage = effectFilter.photoManager.currentDisplayImage!
//    let maxLength = min(currentImage.size.width, currentImage.size.height) / 4
//    GeometryReader { geo in
//        HStack {
//            TrackPad(xyRatio: $xyRatio)
//                .frame(width: geo.size.height, height: geo.size.height)
//            VStack {   //
//                FilterSlider(value: $scale, range: (1, maxLength), label: "Scale",
//                             defaultValue: 10, rangeDisplay: (1, maxLength))
//            }
//            .onChange(of: xyRatio) {
//                valueChanged()
//            }
//            .onChange(of: scale) {
//                valueChanged()
//            }
//            .onAppear {
//                valueChanged()
//            }
//        }
//    }
//}
