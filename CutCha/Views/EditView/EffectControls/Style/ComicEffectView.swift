//
//  ComicEffectView.swift
//  SegmentAnywhere
//
//  Created by hansoong choong on 24/5/24.
//

import SwiftUI

struct ComicEffectView: View {
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
        let effect: CIFilterEffect = .comicEffect
        effectFilter.setEffect(effect: effect)
    }
}