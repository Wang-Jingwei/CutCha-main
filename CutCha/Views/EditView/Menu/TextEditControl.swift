//
//  FontSizeControl.swift
//  SegmentAnywhere
//
//  Created by hansoong on 22/4/24.
//

import SwiftUI
import UIKit

struct TextEditControl : View {
    
    @EnvironmentObject var photoManager : PhotoManager
    @State var sliderArg : Double
    
    @Binding var textOptions : [TextOption]
    @Binding var currentTextIndex : Int
    let sliderCase : SliderBindingCase
    let range : (Double, Double)
    let step: Double
    let rangeDisplay: (Double, Double)
    let label: String
    let decimalPlace: Int
    
    var body: some View {
        
        let sliderArg = Binding<Double>(
            get: {
                setSlider()
            },
            set: {
                self.sliderArg = $0
                self.updateModelValue()
                self.updateTextManager()
            }
        )
        FilterSlider(value: sliderArg, range: range, label: label, 
                     defaultValue: self.sliderArg, rangeDisplay: rangeDisplay,
                     spacing: step, isDisplayValue: true,
                     decimalPlace: decimalPlace)
    }
    
    private func updateModelValue() {
        switch sliderCase {
        case .fontSize:
            textOptions[currentTextIndex].fontSize = Int(sliderArg)
        case .scaleEffectWidth:
            textOptions[currentTextIndex].scaleEffect.width = sliderArg
        case .scaleEffectHeight:
            textOptions[currentTextIndex].scaleEffect.height = sliderArg
        case .shadowXDirection:
            textOptions[currentTextIndex].shadowXDirection = sliderArg
        case .shadowYDirection:
            textOptions[currentTextIndex].shadowYDirection = sliderArg
        case .shadowRadius:
            textOptions[currentTextIndex].shadowRadius = Int(sliderArg)
        case .textBorderWidth:
            textOptions[currentTextIndex].textBorderWidth = Int(sliderArg)
        case .backBorderWidth:
            textOptions[currentTextIndex].backBorderWidth = Int(sliderArg)
        }
    }
    
    private func updateTextManager() {
        switch sliderCase {
        case .fontSize:
            photoManager.textManager.fontSize = textOptions[currentTextIndex].fontSize
        case .scaleEffectWidth:
            photoManager.textManager.scaleEffectWidth = textOptions[currentTextIndex].scaleEffect.width
        case .scaleEffectHeight:
            photoManager.textManager.scaleEffectHeight = textOptions[currentTextIndex].scaleEffect.height
        case .shadowXDirection:
            photoManager.textManager.shadowXDirection = textOptions[currentTextIndex].shadowXDirection
        case .shadowYDirection:
            photoManager.textManager.shadowYDirection = textOptions[currentTextIndex].shadowYDirection
        case .shadowRadius:
            photoManager.textManager.shadowRadius = textOptions[currentTextIndex].shadowRadius
        case .textBorderWidth:
            photoManager.textManager.textBorderWidth = textOptions[currentTextIndex].textBorderWidth
        case .backBorderWidth:
            photoManager.textManager.backBorderWidth = textOptions[currentTextIndex].backBorderWidth
        }
    }
    
    private func setSlider() -> Double {
        switch sliderCase {
        case .fontSize:
            return Double(textOptions[currentTextIndex].fontSize)
        case .scaleEffectWidth:
            return textOptions[currentTextIndex].scaleEffect.width
        case .scaleEffectHeight:
            return textOptions[currentTextIndex].scaleEffect.height
        case .shadowXDirection:
            return textOptions[currentTextIndex].shadowXDirection
        case .shadowYDirection:
            return textOptions[currentTextIndex].shadowYDirection
        case .shadowRadius:
            return Double(textOptions[currentTextIndex].shadowRadius)
        case .textBorderWidth:
            return Double(textOptions[currentTextIndex].textBorderWidth)
        case .backBorderWidth:
            return Double(textOptions[currentTextIndex].backBorderWidth)
        }
    }
}
