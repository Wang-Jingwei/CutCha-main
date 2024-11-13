//
//  VignetteControl.swift
//  colorful-room
//
//  Created by macOS on 7/13/20.
//  Copyright © 2020 PingAK9. All rights reserved.
//

import SwiftUI

struct VignetteControl: View {
    
    @EnvironmentObject var effectFilter:EffectFilterViewModel
    @State var radius: Double = 1
    @State var intensity: Double = 0.5
    @State var xyRatio : [CGPoint] = [.init(x: 0.5, y: 0.5)]
    @State var fallOff: Double = 0
    
    var body: some View {
        let currentImage = effectFilter.photoManager.currentDisplayImage!
        let maxLength = max(currentImage.size.width, currentImage.size.height)/2
        GeometryReader { geo in
            HStack {
                TrackPad(xyRatio: $xyRatio)
                    .frame(width: geo.size.height, height: geo.size.height)
                VStack {   //
                    FilterSlider(value: $radius, range: (1, maxLength), label: "Radius",
                                 defaultValue: 100, rangeDisplay: (1, maxLength))
//                    .border(Color.checkgreen.opacity(0.5))
                    FilterSlider(value: $intensity, range: (-1, 1), label: "Intensity",
                                 defaultValue: 0.5, rangeDisplay: (-100, 100), decimalPlace: 2)
//                    .border(Color.checkgreen.opacity(0.5))
                    FilterSlider(value: $fallOff, range: (0, 1), label: "FallOff",
                                 defaultValue: 0, rangeDisplay: (0, 100), decimalPlace: 2)
//                    .border(Color.checkgreen.opacity(0.5))
                }
                .onChange(of: radius) {
                    valueChanged()
                }
                .onChange(of: intensity) {
                    valueChanged()
                }
                .onChange(of: xyRatio) {
                    valueChanged()
                }
                .onChange(of: fallOff) {
                    valueChanged()
                }
                .onAppear {
                    radius = maxLength / 2
                    valueChanged()
                }
            }
//            .border(Color.checkcyan.opacity(0.5))
        }
    }
        
    func valueChanged() {
        let effect: CIFilterEffect = .vignetteEffect(position: xyRatio[0], radius: radius,
                                                     intensity: intensity, fallOff: fallOff)
        effectFilter.setEffect(effect: effect)
    }
}
