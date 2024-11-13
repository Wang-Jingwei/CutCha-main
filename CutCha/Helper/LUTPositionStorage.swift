//
//  LUTPositionStorage.swift
//  CutCha
//
//  Created by Wang Jingwei on 7/11/24.
//

import Foundation

struct LUTPositionStorage {
    static let saturationKey = "saturationPosition"
    static let brightnessKey = "brightnessPosition"
    static let colorTempKey = "colorTempPosition"
    static let colorTintKey = "colorTintPosition"
    
    static func savePositions(saturation: Float, brightness: Float, colorTemp: Float, colorTint: Float) {
        UserDefaults.standard.set(saturation, forKey: saturationKey)
        UserDefaults.standard.set(brightness, forKey: brightnessKey)
        UserDefaults.standard.set(colorTemp, forKey: colorTempKey)
        UserDefaults.standard.set(colorTint, forKey: colorTintKey)
    }
    
    static func loadPositions() -> (saturation: Float, brightness: Float, colorTemp: Float, colorTint: Float) {
        let saturation = UserDefaults.standard.float(forKey: saturationKey)
        let brightness = UserDefaults.standard.float(forKey: brightnessKey)
        let colorTemp = UserDefaults.standard.float(forKey: colorTempKey)
        let colorTint = UserDefaults.standard.float(forKey: colorTintKey)
        
        // If no value is found, return defaults (like 0.5, 0.5, 0.5, 0.5)
        return (saturation != 0 ? saturation : 0.5,
                brightness != 0 ? brightness : 0.5,
                colorTemp != 0 ? colorTemp : 0.5,
                colorTint != 0 ? colorTint : 0.5)
    }
    
    static func resetToDefault() {
        savePositions(saturation: 0.5, brightness: 0.5, colorTemp: 0.5, colorTint: 0.5)
    }
}
