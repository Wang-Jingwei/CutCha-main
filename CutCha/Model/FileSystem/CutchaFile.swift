//
//  CutchaFile.swift
//  CutCha
//
//  Created by hansoong choong on 23/9/24.
//

import Foundation
import SwiftUI
import CodableFiles

struct CcCanvas : Codable {
    var version : String = "1.0"
    var size : CGSize?
    var background : CcBackground?
    var elements : [CcElement] = []
    var projectType: CcType = .photoEditor
    
    ///move nbig data(images) to data folder
    func makeLightWeight(using folder:String) -> CcCanvas {
        if let dataURL = CutchaFile.shared.getCutchaDataFolder(in: folder) {
            var canvas =  self
            canvas.elements = []
            for element in self.elements {
                if case(.image(let data, let option, _)) = element {
                    let id = CutchaFileHelper.shared.generateID()
                    if let data = data {
                        try? data.write(to: dataURL.appendingPathComponent(id))
                        canvas.elements.append(.image(nil, options: option, id: id))
                    } else {
                        canvas.elements.append(element)
                    }
                }
            }
            return canvas
        }
        return self
    }
}

enum CcType : String, Codable {
    case photoEditor = "PhotoEditor"
}

enum CcBackground : Codable {
    case empty
    case color(Color)
    case gradient(GradientPattern)
    case image(Data, options : [String:String])
}

enum CcElement : Codable {
    case text(String, options : [String:String]?)
    case image(Data?, options : [String:String]?, id: String? = nil)
}

struct CutchaFile {
    static let shared = CutchaFile()
    
    func initCutcha(in folder : String) -> URL? {
        
        return try? CodableFiles.shared.prepare(atDirectory: .directoryName(folder))
    }

    func getCutchaDataFolder(in folder : String) -> URL? {
        
        return try? CodableFiles.shared.getDataFolder(atDirectory: .directoryName(folder))
    }

    func saveCutcha(_ canvas : CcCanvas, fileName: String, in folder: String) -> URL? {
        let lightCanvas = canvas.makeLightWeight(using:folder)
        return try? CodableFiles.shared.save(lightCanvas, withFilename: fileName, atDirectory: .directoryName(folder))
    }
    
    func loadCutcha(fileName: String, in folder: String) -> CcCanvas? {
        return try? CodableFiles.shared.load(withFilename: fileName, atDirectory: .directoryName(folder))
    }
    
    func initGradient() -> [GradientPattern] {
        CcGradient.shared.initGradient()
    }
    
    func initMaterial() -> [String] {
        CcMaterial.shared.initMaterial()
    }
}
