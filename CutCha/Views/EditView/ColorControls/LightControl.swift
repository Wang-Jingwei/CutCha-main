//
//  BrightnessControl.swift
//  colorful-room
//
//  Created by macOS on 7/14/20.
//  Copyright © 2020 PingAK9. All rights reserved.
//

import SwiftUI

struct LightControl: View {
    
    @EnvironmentObject var effectFilter:EffectFilterViewModel
    @State var exposure: Double = 0
    @State var brightness: Double = 0
    @State var contrast: Double = 1
    @State var gamma: Double = 1
    
    var body: some View {
        VStack {
            FilterSlider(value: $exposure, range: (-5, 5), label: "Exposure",
                         defaultValue: 0, rangeDisplay: (-100, 100), decimalPlace: 2)
            FilterSlider(value: $brightness, range: (-1, 1), label: "Brightness",
                         defaultValue: 0, rangeDisplay: (-100, 100), decimalPlace: 2)
            FilterSlider(value: $contrast, range: (0, 2), label: "Contrast",
                         defaultValue: 1, rangeDisplay: (0, 100), decimalPlace: 2)
            FilterSlider(value: $gamma, range: (0, 4), label: "Gamma",
                         defaultValue: 1, rangeDisplay: (0, 100), decimalPlace: 2)
        }
        .onChange(of: exposure) {
            valueChanged()
        }
        .onChange(of: brightness) {
            valueChanged()
        }
        .onChange(of: contrast) {
            valueChanged()
        }
        .onChange(of: gamma) {
            valueChanged()
        }
        .onAppear {
            valueChanged()
        }
    }
    
    func valueChanged() {
        let effect: CIFilterEffect = .lightControls(exposure: exposure, 
                                                    brightness: brightness,
                                                    contrast: contrast,
                                                    gamma:gamma)
        effectFilter.setEffect(effect: effect)
    }
}
