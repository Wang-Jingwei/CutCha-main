//
//  ZoomBlurView.swift
//  SegmentAnywhere
//
//  Created by hansoong choong on 27/5/24.
//

import SwiftUI

struct ZoomBlurView: View {
    @EnvironmentObject var effectFilter:EffectFilterViewModel
    @State var amount: Double = 10
    @State var xyRatio : [CGPoint] = [.init(x: 0.5, y: 0.5)]
    
    var body: some View {
        let currentImage = effectFilter.photoManager.currentDisplayImage!
        let maxLength = min(currentImage.size.width, currentImage.size.height) / 4
        GeometryReader { geo in
            HStack {
                TrackPad(xyRatio: $xyRatio)
                    .frame(width: geo.size.height, height: geo.size.height)
                FilterSlider(value: $amount, range: (1, maxLength), label: "Amount",
                             defaultValue: 10, rangeDisplay: (1, maxLength))
//                .border(Color.checkgreen.opacity(0.5))
                .onChange(of: amount) {
                    valueChanged()
                }
                .onChange(of: xyRatio) {
                    valueChanged()
                }
                .onAppear {
                    valueChanged()
                }
            }
//            .border(Color.checkcyan.opacity(0.5))
        }
    }

    func valueChanged() {
        let effect: CIFilterEffect = .zoomBlur(position: xyRatio[0], amount: amount)
        effectFilter.setEffect(effect: effect)
    }
}

