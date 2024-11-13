//
//  KaleidoscopeView.swift
//  CutCha
//
//  Created by hansoong choong on 19/7/24.
//
import SwiftUI

struct KaleidoscopeView: View {
    @EnvironmentObject var effectFilter:EffectFilterViewModel
    @State var count: Double = 6
    @State var rotation: Double = 0
    @State var xyRatio : [CGPoint] = [.init(x: 0.5, y: 0.5)]
    
    var body: some View {
        GeometryReader { geo in
            HStack {
                TrackPad(xyRatio: $xyRatio)
                    .frame(width: geo.size.height, height: geo.size.height)
                VStack {
                    FilterSlider(value: $count, range: (1, 12), label: "Size",
                                 defaultValue: 6, rangeDisplay: (1, 12))
                    FilterSlider(value: $rotation, range: (-180, 180), label: "Rotation",
                                 defaultValue: 0, rangeDisplay: (-180, 180))
                }
                .onChange(of: count) {
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
        let effect: CIFilterEffect = .kaleidoscope(count: count,
                                                   angle: rotation, position: xyRatio[0])
        effectFilter.setEffect(effect: effect)
    }
}
