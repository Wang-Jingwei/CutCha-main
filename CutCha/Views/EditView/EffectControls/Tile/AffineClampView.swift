//
//  AffineClampView.swift
//  CutCha
//
//  Created by hansoong choong on 19/7/24.
//

import SwiftUI

struct AffineClampView: View {
    @EnvironmentObject var effectFilter:EffectFilterViewModel
    @State var width: Double = 400
    //@State var rotation: Double = 0
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
//                    FilterSlider(value: $rotation, range: (-360, 360), label: "Rotation",
//                                 defaultValue: 0, rangeDisplay: (-360, 360))
                }
//                .border(Color.checkgreen.opacity(0.5))
                .onChange(of: width) {
                    valueChanged()
                }
//                .onChange(of: rotation) {
//                    valueChanged()
//                }
                .onChange(of: xyRatio) {
                    valueChanged()
                }
                .onAppear {
                    valueChanged()
                }
            }
//            .border(Color.checkcyan.opacity(0.5))
        }
    }

    func valueChanged() {
        let effect: CIFilterEffect = .affineClamp(width: width, angle: 0, position: xyRatio[0])
        effectFilter.setEffect(effect: effect)
    }
}
