//
//  OpTileView.swift
//  CutCha
//
//  Created by hansoong choong on 19/7/24.
//

import SwiftUI

struct OpTileView: View {
    @EnvironmentObject var effectFilter:EffectFilterViewModel
    @State var width: Double = 100
    @State var scale: Double = 2
    @State var rotation: Double = 0
    @State var xyRatio : [CGPoint] = [.init(x: 0.5, y: 0.5)]
    
    var body: some View {
        let currentImage = effectFilter.photoManager.currentDisplayImage!
        let maxLength = min(currentImage.size.width, currentImage.size.height)/4
        GeometryReader { geo in
            HStack {
                TrackPad(xyRatio: $xyRatio)
                    .frame(width: geo.size.height, height: geo.size.height)
                VStack {
                    FilterSlider(value: $width, range: (1, maxLength), label: "Size",
                                 defaultValue: 400, rangeDisplay: (1, maxLength))
                    FilterSlider(value: $scale, range: (1, 4), label: "Scale",
                                 defaultValue: 2, rangeDisplay: (1, 4))
                    FilterSlider(value: $rotation, range: (-180, 180), label: "Rotation",
                                 defaultValue: 0, rangeDisplay: (-180, 180))
                }
                .onChange(of: width) {
                    valueChanged()
                }
                .onChange(of: scale) {
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
        let effect: CIFilterEffect = .opTile(width: width, scale: scale, angle: rotation, position: xyRatio[0])
        effectFilter.setEffect(effect: effect)
    }
}
