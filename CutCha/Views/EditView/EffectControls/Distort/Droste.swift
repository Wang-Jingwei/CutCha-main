//
//  droste.swift
//  SegmentAnywhere
//
//  Created by hansoong choong on 23/5/24.
//
import SwiftUI

struct DrosteView: View {
    @EnvironmentObject var effectFilter:EffectFilterViewModel
    //@State var radius: Double = 1.0
    @State var xyRatio : [CGPoint] = [.init(x: 0.2, y: 0.2), .init(x: 0.8, y: 0.8)]
    @State var zoom: Double = 1
    @State var periodicity: Double = 1
    @State var strands: Double = 1
    @State var rotation: Double = 0
    
    var body: some View {
        //let currentImage = effectFilter.photoManager.currentDisplayImage!
        //let maxLength = min(currentImage.size.width, currentImage.size.height)
        GeometryReader { geo in
            HStack {
                TrackPad(xyRatio: $xyRatio)
                    .frame(width: geo.size.height, height: geo.size.height)
                VStack {   //
                    FilterSlider(value: $zoom, range: (0, 2), label: "Zoom",
                                 defaultValue: 1, rangeDisplay: (0, 100), decimalPlace: 1)
//                    .border(Color.checkgreen.opacity(0.5))
                    FilterSlider(value: $periodicity, range: (1, 10), label: "Periodicity",
                                 defaultValue: 1, rangeDisplay: (1, 10))
//                    .border(Color.checkgreen.opacity(0.5))
                    FilterSlider(value: $strands, range: (1, 10), label: "Strands",
                                 defaultValue: 1, rangeDisplay: (1, 10))
//                    .border(Color.checkgreen.opacity(0.5))
                    FilterSlider(value: $rotation, range: (0, 360), label: "Rotation",
                                 defaultValue: 0, rangeDisplay: (0, 360))
//                    .border(Color.checkgreen.opacity(0.5))
                }
                    .onChange(of: xyRatio) {
                        valueChanged()
                    }
                    .onChange(of: zoom) {
                        valueChanged()
                    }
                    .onChange(of: periodicity) {
                        valueChanged()
                    }
                    .onChange(of: strands) {
                        valueChanged()
                    }
                    .onChange(of: rotation) {
                        valueChanged()
                    }
                    .onAppear {
                        valueChanged()
                        //radius = maxLength / 2
                    }
            }
//            .border(Color.checkcyan.opacity(0.5))
        }
    }
    
    func valueChanged() {
        let effect: CIFilterEffect = .droste(position: xyRatio, zoom: zoom, 
                                              periodicity: periodicity,
                                              strands: strands, rotation: rotation)
        effectFilter.setEffect(effect: effect)
    }
}
