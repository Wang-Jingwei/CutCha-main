//
//  ColorBackgroundView.swift
//  CutCha
//
//  Created by hansoong choong on 25/9/24.
//

import SwiftUI

struct FillColorView: View {
    @EnvironmentObject var fillVM:FillBackgroundViewModel
    @State var opacity: Double = 1.0
    let originalColor : Color
    
    var body: some View {
        HStack {
            Rectangle()
                .fill(originalColor)
                .border(Color.gray)
                .aspectRatio(1.0, contentMode: .fit)
            VStack {
                FilterSlider(value: $opacity, range: (0, 1), label: "Opacity",
                             defaultValue: 1, rangeDisplay: (0, 100), decimalPlace: 2)
                HStack {
                    Toggle(isOn: $fillVM.keepBackground) {
                        Text("Keep Background")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.white)
                    }
                    .toggleStyle(iOSCheckboxToggleStyle())
                    
                    Spacer()
                    HStack {
                        Toggle(isOn: $fillVM.strokeOnly) {
                            Text("Stroke")
                                .font(.system(size: 10, weight: .regular))
                                .foregroundColor(.white)
                        }
                        .toggleStyle(iOSCheckboxToggleStyle())

                        Picker("", selection: $fillVM.lineWidth) {
                            ForEach(1 ..< 101, id: \.self) { index in
                                Text("\(index)")
                            }
                        }
                        .tint(.white)
                        .scaleEffect(0.8)
                        .disabled(!fillVM.strokeOnly)
                    }
                }
            }
        }
        .onChange(of: opacity) {
            valueChanged()
        }
        .onChange(of: fillVM.keepBackground) {
            valueChanged()
        }
        .onChange(of: fillVM.strokeOnly) {
            valueChanged()
        }
        .onChange(of: fillVM.lineWidth) {
            valueChanged()
        }
        .onAppear {
            self.opacity = fillVM.opacity
            valueChanged()
        }
    }
    
    func valueChanged() {
        let r = originalColor.components.red
        let g = originalColor.components.green
        let b = originalColor.components.blue
        let color = Color(red: r, green: g, blue: b).opacity(opacity)
        fillVM.opacity = self.opacity
        let fillEffect : FillEffect = .color(color)
        fillVM.setFill(effect: fillEffect)
    }
}
