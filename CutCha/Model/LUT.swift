//
//  LUT.swift
//  SegmentAnywhere
//
//  Created by hansoong choong on 19/6/24.
//

import Foundation
import CoreImage
import CoreTransferable
import SwiftUI

enum LUT : Hashable {
    case Identity
    case Text
    case Image
    
}

enum LUTError : String, Error {
    case noError
    case duplicatedName = "File with same name already exists, import failed."
    case fileNotValid = "File format error, import failed."
    case noPermission = "File cannot be opened, import failed."
    case wrongExtension = "Only .cube and .png files are supported, import failed."
    case fileTooBig = "File too big, import failed."
    case colorCubeGenerate = "ColorCube failed to generate, import failed."
    case lutMaxSize = "Max LUT size is 64, import failed."
}

struct LUTItem : Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(fileURL)
    }
    static func copyLUTFile(source: URL) throws -> (URL, LUTError) {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let lutURL = documentsURL.appendingPathComponent("LUT/Images")
        
        let destination = lutURL.appendingPathComponent(
            source.deletingPathExtension().lastPathComponent + ".cube", isDirectory: false)
        
        if FileManager.default.fileExists(atPath: destination.path) {
            return (source, .duplicatedName)
        }
        try FileManager.default.copyItem(at: source, to: destination)
        
        return (destination, .noError)
    }
    
    static let Identity : LUTItem = LUTItem()
    var name : String = ""
    var lut : LUT = .Identity
    var lutSize = 0
    var colorCubeData: [Float32] = []
    var fileURL: URL? = nil
    var filter : CIFilter!
    var lutError : LUTError = .noError
    
    init() {}
    
    init(url: URL) {
        if url.pathExtension.lowercased() == "cube" {
            name = (url.lastPathComponent as NSString).deletingPathExtension
            //let _ = print("name = \(name)")
            constructFilter(url: url)
            fileURL = url
        }
    }
    
    func getLUTImage(inputImage: UIImage) -> UIImage {
        if let filter = filter {
                let ciInputImage = CIImage(cgImage: inputImage.cgImage!)
                filter.setValue(ciInputImage, forKey: kCIInputImageKey)
                if let outputImage = filter.outputImage {
                    if let cgImage = outputImage.convertCIImageToCGImage() {
                        return UIImage(cgImage: cgImage)
                            .resized(to: inputImage.size)
                    }
                }
            }
        return inputImage
    }
    
    
    func filterCanOutput() -> Bool {
        let ciInputImage = CIImage(cgImage: UIImage(named: "H1")!.cgImage!)
        let filter = CIFilter.colorCube()
        filter.inputImage = ciInputImage
        filter.cubeDimension = Float(lutSize)
        filter.cubeData = Data(bytes: colorCubeData, count: colorCubeData.count * 4)
        let outImage = filter.outputImage
        if outImage == nil {
            return false
        }
        return true
    }
    
    func convertTextLutToCGImage() -> CGImage? {
        
        if colorCubeData.count <= 0 { return nil }
        let data = colorCubeData.map { data in
           UInt8(min(max(abs(data) * 255.0, 0), 255))
        }
        
        var cgImage : CGImage? = nil
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        data.withUnsafeBytes { rawBufferPointer in
            guard let context = CGContext(data: .init(mutating: rawBufferPointer.baseAddress),
                                          width: lutSize * lutSize,
                                          height: lutSize,
                                          bitsPerComponent: 8,
                                          bytesPerRow: lutSize * lutSize * 4,
                                          space: colorSpace,
                                          bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
            else {
                let _ = print("nothing")
                return
            }
            
            cgImage = context.makeImage()
        }
        return cgImage
    }
    
    mutating func constructFilter(url: URL) {
        if let data = try? Data(contentsOf: url) {
            let uiImage = UIImage(data: data)
            if  uiImage != nil {
                imageCube(uiImage!)
                lut = .Image
            } else {
                textCube(url)
                lut = .Text
                try? FileManager.default.removeItem(at: url)
                if let cgImage = convertTextLutToCGImage() {
                    try? PhotoManager.shared.write(cgImage, to: url)
                    imageCube(UIImage(cgImage: cgImage))
                }
            }
        } else {
            lutError = .fileNotValid
        }
    }
    
    mutating func imageCube(_ uiImage: UIImage) {
        if let tuple = ColorCube.makeColorCubeFilter(lutImage: uiImage,
                                                     colorSpace: CGColorSpaceCreateDeviceRGB()) {
            lutSize = tuple.1
            filter = tuple.0
        } else {
            lutError = .colorCubeGenerate
        }
    }
    
    mutating func textCube(_ url: URL) {
        if let aStreamReader = StreamReader(url: url) {
            defer {
                aStreamReader.close()
            }
            var headerFound = false
            while let line = aStreamReader.nextLine() {
                if !headerFound {
                    if line.lowercased().contains("lut_3d_size") {
                        let counter = line.components(separatedBy: .whitespacesAndNewlines)
                        if counter.count >= 2 {
                            lutSize = Int(counter[1]) ?? 0
                        }
                        headerFound = true
                        while let line1 = aStreamReader.nextLine() {
                            let rgb = line1.components(separatedBy: .whitespacesAndNewlines)
                            //
                            if rgb.count >= 3 && Float32(rgb[0]) != nil {
                                if Float32(rgb[1]) != nil && Float32(rgb[2]) != nil {
                                    colorCubeData.append(contentsOf: [Float32(rgb[0])!, Float32(rgb[1])!, Float32(rgb[2])!, 1.0])
                                    break
                                } else {
                                    lutSize = 0
                                }
                            }
                        }
                    }
                    continue
                }
                
                if lutSize == 0 { break }
                
                let rgb = line.components(separatedBy: .whitespacesAndNewlines)
                if rgb.count >= 3 {
                    if Float32(rgb[0]) != nil && Float32(rgb[1]) != nil && Float32(rgb[2]) != nil {
                        colorCubeData.append(contentsOf: [Float32(rgb[0])!, Float32(rgb[1])!, Float32(rgb[2])!, 1.0])
                    } else {
                        break
                    }
                }
            }
            if lutSize == 0 {
                lutError = .fileNotValid
            } else if lutSize > 64 {
                lutError = .lutMaxSize
            } else if colorCubeData.count != Int(4 * pow(Double(lutSize), 3.0)) {
                lutError = .fileNotValid
            } else if !filterCanOutput() {
                lutError = .colorCubeGenerate
            }
        } else {
            lutError = .fileNotValid
        }
    }
}
