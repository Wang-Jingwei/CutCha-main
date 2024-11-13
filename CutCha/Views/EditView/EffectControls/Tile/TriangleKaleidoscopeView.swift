//
//  TriangleKaleidoscopeView.swift
//  CutCha
//
//  Created by hansoong choong on 22/7/24.
//

import SwiftUI

struct TriangleKaleidoscopeView: View {
    @EnvironmentObject var effectFilter:EffectFilterViewModel
    @State var size: Double = 400
    @State var decay : Double = 0.85
    @State var rotation: Double = 0
    @State var xyRatio : [CGPoint] = [.init(x: 0.5, y: 0.5)]
    
    var body: some View {
        let currentImage = effectFilter.photoManager.currentDisplayImage!
        let maxLength = max(min(currentImage.size.width, currentImage.size.height), 400)
        GeometryReader { geo in
            HStack {
                TrackPad(xyRatio: $xyRatio)
                    .frame(width: geo.size.height, height: geo.size.height)
                VStack {
                    FilterSlider(value: $size, range: (1, maxLength), label: "Size",
                                 defaultValue: 400, rangeDisplay: (1, maxLength))
                    FilterSlider(value: $decay, range: (0, 1), label: "Decay",
                                 defaultValue: 0.85, rangeDisplay: (0, 100))
                    FilterSlider(value: $rotation, range: (-180, 180), label: "Rotation",
                                 defaultValue: 0, rangeDisplay: (-180, 180))
                }
                .onChange(of: size) {
                    valueChanged()
                }
                .onChange(of: decay) {
                    valueChanged()
                }
                .onChange(of: rotation) {
                    valueChanged()
                }
                .onChange(of: xyRatio) {
                    valueChanged()
                }
                .onAppear {
                    valueChanged()
                }
            }
        }
    }
    
    func valueChanged() {
        let effect: CIFilterEffect = .triangleKaleidoscope(width: size, angle: rotation,
                                                           decay: decay, position: xyRatio[0])
        effectFilter.setEffect(effect: effect)
    }
}
