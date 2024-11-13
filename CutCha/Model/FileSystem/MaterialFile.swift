//
//  CcMaterial.swift
//  CutCha
//
//  Created by hansoong choong on 11/10/24.
//

import SwiftUI
import CodableFiles

struct CcMaterial : Codable {
    static let MATERIAL_FOLDER = "material"
    static let MATERIAL_FILE = "material"
    static var shared = CcMaterial()
    
    var version : String = "1.0"
    var elements : [String] = []
    
    init(elements : [String] = []) {
        self.elements = elements
    }
    
    func initMaterial() -> [String] {
        if let _ = CutchaFile.shared.initCutcha(in: CcMaterial.MATERIAL_FOLDER) {
            let ccMaterial = CcMaterial.shared.loadMaterial(fileName: CcMaterial.MATERIAL_FILE, in: CcMaterial.MATERIAL_FOLDER)
            if ccMaterial == nil {
                let urls : [String] = []
                var ccMaterial = CcMaterial()
                ccMaterial.elements.append(contentsOf: urls)
                let _ = saveMaterial(ccMaterial, fileName: CcMaterial.MATERIAL_FILE, in: CcMaterial.MATERIAL_FOLDER)
                return ccMaterial.elements
                
            } else  {
                //let _ = print("ccMaterial!.elements = \(ccMaterial!.elements)")
                return ccMaterial!.elements
            }
        }
        return []
    }
    
    var getMaterialFolder : URL? {
        CutchaFile.shared.getCutchaDataFolder(in: CcMaterial.MATERIAL_FOLDER)
    }
    
    func saveMaterial(_ material : CcMaterial, fileName: String, in folder: String) -> URL? {
        return try? CodableFiles.shared.save(material, withFilename: fileName, atDirectory: .directoryName(folder))
    }
    
    func loadMaterial(fileName: String, in folder: String) -> CcMaterial? {
        return try? CodableFiles.shared.load(withFilename: fileName, atDirectory: .directoryName(folder))
    }
    
    func getImagePath(_ filename: String) -> String {
        return getMaterialFolder?.appendingPathComponent(filename).path ?? ""
    }
    
    func getImage(_ filename: String) -> UIImage {
        return UIImage(contentsOfFile: getImagePath(filename)) ?? UIImage()
    }
    
    mutating func saveImage(image : UIImage) -> [String] {
        guard let data = image.pngData() else {
            print("Failed to convert image to data.")
            return elements
        }
        
        // Get the Documents directory path
        guard let materialDirectory = getMaterialFolder else {
            print("Could not find documents directory.")
            return elements
        }
        
        // Create the file URL
        let filename = "\(CutchaFileHelper.shared.generateID()).png"
        
        let fileURL = materialDirectory.appendingPathComponent(filename)
        
        do {
            // Write the data to the file
            try data.write(to: fileURL)
            //print("Image saved to: \(fileURL)")
            if var ccmaterial = loadMaterial(fileName: CcMaterial.MATERIAL_FILE, in: CcMaterial.MATERIAL_FOLDER) {
                ccmaterial.elements.append(filename)
                let _ = saveMaterial(ccmaterial, fileName: CcMaterial.MATERIAL_FILE, in: CcMaterial.MATERIAL_FOLDER)
            }
            return elements
        } catch {
            print("Error saving image: \(error)")
            return elements
        }
    }
}
