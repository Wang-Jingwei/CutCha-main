//
//  GloomView.swift
//  SegmentAnywhere
//
//  Created by hansoong choong on 24/5/24.
//

import SwiftUI

struct GloomView: View {
    @EnvironmentObject var effectFilter:EffectFilterViewModel
    @State var radius: Double = 3
    @State var intensity: Double = 10
    
    var body: some View {
        VStack {   //
            FilterSlider(value: $radius, range: (1, 20), label: "Radius",
                         defaultValue: 3, rangeDisplay: (1, 20))
            Spacer().frame(maxHeight: UILayout.CommonGap)
//            .border(Color.checkgreen.opacity(0.5))
            FilterSlider(value: $intensity, range: (0, 100), label: "Intensity",
                         defaultValue: 10, rangeDisplay: (0, 100))
//            .border(Color.checkgreen.opacity(0.5))
        }
        .onChange(of: radius) {
            valueChanged()
        }
        .onChange(of: intensity) {
            valueChanged()
        }
        .onAppear {
            valueChanged()
        }
    }
    
    func valueChanged() {
        let effect: CIFilterEffect = .gloom(radius: radius, intensity: intensity)
        effectFilter.setEffect(effect: effect)
    }
}
