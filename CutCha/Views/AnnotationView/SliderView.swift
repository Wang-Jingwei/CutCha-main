//
//  SliderView.swift
//  SegmentAnywhere
//
//  Created by hansoong choong on 16/1/24.
//


import SwiftUI

struct SliderView: View {
    
    @Binding var imageLength: CGFloat
    let min: CGFloat = WorkingImageSize.minSize
    let max: CGFloat = WorkingImageSize.maxSize
    let step: CGFloat = 128
    
    var body: some View {
        VStack {
            Slider(
                value: $imageLength,
                in: min...max,
                step: step,
                minimumValueLabel: Text(min.format0()),
                maximumValueLabel: Text(max.format0()),
                label: {})
            HStack {
                //Text("Fast")
                Spacer()
                Text("**ORIGINAL image will be reload if changed")
                    .bold()
                    .foregroundStyle(Color.red)
                Spacer()
                //Text("Slow")
            }
        }.font(.caption)
    }
}
