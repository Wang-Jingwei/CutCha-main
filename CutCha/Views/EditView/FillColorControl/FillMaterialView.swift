//
//  FillMaterialView.swift
//  CutCha
//
//  Created by hansoong choong on 14/10/24.
//

import SwiftUI

struct FillMaterialView: View {
    @EnvironmentObject var fillVM:FillBackgroundViewModel
    @State var blendMode : CcBlendMode = .normal
    @State var opacity : Double = 1.0
    @State var keepBackground : Bool = true
    
    var body: some View {
        Spacer()
        HStack {
            if case let .image(filename) = fillVM.currentFillItem.fillEffect {
                Image(uiImage: CcMaterial.shared.getImage(filename))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            Spacer()
            VStack {
                Toggle(isOn: $keepBackground) {
                    Text("Keep Background")
                        .font(.system(size: 10, weight: .regular))
                        .foregroundColor(.white)
                }.toggleStyle(iOSCheckboxToggleStyle())
                VStack {
                    HStack {
                        Text("Composite:")
                            .font(.system(size: 10, weight: .regular))
                        Picker("", selection: $blendMode) {
                            ForEach(CcBlendMode.allCases) { mode in
                                Text(mode.rawValue).tag(mode)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .scaleEffect(0.8)
                    }
                    FilterSlider(value: $opacity, range: (0, 1),
                                 defaultValue: 1, rangeDisplay: (0, 100), isDisplayValue: false, decimalPlace: 2)
                }
                .disabled(!keepBackground)
                .tint(.white)
            }
        }
        .onChange(of: blendMode) {
            valueChanged()
        }
        .onChange(of: fillVM.keepBackground) {
            valueChanged()
        }
        .onChange(of: opacity) {
            valueChanged()
        }
        .onAppear {
            valueChanged()
        }
        Spacer()
    }
    
    func valueChanged() {
        fillVM.keepBackground = keepBackground
        fillVM.blendMode = blendMode.toNative
        fillVM.opacity = opacity
        fillVM.setFill(effect: fillVM.currentFillItem.fillEffect)
    }
}

enum CcBlendMode: String, CaseIterable, Identifiable {
    case normal
    case multiply
    case screen
    case overlay
    case darken
    case lighten
    case colorDodge
    case colorBurn
    case softLight
    case hardLight
    case difference
    case exclusion
    case hue
    case saturation
    case color
    case luminosity

    var id: String { rawValue }

    var toNative: CGBlendMode {
        switch self {
        case .normal:
            return .normal
        case .multiply:
            return .multiply
        case .screen:
            return .screen
        case .overlay:
            return .overlay
        case .darken:
            return .darken
        case .lighten:
            return .lighten
        case .colorDodge:
            return .colorDodge
        case .colorBurn:
            return .colorBurn
        case .softLight:
            return .softLight
        case .hardLight:
            return .hardLight
        case .difference:
            return .difference
        case .exclusion:
            return .exclusion
        case .hue:
            return .hue
        case .saturation:
            return .saturation
        case .color:
            return .color
        case .luminosity:
            return .luminosity
        }
    }
    
    var description: String {
        switch self {
        case .normal:
            return "No blending."
        case .multiply:
            return "Multiplies the colors."
        case .screen:
            return "Brightens colors."
        case .overlay:
            return "Combines multiply and screen."
        case .darken:
            return "Retains the darkest colors."
        case .lighten:
            return "Retains the lightest colors."
        case .colorDodge:
            return "Brightens to reflect the blend color."
        case .colorBurn:
            return "Darkens to reflect the blend color."
        case .softLight:
            return "Simulates soft light."
        case .hardLight:
            return "Combines multiply and screen based on the blend color."
        case .difference:
            return "Subtracts the blend color."
        case .exclusion:
            return "Produces lower contrast than difference."
        case .hue:
            return "Preserves luminosity and saturation."
        case .saturation:
            return "Preserves luminosity and hue."
        case .color:
            return "Preserves luminosity while adopting the blend color."
        case .luminosity:
            return "Preserves hue and saturation while adopting the blend luminosity."
        }
    }
}
