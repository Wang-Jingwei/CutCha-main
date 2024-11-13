//
//  BrightnessControl.swift
//  colorful-room
//
//  Created by macOS on 7/14/20.
//  Copyright © 2020 PingAK9. All rights reserved.
//

import SwiftUI

struct ColorControl: View {
    
    @EnvironmentObject var effectFilter:EffectFilterViewModel
    @State var hue: Double = 0
    @State var saturation: Double = 1
    @State var neutral: Double = 0
    
    var body: some View {
        VStack {
            FilterSlider(value: $hue, range: (-180, 180), label: "Hue",
                         defaultValue: 0, rangeDisplay: (-180, 180))
//            .border(Color.checkgreen.opacity(0.5))
            Spacer().frame(maxHeight: UILayout.CommonGap)
            FilterSlider(value: $saturation, range: (0, 2), label: "Saturation",
                         defaultValue: 1, rangeDisplay: (0, 100), decimalPlace: 2)
//            .border(Color.checkgreen.opacity(0.5))
            Spacer().frame(maxHeight: UILayout.CommonGap)
            FilterSlider(value: $neutral, range: (-3000, 3000), label: "Temperature",
                         defaultValue: 1, rangeDisplay: (-100, 100))
//            .border(Color.checkgreen.opacity(0.5))
            Spacer().frame(maxHeight: UILayout.CommonGap)
        }
        .onChange(of: hue) {
            valueChanged()
        }
        .onChange(of: saturation) {
            valueChanged()
        }
        .onChange(of: neutral) {
            valueChanged()
        }
        .onAppear {
            valueChanged()
        }
    }
    
    func valueChanged() {
        let effect: CIFilterEffect = .colorControls(hue: hue,
                                                    saturation: saturation,
                                                    temperature: neutral)
        effectFilter.setEffect(effect: effect)
    }
}
