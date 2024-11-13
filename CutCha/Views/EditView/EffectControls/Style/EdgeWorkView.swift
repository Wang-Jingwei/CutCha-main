//
//  EdgeWorkView.swift
//  SegmentAnywhere
//
//  Created by hansoong choong on 24/5/24.
//

import SwiftUI

struct EdgeWorkView: View {
    @EnvironmentObject var effectFilter:EffectFilterViewModel
    @State var radius: Double = 5
    
    var body: some View {
        FilterSlider(value: $radius, range: (1, 20), label: "Radius",
                     defaultValue: 5, rangeDisplay: (1, 20))
//        .border(Color.checkgreen.opacity(0.5))
        .onChange(of: radius) {
            valueChanged()
        }
        .onAppear {
            valueChanged()
        }
    }
    
    func valueChanged() {
        let effect: CIFilterEffect = .edgeWork(radius: radius)
        effectFilter.setEffect(effect: effect)
    }
}
