//
//  EdgesView.swift
//  SegmentAnywhere
//
//  Created by hansoong choong on 24/5/24.
//

import SwiftUI

struct EdgesView: View {
    @EnvironmentObject var effectFilter:EffectFilterViewModel
    @State var intensity: Double = 5
    
    var body: some View {
        FilterSlider(value: $intensity, range: (1, 20), label: "Intensity",
                     defaultValue: 5, rangeDisplay: (1, 20))
//        .border(Color.checkgreen.opacity(0.5))
        
        .onChange(of: intensity) {
            valueChanged()
        }
        .onAppear {
            valueChanged()
        }
    }
    
    func valueChanged() {
        let effect: CIFilterEffect = .edges(intensity: intensity)
        effectFilter.setEffect(effect: effect)
    }
}
