//
//  LutBalanceView.swift
//  CutCha
//
//  Created by Wang Jingwei on 7/11/24.
//

import SwiftUI
import SceneKit
import ControlPadSPM

struct LutBalanceView: View{
    @EnvironmentObject var lutViewModel: LUTViewModel
    @State private var saturationPosition: Float = 0.5
    @State private var brightnessPosition: Float = 0.5
    @State private var colorTempPosition: Float = 0.5
    @State private var colorTintPosition: Float = 0.5
    
    // Load the saved positions when the view is initialized
    init() {
        let savedPositions = LUTPositionStorage.loadPositions()
        _saturationPosition = State(initialValue: savedPositions.saturation)
        _brightnessPosition = State(initialValue: savedPositions.brightness)
        _colorTempPosition = State(initialValue: savedPositions.colorTemp)
        _colorTintPosition = State(initialValue: savedPositions.colorTint)
        
    }
    
    var body: some View {
        VStack() {
            HStack(){
                VStack(){
                    // XYPad - X for saturation; Y for brightness
                    XYPad(x: $lutViewModel.saturation, y: $lutViewModel.brightness, xPosition: $saturationPosition, yPosition: $brightnessPosition,  xrange: 0...2, yrange: -0.2...0.2, isDragEnded: $lutViewModel.isEnd)
                            .backgroundColor(.gray.opacity(0.5))
                            .foregroundColor(.gray)
                            .cornerRadius(10)
                            .indicatorSize(CGSize(width: 20, height: 20))
                            .frame(width: 150, height: 100)
//                    Text("Saturation: \(String(format: "%.1f", lutViewModel.saturation))").appTextStyle()
//                    Text("Brightness: \(String(format: "%.02f", lutViewModel.brightness))").appTextStyle()
                }
                Spacer()
                VStack(){
                    // XYPad - X for color temp; Y for colot tint
                    XYPad(x: $lutViewModel.colorTemp, y: $lutViewModel.colorTint, xPosition: $colorTempPosition, yPosition: $colorTintPosition,  xrange: 1000...12000, yrange: -1.0...1.0, isDragEnded: $lutViewModel.isEnd)
                            .backgroundColor(.gray.opacity(0.5))
                            .foregroundColor(.gray)
                            .cornerRadius(10)
                            .indicatorSize(CGSize(width: 20, height: 20))
                            .frame(width: 150, height: 100)
//                    Text("Color Temp: \(Int(lutViewModel.colorTemp))K").appTextStyle()
//                    Text("Color Tint: \(String(format: "%.02f", lutViewModel.colorTint))").appTextStyle()
                }
            }
        }
        .padding()
        .onDisappear {
            LUTPositionStorage.savePositions(saturation: saturationPosition, brightness: brightnessPosition, colorTemp: colorTempPosition, colorTint: colorTintPosition)
        }
    }
}
