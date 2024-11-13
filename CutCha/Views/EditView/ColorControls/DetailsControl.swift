//
//  SharpenControl.swift
//  colorful-room
//
//  Created by macOS on 7/13/20.
//  Copyright © 2020 PingAK9. All rights reserved.
//

import SwiftUI

struct DetailsControl: View {
    
    @EnvironmentObject var effectFilter:EffectFilterViewModel
    @State var radius: Double = 2
    @State var sharpness: Double = 0.1
    @State var noiseReduction: Double = 0.0
    
    var body: some View {
        VStack {
            FilterSlider(value: $radius, range: (1, 20), label: "Radius",
                         defaultValue: 2, rangeDisplay: (0, 100))
//            .border(Color.checkgreen.opacity(0.5))
            Spacer().frame(maxHeight: UILayout.CommonGap)
            FilterSlider(value: $sharpness, range: (0, 1), label: "Sharpness",
                         defaultValue: 0.1, rangeDisplay: (0, 100), decimalPlace: 2)
//            .border(Color.checkgreen.opacity(0.5))
            Spacer().frame(maxHeight: UILayout.CommonGap)
            FilterSlider(value: $noiseReduction, range: (0, 1), label: "Noise Reduction",
                         defaultValue: 0, rangeDisplay: (0, 100), decimalPlace: 2)
        }
        .onChange(of: radius) {
            valueChanged()
        }
        .onChange(of: sharpness) {
            valueChanged()
        }
        .onChange(of: noiseReduction) {
            valueChanged()
        }
        .onAppear {
            valueChanged()
        }
    }
    
    func valueChanged() {
        let effect: CIFilterEffect = .detailsControl(radius: radius, sharpness: sharpness, noiseReduction: noiseReduction)
        effectFilter.setEffect(effect: effect)
    }
}
