//
//  GradientFile.swift
//  CutCha
//
//  Created by hansoong choong on 8/10/24.
//

import SwiftUI
import CodableFiles

struct CcGradient : Codable {
    static let GRADIENT_FOLDER = "gradient"
    static let GRADIENT_FILE = "gradient"
    static let shared = CcGradient()
    
    var version : String = "1.0"
    var elements : [GradientPattern] = []
    
    init(elements : [GradientPattern] = []) {
        self.elements = elements
    }
    
    func initGradient() -> [GradientPattern] {
        if let _ = CutchaFile.shared.initCutcha(in: CcGradient.GRADIENT_FOLDER) {
            let ccgradient: CcGradient? = loadGradient(fileName: CcGradient.GRADIENT_FILE, in: CcGradient.GRADIENT_FOLDER)
            if ccgradient == nil {
                let gradientPatterns = ColorConstants.gradientColorsFilter.map {
                    if case FillEffect.gradient(let pattern) = $0.fillEffect {
                        return pattern
                    }
                    return .init()
                }
                var ccgradient = CcGradient()
                ccgradient.elements.append(contentsOf: gradientPatterns)
                let _ = saveGradient(ccgradient, fileName: CcGradient.GRADIENT_FILE, in:  CcGradient.GRADIENT_FOLDER)
                return ccgradient.elements
                
            } else  {
                return ccgradient!.elements
            }
        }
        return []
    }
    
    var getGradientFolder : URL? {
        CutchaFile.shared.getCutchaDataFolder(in: CcGradient.GRADIENT_FOLDER)
    }
    
    func saveGradient(_ gradient : CcGradient, fileName: String, in folder: String) -> URL? {
        return try? CodableFiles.shared.save(gradient, withFilename: fileName, atDirectory: .directoryName(folder))
    }
    
    func loadGradient(fileName: String, in folder: String) -> CcGradient? {
        return try? CodableFiles.shared.load(withFilename: fileName, atDirectory: .directoryName(folder))
    }
    
}
