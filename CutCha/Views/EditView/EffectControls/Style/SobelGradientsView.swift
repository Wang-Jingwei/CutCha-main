//
//  SobelGradientsView.swift
//  SegmentAnywhere
//
//  Created by hansoong choong on 24/5/24.
//

import SwiftUI

struct SobelGradientsView: View {
    @EnvironmentObject var effectFilter:EffectFilterViewModel
    
    var body: some View {
        Rectangle()
            .frame(width: 1, height: 1)
            .opacity(0)
            .onAppear {
                valueChanged()
            }
    }
    
    func valueChanged() {
        let effect: CIFilterEffect = .sobelGradients
        effectFilter.setEffect(effect: effect)
    }
}
