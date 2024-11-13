//
//  MorRectMaxView.swift
//  SegmentAnywhere
//
//  Created by hansoong choong on 27/5/24.
//

import SwiftUI

struct MorRectMaxView: View {
    @EnvironmentObject var effectFilter:EffectFilterViewModel
    @State var width: Double = 5
    @State var height: Double = 5
    
    var body: some View {
        let currentImage = effectFilter.photoManager.currentDisplayImage!
        let maxLength = min(currentImage.size.width, currentImage.size.height) / 4
        VStack {
            FilterSlider(value: $width, range: (1, maxLength), label: "Width",
                         defaultValue: 5, rangeDisplay: (1, maxLength))
            Spacer().frame(maxHeight: UILayout.CommonGap)
//            .border(Color.checkgreen.opacity(0.5))
            FilterSlider(value: $height, range: (1, maxLength), label: "Height",
                         defaultValue: 5, rangeDisplay: (1, maxLength))
//            .border(Color.checkgreen.opacity(0.5))
        }
        .onChange(of: width) {
            valueChanged()
        }
        .onChange(of: height) {
            valueChanged()
        }
        .onAppear {
            valueChanged()
        }
    }
    
    func valueChanged() {
        let effect: CIFilterEffect = .morphologyRectangleMaximum(width: width, height: height)
        effectFilter.setEffect(effect: effect)
    }
}
