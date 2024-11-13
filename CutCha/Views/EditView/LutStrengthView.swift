//
//  LutStrengthView.swift
//  CutCha
//
//  Created by Wang Jingwei on 7/11/24.
//

import SwiftUI

struct LutStrengthView: View{
    @EnvironmentObject var lutViewModel: LUTViewModel
    
    var body: some View {
        VStack{
            FilterSlider(value: $lutViewModel.contrast, range: (-1, 1), label: "Contrast",
                         defaultValue: 0, rangeDisplay: (-1, 1), decimalPlace: 2)
            Spacer().frame(maxHeight: UILayout.CommonGap)
            FilterSlider(value: $lutViewModel.opacity, range: (0, 1), label: "Opacity",
                         defaultValue: 1, rangeDisplay: (0, 1), decimalPlace: 2)
            Spacer().frame(maxHeight: UILayout.CommonGap)
        }
    }
}
