//
//  PerspectiveTileView.swift
//  CutCha
//
//  Created by hansoong choong on 22/7/24.
//

import SwiftUI

struct PerspectiveTileView: View {
    @EnvironmentObject var effectFilter:EffectFilterViewModel
    @State var width: Double = 300
    @State var rotation: Double = 0
    @State var xyRatio : [CGPoint] = [.init(x: 0.2, y: 0.2), .init(x: 0.8, y: 0.2),
                                      .init(x: 0.2, y: 0.8), .init(x: 0.8, y: 0.8)]
    
    var body: some View {
        GeometryReader { geo in
            HStack {
                TrackPad(xyRatio: $xyRatio)
                    .frame(width: geo.size.width, height: geo.size.height)
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
        let effect: CIFilterEffect = .perspectiveTile(positions: xyRatio)
        effectFilter.setEffect(effect: effect)
    }
}
