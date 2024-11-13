//
//  HighlightShadowAdjustView.swift
//  SegmentAnywhere
//
//  Created by hansoong choong on 24/5/24.
//

import SwiftUI

struct HighlightShadowAdjustView: View {
    @EnvironmentObject var effectFilter:EffectFilterViewModel
    @State var shadowRadius: Double = 3
    @State var shadowAmount: Double = 0.5
    
    var body: some View {
        VStack {   //
            FilterSlider(value: $shadowRadius, range: (1, 20), label: "Radius",
                         defaultValue: 3, rangeDisplay: (1, 20))
//            .border(Color.checkgreen.opacity(0.5))
            Spacer().frame(maxHeight: UILayout.CommonGap)
            FilterSlider(value: $shadowAmount, range: (0, 1), label: "Amount",
                         defaultValue: 0.5, rangeDisplay: (-100, 100), decimalPlace: 2)
//            .border(Color.checkgreen.opacity(0.5))
        }
        .onChange(of: shadowRadius) {
            valueChanged()
        }
        .onChange(of: shadowAmount) {
            valueChanged()
        }
        .onAppear {
            valueChanged()
        }
    }
    
    func valueChanged() {
        let effect: CIFilterEffect = .highlightShadowAdjust(shadowRadus: shadowRadius, shadowAmount: shadowAmount)
        effectFilter.setEffect(effect: effect)
    }
}
