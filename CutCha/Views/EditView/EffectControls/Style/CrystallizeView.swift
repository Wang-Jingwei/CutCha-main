//
//  CrystallizeView.swift
//  SegmentAnywhere
//
//  Created by hansoong choong on 24/5/24.
//

import SwiftUI

struct CrystallizeView: View {
    @EnvironmentObject var effectFilter:EffectFilterViewModel
    @State var radius: Double = 10
    @State var xyRatio : [CGPoint] = [.init(x: 0.5, y: 0.5)]
    
    var body: some View {
        let currentImage = effectFilter.photoManager.currentDisplayImage!
        let maxLength = min(currentImage.size.width, currentImage.size.height) / 4
        FilterSlider(value: $radius, range: (1, maxLength), label: "Radius",
                     defaultValue: 10, rangeDisplay: (1, maxLength))
//        .border(Color.checkgreen.opacity(0.5))
        .onChange(of: radius) {
            valueChanged()
        }
        .onChange(of: xyRatio) {
            valueChanged()
        }
        .onAppear {
            valueChanged()
        }
    }

    func valueChanged() {
        let effect: CIFilterEffect = .crystallize(position: xyRatio[0], radius: radius)
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
//                FilterSlider(value: $radius, range: (1, maxLength), label: "Radius",
//                             defaultValue: 10, rangeDisplay: (1, maxLength))
//            }
//            .onChange(of: radius) {
//                valueChanged()
//            }
//            .onChange(of: xyRatio) {
//                valueChanged()
//            }
//            .onAppear {
//                valueChanged()
//            }
//        }
//    }
//}
