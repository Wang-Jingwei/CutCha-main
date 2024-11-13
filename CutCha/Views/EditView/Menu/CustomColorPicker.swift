//
//  ColorPicker.swift
//  SegmentAnywhere
//
//  Created by vh on 28/4/24.
//

import Foundation
import SwiftUI

struct CustomColorPicker: View {
    let colorWheelScaleRatio: CGFloat
    let pickerWidth: CGFloat
    let pickerHeight: CGFloat
    let gap: CGFloat
    let containerHeight: CGFloat
    let isPickerOnly: Bool
    var isBackgroundShape: Bool = false
    
    @Binding var isDisableColor : Bool
    @Binding var bindColor: Color
    @Binding var lastColor : Color
    
    var body: some View {
        if isPickerOnly {
            ColorPickerView()
        } else {
            pickerOrNoneView()
        }
    }
    
    @ViewBuilder
    private func ColorPickerView() -> some View {
        VStack(spacing:0){
            Spacer().frame(height: 10)
            ColorPicker("Picker", selection: $bindColor)
                .scaleEffect(CGSize(width: colorWheelScaleRatio, height: colorWheelScaleRatio))
                .labelsHidden()
                .frame(width: pickerWidth, height: pickerHeight - 10)
                .appButtonStyle()
            
            Text("Picker")
                .appTextStyle()
        }
        .frame(height: containerHeight)
        .appButtonStyle3()
    }
    
    @ViewBuilder
    private func pickerOrNoneView() -> some View {
        GeometryReader { geo1 in
            VStack(spacing: 0){
                VStack(spacing:0) {
                    Image(systemName: "circle.slash")
                        .frame(width: pickerWidth, height: pickerHeight - 10)
                        .onTapGesture {
                            ontapgesturefunc()
                        }
                        .onChange(of: bindColor) {
                            if isDisableColor && (bindColor != lastColor) {
                                if (bindColor != Color(.lightGray)) && (bindColor != .clear) {
                                    lastColor = bindColor
                                    isDisableColor = false
                                }
                            }
                        }
                      
                    Text("None")
                        .appTextStyle()
                    Spacer().frame(height: gap)
                }
                .frame(width: pickerWidth, height: geo1.size.height/2 - gap/2)
                .appButtonStyle(active: isDisableColor)
                
                Spacer().frame(height: gap)
                
                VStack(spacing: 0) {
                    
                    ColorPickerView()
                    
                    Text("Picker")
                        .appTextStyle()
                    Spacer().frame(height: gap)
                }
                .frame(width: pickerWidth, height: geo1.size.height/2 - gap/2)
                .appButtonStyle3()
            }
        }.frame(width: pickerWidth, height: containerHeight)
    }
    
    @ViewBuilder
    func pickerOnlyView() -> some View {
        ColorPickerView()
    }
    
    private func ontapgesturefunc() {
        isDisableColor.toggle()
        if isDisableColor {
            lastColor = bindColor
            bindColor = isBackgroundShape ? lastColor : .clear
        } else {
            bindColor = lastColor
        }
    }
}
