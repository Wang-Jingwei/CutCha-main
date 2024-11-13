//
//  MorMaxView.swift
//  SegmentAnywhere
//
//  Created by hansoong choong on 27/5/24.
//

import SwiftUI

struct MorMaxView: View {
    @EnvironmentObject var effectFilter:EffectFilterViewModel
    @State var radius: Double = 5
    
    var body: some View {
        let currentImage = effectFilter.photoManager.currentDisplayImage!
        let maxLength = min(currentImage.size.width, currentImage.size.height) / 4
        
        FilterSlider(value: $radius, range: (1, maxLength), label: "Radius",
                     defaultValue: 5, rangeDisplay: (1, maxLength))
//        .border(Color.checkgreen.opacity(0.5))
        .onChange(of: radius) {
            valueChanged()
        }
        .onAppear {
            valueChanged()
        }
    }
    
    func valueChanged() {
        let effect: CIFilterEffect = .morphologyMaximum(radius: radius)
        effectFilter.setEffect(effect: effect)
    }
}
