//
//  HeightFieldFromMaskView.swift
//  SegmentAnywhere
//
//  Created by hansoong choong on 24/5/24.
//

import SwiftUI

struct HeightFieldFromMaskView: View {
    @EnvironmentObject var effectFilter:EffectFilterViewModel
    @State var radius: Double = 3
    
    var body: some View {
        FilterSlider(value: $radius, range: (1, 20), label: "Radius",
                     defaultValue: 3, rangeDisplay: (1, 20))
//        .border(Color.checkgreen.opacity(0.5))
        .onChange(of: radius) {
            valueChanged()
        }
        .onAppear {
            valueChanged()
        }
    }
    
    func valueChanged() {
        let effect: CIFilterEffect = .heightFieldFromMask(radius: radius)
        effectFilter.setEffect(effect: effect)
    }
}
