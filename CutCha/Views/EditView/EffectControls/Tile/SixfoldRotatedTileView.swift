//
//  SixfoldRotatedTileView.swift
//  CutCha
//
//  Created by hansoong choong on 22/7/24.
//

import SwiftUI

struct SixfoldRotatedTileView: View {
    @EnvironmentObject var effectFilter:EffectFilterViewModel
    @State var width: Double = 300
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
                    FilterSlider(value: $width, range: (1, maxLength), label: "Size",
                                 defaultValue: 400, rangeDisplay: (1, maxLength))
                    FilterSlider(value: $rotation, range: (-180, 180), label: "Rotation",
                                 defaultValue: 0, rangeDisplay: (-180, 180))
                }
                .onChange(of: width) {
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
        let effect: CIFilterEffect = .sixfoldRotatedTile(width: width, angle: rotation, position: xyRatio[0])
        effectFilter.setEffect(effect: effect)
    }
}