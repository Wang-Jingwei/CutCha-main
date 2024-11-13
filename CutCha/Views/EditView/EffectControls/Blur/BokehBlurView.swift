//
//  BokehBlurView.swift
//  SegmentAnywhere
//
//  Created by hansoong choong on 11/6/24.
//

import SwiftUI

struct BokehBlurView: View {
    @EnvironmentObject var morphologyTransformer:MorphologyTransformer
    var body: some View {
        VStack {
            FilterSlider(value: $morphologyTransformer.bokehRadius, range: (1, 50), label: "Radius",
                         defaultValue: 4, rangeDisplay: (1, 50))
            Spacer().frame(maxHeight: UILayout.CommonGap)
//            .border(Color.checkgreen.opacity(0.5))
            FilterSlider(value: $morphologyTransformer.diaphragmBladeCount, range: (3, 8), label: "Blade",
                         defaultValue: 8, rangeDisplay: (3, 8))
            Spacer().frame(maxHeight: UILayout.CommonGap)
//            .border(Color.checkgreen.opacity(0.5))
            FilterSlider(value: $morphologyTransformer.angle.degrees, range: (0, 360), label: "Angle",
                         defaultValue: 45, rangeDisplay: (0, 360))
//            .border(Color.checkgreen.opacity(0.5))
        }.onAppear {
            valueChanged()
        }
    }
    
    func valueChanged() {
        morphologyTransformer.proceed(sourceImage: morphologyTransformer.photoManager.lastFilteringImage!)
    }
}
