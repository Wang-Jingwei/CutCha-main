//
//  MotionBlurView.swift
//  SegmentAnywhere
//
//  Created by hansoong choong on 27/5/24.
//

import SwiftUI

struct MotionBlurView: View {
    @EnvironmentObject var effectFilter:EffectFilterViewModel
    @State var radius: Double = 30
    @State var angle: Double = 45
    
    var body: some View {
        let currentImage = effectFilter.photoManager.currentDisplayImage!
        let maxLength = min(currentImage.size.width, currentImage.size.height) / 4
        VStack {
            FilterSlider(value: $radius, range: (1, maxLength), label: "Radius",
                         defaultValue: 30, rangeDisplay: (1, maxLength))
//            .border(Color.checkgreen.opacity(0.5))
            Spacer().frame(maxHeight: UILayout.CommonGap)
            FilterSlider(value: $angle, range: (0, 360), label: "Angle",
                         defaultValue: 45, rangeDisplay: (0, 360))
//            .border(Color.checkgreen.opacity(0.5))
        }
        .onChange(of: angle) {
            valueChanged()
        }
        .onChange(of: radius) {
            valueChanged()
        }
        .onAppear {
            valueChanged()
        }
    }
    
    func valueChanged() {
        let effect: CIFilterEffect = .motionBlur(radius: radius, angle: angle)
        effectFilter.setEffect(effect: effect)
    }
}
