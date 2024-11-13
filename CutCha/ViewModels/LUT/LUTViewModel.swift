//
//  LUTViewModel.swift
//  SegmentAnywhere
//
//  Created by hansoong choong on 19/6/24.
//

import Foundation
import SwiftUI
import CoreImage
import UniformTypeIdentifiers
import SceneKit
import PhotosUI
import OSLog
import UIKit
import Photos
import CoreML
import Accelerate
import CoreImage.CIFilterBuiltins

class LUTViewModel: ObservableObject, FilterModel  {
    @AppStorage("favoriteLUT") var favoriteLUT: [String] = []
    @Published var lutOption : LUTOption = .ALL
    @Published var lutList : [LUTItem] = []
    
    @Published var currentLUTItem:LUTItem = LUTItem.Identity
    @Published var isModified: Bool = false
    
    @Published var isSetLut: Bool = false
    
    @Published var editType : EditType = .BalancePanel
    var filter : CIFilter!
    
    var photoManager : PhotoManager
    private let filterQueue = DispatchQueue(label: "com.app.filterProcessing", qos: .userInitiated)
    private var currentFilterWorkItem: DispatchWorkItem?
    
    var vertices: [SCNVector3] = []
    var colors: [SCNVector3] = []
    var indices: [UInt32] = []
    var lutSize: Int = 0
    
    var vertices_ori : [SCNVector3] = []
    var colors_ori : [SCNVector3] = []
    var downsampledVertices: [SCNVector3] = []
    
    var isResetting = false
    private var isUpdating = false
    @Published var isEnd = false
    
    
    @Published var saturation: Float = 1.0 {
        didSet {
            if !isResetting {
                debounceProcessFilter()
            }
        }
    }

    @Published var brightness: Float = 0.0 {
        didSet {
            if !isResetting {
                debounceProcessFilter()
            }
        }
    }

    @Published var colorTemp: Float = 6500.0 {
        didSet {
            if !isResetting {
                debounceProcessFilter()
            }
        }
    }

    @Published var colorTint: Float = 0.0 {
        didSet {
            if !isResetting {
                debounceProcessFilter()
            }
        }
    }

    @Published var contrast: Double = 0.0 {
        didSet {
            if !isResetting {
                debounceProcessFilter()
            }
        }
    }

    @Published var opacity: Double = 1.0 {
        didSet {
            if !isResetting {
                debounceProcessFilter()
            }
        }
    }
    
    func resetToDefault(){
        isResetting = true
        saturation = 1.0
        brightness = 0.0
        colorTemp = 6500.0
        colorTint = 0.0
        contrast = 0.0
        opacity = 1.0
        LUTPositionStorage.resetToDefault()
        isResetting = false
    }
    
    private var debounceWorkItem: DispatchWorkItem?
    private let debounceDelay: TimeInterval = 0.1

    private func debounceProcessFilter() {
        // Cancel any previous debounced task
        debounceWorkItem?.cancel()
        
        // Create a new task to process the filter
        debounceWorkItem = DispatchWorkItem {
            self.processFilter()
        }
        
        // Execute the task after the debounce delay
        DispatchQueue.main.asyncAfter(deadline: .now() + debounceDelay, execute: debounceWorkItem!)
    }
    
  
    private func processFilter() {
        self.isModified = true
        if !isUpdating{
            isUpdating = true
            let startTime = CFAbsoluteTimeGetCurrent()
//            if !isEnd{
//                vertices = satAndBri(downsampledVertices, sintensity: CGFloat(saturation), bintensity: CGFloat(brightness))
//                lutSize = 32
//            }else{
                vertices = satAndBri(vertices_ori, sintensity: CGFloat(saturation), bintensity: CGFloat(brightness))
                lutSize = self.currentLUTItem.lutSize
//            }
            vertices = tempAndTint(vertices, colorTemp: CGFloat(colorTemp), colorTint: CGFloat(colorTint))
            vertices = applyContrast(vertices, intensity: contrast)
            // Measure the total time
            let totalTime = CFAbsoluteTimeGetCurrent() - startTime
            print("Total processFilter took: \(totalTime) seconds")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                let startTiime = CFAbsoluteTimeGetCurrent()
                self.updateDisplayImage()
                let totalTiime = CFAbsoluteTimeGetCurrent() - startTiime
                print("Update Image took: \(totalTiime) seconds")
                self.isUpdating = false
            }
        }
   }
    
//    func applyLUTFilter(inputUIImage: UIImage) -> UIImage? {
//        print("Updating")
//        let colorCubeData: [Float32] = vertices.flatMap {
//            [$0.x, $0.y, $0.z, 1.0]
//        }
//        
//        guard !colorCubeData.isEmpty else { return nil }
//        let data = colorCubeData.map { data in
//            UInt8(min(max(abs(data) * 255.0, 0), 255))
//        }
//        
//        guard let originalFileURL = self.currentLUTItem.fileURL,
//             let lutImage = UIImage(contentsOfFile: originalFileURL.path) else {
//           print("Failed to load LUT image.")
//           return nil
//       }
//    
//        
//        var lutWidth = Int(lutImage.size.width)
//        var lutHeight = Int(lutImage.size.height)
//        
//        if !isEnd{
//            let ratio = Double(lutWidth) / Double(lutHeight)
//            let lutHeightDouble = sqrt(pow(Double(lutSize), 3.0) / ratio)
//            lutHeight = Int(round(lutHeightDouble))
//            lutWidth = Int(round(ratio * Double(lutHeight)))
//        }
//       
//        var cgImage : CGImage? = nil
//        let colorSpace = CGColorSpaceCreateDeviceRGB()
//        data.withUnsafeBytes { rawBufferPointer in
//            guard let context = CGContext(data: .init(mutating: rawBufferPointer.baseAddress),
//                                          width: lutWidth,
//                                          height: lutHeight,
//                                          bitsPerComponent: 8,
//                                          bytesPerRow: lutWidth * 4,
//                                          space: colorSpace,
//                                          bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
//            else {
//                let _ = print("nothing")
//                return
//            }
//            
//            cgImage = context.makeImage()
//        }
//        
//        guard let lutCGImage = cgImage,
//              let colorCubeFilterTuple = ColorCube.makeColorCubeFilter(lutImage: UIImage(cgImage: lutCGImage), colorSpace: colorSpace) else {
//            print("Failed to create ColorCube filter.")
//            return nil
//        }
//        filter = colorCubeFilterTuple.0
//        
//        if let filter = filter {
//            let ciInputImage = CIImage(cgImage: inputUIImage.cgImage!)
//            filter.setValue(ciInputImage, forKey: kCIInputImageKey)
//            
//            //opacity
//            guard let filteredImage = filter.outputImage else {
//                return nil
//            }
//            let blendFilter = CIFilter(name: "CIBlendWithMask")
//            blendFilter?.setValue(ciInputImage, forKey: kCIInputBackgroundImageKey)
//            blendFilter?.setValue(filteredImage, forKey: kCIInputImageKey)
//            let maskGenerator = CIFilter(name: "CIConstantColorGenerator")
//            let maskColor = CIColor(red: CGFloat(opacity), green: CGFloat(opacity), blue: CGFloat(opacity))
//            maskGenerator?.setValue(maskColor, forKey: kCIInputColorKey)
//            blendFilter?.setValue(maskGenerator?.outputImage, forKey: kCIInputMaskImageKey)
//            
//            guard let outputImage = blendFilter?.outputImage,
//                  let finalCGImage = outputImage.convertCIImageToCGImage() else {
//                return nil
//            }
//            
//            return UIImage(cgImage: finalCGImage)
//                .resized(to: inputUIImage.size)
//            
////            if let outputImage = filter.outputImage {
////                if let cgImage = outputImage.convertCIImageToCGImage() {
////                    return UIImage(cgImage: cgImage)
////                        .resized(to: inputUIImage.size)
////                }
////            }
//        }
//        return inputUIImage
//    }
    
//    func applyLUTFilter(inputUIImage: UIImage) -> UIImage? {
//        // 1. Early validation
//        guard let inputCGImage = inputUIImage.cgImage,
//              let originalFileURL = self.currentLUTItem.fileURL,
//              let lutImage = UIImage(contentsOfFile: originalFileURL.path) else {
//            print("Failed to load input image or LUT image.")
//            return nil
//        }
//        
//        // 2. Optimize color cube data creation
//        let colorCubeData: [UInt8] = vertices.flatMap { vertex in
//            [UInt8(min(max(vertex.x * 255.0, 0), 255)),
//             UInt8(min(max(vertex.y * 255.0, 0), 255)),
//             UInt8(min(max(vertex.z * 255.0, 0), 255)),
//             255]
//        }
//        
//        guard !colorCubeData.isEmpty else { return nil }
//        
//        // 3. More efficient LUT dimensions calculation
//        let lutWidth = Int(lutImage.size.width)
//        let lutHeight = Int(lutImage.size.height)
//        
//        let (finalWidth, finalHeight) = isEnd ? (lutWidth, lutHeight) : {
//            let ratio = Double(lutWidth) / Double(lutHeight)
//            let lutHeightDouble = sqrt(pow(Double(lutSize), 3.0) / ratio)
//            let height = Int(round(lutHeightDouble))
//            let width = Int(round(ratio * Double(height)))
//            return (width, height)
//        }()
//        
//        // 4. Optimized CGImage creation
//        let colorSpace = CGColorSpaceCreateDeviceRGB()
//        let cgImage = colorCubeData.withUnsafeBufferPointer { buffer -> CGImage? in
//            guard let context = CGContext(
//                data: UnsafeMutableRawPointer(mutating: buffer.baseAddress),
//                width: finalWidth,
//                height: finalHeight,
//                bitsPerComponent: 8,
//                bytesPerRow: finalWidth * 4,
//                space: colorSpace,
//                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
//                return nil
//            }
//            return context.makeImage()
//        }
//        
//        // 5. Simplified filter creation and application
//        guard let lutCGImage = cgImage,
//              let (filter, _) = ColorCube.makeColorCubeFilter(
//                lutImage: UIImage(cgImage: lutCGImage),
//                colorSpace: colorSpace) else {
//            print("Failed to create ColorCube filter.")
//            return nil
//        }
//        
//        // 6. Optimized image processing pipeline
//        let ciInputImage = CIImage(cgImage: inputCGImage)
//        filter.setValue(ciInputImage, forKey: kCIInputImageKey)
//        
//        guard let filteredImage = filter.outputImage else { return nil }
//        
//        // 7. Efficient blend filter setup
//        let blendFilter = CIFilter(name: "CIBlendWithMask")
//        let maskGenerator = CIFilter(name: "CIConstantColorGenerator")
//        let maskColor = CIColor(red: CGFloat(opacity), green: CGFloat(opacity), blue: CGFloat(opacity))
//        
//        blendFilter?.setValue(ciInputImage, forKey: kCIInputBackgroundImageKey)
//        blendFilter?.setValue(filteredImage, forKey: kCIInputImageKey)
//        maskGenerator?.setValue(maskColor, forKey: kCIInputColorKey)
//        blendFilter?.setValue(maskGenerator?.outputImage, forKey: kCIInputMaskImageKey)
//        
//        // 8. Final image creation with proper memory management
//        guard let outputImage = blendFilter?.outputImage?.convertCIImageToCGImage() else {
//            return nil
//        }
//        
//        return UIImage(cgImage: outputImage).resized(to: inputUIImage.size)
//    }
    
    func applyLUTFilter(inputUIImage: UIImage) -> UIImage? {
        guard let cgImage = inputUIImage.cgImage else { return nil }
                
        let context = CIContext()
        let ciImage = CIImage(cgImage: cgImage)
        
        // Create color cube filter
        guard let filter = CIFilter(name: "CIColorCube") else { return nil }
        
        // Convert SCNVector3 to float array
        var cubeData = [Float]()
        cubeData.reserveCapacity(vertices.count * 4)
        
        for vector in vertices {
            cubeData.append(Float(vector.x))
            cubeData.append(Float(vector.y))
            cubeData.append(Float(vector.z))
            cubeData.append(1.0) // Alpha channel
        }
        
        // Set filter parameters
        filter.setValue(self.currentLUTItem.lutSize, forKey: "inputCubeDimension")
        filter.setValue(Data(bytes: &cubeData, count: cubeData.count * MemoryLayout<Float>.size),
                       forKey: "inputCubeData")
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        
        // Apply filter and convert back to UIImage
        guard let outputImage = filter.outputImage,
              let cgOutput = context.createCGImage(outputImage, from: outputImage.extent) else {
            return nil
        }
        
        return UIImage(cgImage: cgOutput)
    }
    
        
    
    func satAndBri(_ cube: [SCNVector3], sintensity: CGFloat, bintensity: CGFloat) -> [SCNVector3] {
        let hsb = rgbToHSB(rgb: cube)
        let hsbNew : [SCNVector3] = hsb.map {
            .init($0.x, min($0.y * Float(sintensity), 1), Float(truncate(CGFloat($0.z) + bintensity)))
        }
        return hsbToRGB(hsb: hsbNew)
    }
    
    func rgbToHSB(rgb : [SCNVector3]) -> [SCNVector3] {
        rgb.map {
            let color = Color.init(red: CGFloat($0.x), green: CGFloat($0.y), blue: CGFloat($0.z))
            var h: CGFloat = 0
            var s: CGFloat = 0
            var b: CGFloat = 0
            if UIColor(color).getHue(&h, saturation: &s, brightness: &b, alpha: nil) {
                return SCNVector3(h, s, b)
            } else {
                let _ = print("toHSB failed, value = \($0)")
                return SCNVector3(0, 0, 0)
            }
        }
    }
    
    func hsbToRGB(hsb : [SCNVector3]) -> [SCNVector3] {
        hsb.map {
            let color = Color.init(hue: CGFloat($0.x), saturation: CGFloat($0.y), brightness: CGFloat($0.z))
            var r: CGFloat = 0
            var g: CGFloat = 0
            var b: CGFloat = 0
            if UIColor(color).getRed(&r, green: &g, blue: &b, alpha: nil) {
                return SCNVector3(r, g, b)
            } else {
                let _ = print("toRGB failed, value = \($0)")
                return SCNVector3(0, 0, 0)
            }
        }
    }
    
    func tempAndTint(_ vertices: [SCNVector3], colorTemp: CGFloat, colorTint: CGFloat) -> [SCNVector3] {
        let temp = (colorTemp - 6500) / 6500
        let rTempAdjust = 1 - temp
        let bTempAdjust = 1 + temp
        let (rTintAdjust, gTintAdjust, bTintAdjust): (CGFloat, CGFloat, CGFloat)
        
        if colorTint > 0 {
            // Tint toward green
            gTintAdjust = 1 + colorTint * 2 // Boost green
            rTintAdjust = 1 - colorTint // Reduce red
            bTintAdjust = 1 - colorTint // Reduce blue
        } else {
            // Tint toward magenta
            gTintAdjust = 1 + colorTint // Reduce green
            rTintAdjust = 1 - colorTint * 2 // Boost red
            bTintAdjust = 1 - colorTint * 2 // Boost blue
        }
        
        return vertices.map { vertex in
            // Convert from sRGB to linear RGB
            let rLinear = pow(CGFloat(vertex.x), 2.2)
            let gLinear = pow(CGFloat(vertex.y), 2.2)
            let bLinear = pow(CGFloat(vertex.z), 2.2)
            
            // Convert back to sRGB
            return SCNVector3(
                pow(truncate(rLinear * rTempAdjust * rTintAdjust), 1 / 2.2),
                pow(truncate(gLinear * gTintAdjust), 1 / 2.2),
                pow(truncate(bLinear * bTempAdjust * bTintAdjust), 1 / 2.2)
            )
        }
    }
    
    func truncate(_ value: CGFloat, _ lowBound: CGFloat = 0.0, _ highBound: CGFloat = 1.0) -> CGFloat {
        return max(lowBound, min(value, highBound))
    }
    
    func applyContrast(_ cube: [SCNVector3], intensity: Double) -> [SCNVector3] {
        let contrastIntensity = map(value: intensity, fromLow: -1.0, fromHigh: 1.0, toLow: -255, toHigh: 255)
        let factor = (259 * (CGFloat(contrastIntensity) + 255)) / (255 * (259 - CGFloat(contrastIntensity)))
        
        func adjustColorComponent(_ component: CGFloat) -> CGFloat {
            return truncate(CGFloat(factor) * (component - 0.5) + 0.5)
        }
        
        return cube.map { color in
            return SCNVector3(
                adjustColorComponent(CGFloat(color.x)),
                adjustColorComponent(CGFloat(color.y)),
                adjustColorComponent(CGFloat(color.z))
            )
        }
    }
    
    func map(value: CGFloat, fromLow: CGFloat, fromHigh: CGFloat, toLow: CGFloat, toHigh: CGFloat) -> Int {
        let mappedValue = toLow + (toHigh - toLow) * ((value - fromLow) / (fromHigh - fromLow))
        return Int(mappedValue.rounded())
    }

    
    init(photoManager : PhotoManager) {
        self.photoManager = photoManager
        self.photoManager.lutViewModel = self
        (vertices_ori, colors_ori, indices, lutSize) = identity()
        vertices = vertices_ori
        colors = vertices
        LUTPositionStorage.resetToDefault()
    }
    
    func updateDisplayImage() {
        self.photoManager.updateDisplayImage(usingModel: self)
    }
    
    func setLUTItem(_ lutItem : LUTItem, refreshIcon : Bool = true) {
        self.currentLUTItem = lutItem
        self.isModified = false
        resetToDefault()
        updateDisplayImage()
        if lutItem.lut == LUT.Identity{
            (vertices, colors, indices, lutSize) = identity()
        }else{
            convertToTextLut(item: lutItem)
        }
        print(lutItem)
    }
    
    func identity() -> ([SCNVector3], [SCNVector3], [UInt32], Int) {
        let lutSize = 33
        var vertices : [SCNVector3] = []
        var colors : [SCNVector3] = []
        var indices : [UInt32] = []
        var counter : UInt32 = 0
        
        let step : Float = 1.0 / (Float(lutSize) - 1)
        
        for x in 0 ..< lutSize {
            for y in 0 ..< lutSize {
                for z in 0 ..< lutSize {
                    let r = Float(z) * step
                    let g = Float(y) * step
                    let b = Float(x) * step
                    
                    vertices.append(.init(x: r, y: g, z: b))
                    colors.append(.init(x: r, y: g, z: b))
                    indices.append(counter)
                    counter = counter + 1
                }
            }
        }
        return (vertices, colors, indices, lutSize)
    }
    
    func convertToTextLut(item: LUTItem) {
       //TODO: check this else statement
        guard let originalFileURL = item.fileURL else {
            print("Original file URL is nil.")
            return
        }
        guard let imageSource = CGImageSourceCreateWithURL(originalFileURL as CFURL, nil) else {
            print("Failed to create image source.")
            return
        }

        guard let cgImage = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else {
            print("Failed to create CGImage from image source.")
            return
        }
        
        
        (vertices_ori, lutSize) = convertCGImageToTextLut(cgImage: cgImage, item: item)
        downsampledVertices = downsampleLUT(vertices_ori, fromSize: item.lutSize)
        vertices = downsampledVertices
        colors = vertices
        indices = []
        for i in 0..<vertices.count {
            indices.append(UInt32(i))
        }
    }
    
    func downsampleLUT(_ vertices: [SCNVector3], fromSize: Int, toSize: Int = 32) -> [SCNVector3] {
        guard fromSize > toSize else { return vertices }
        
        let ratio = Float(fromSize - 1) / Float(toSize - 1)
        var downsampled: [SCNVector3] = []
        downsampled.reserveCapacity(toSize * toSize * toSize)
        
        // Iterate through the target size dimensions
        for b in 0..<toSize {
            for g in 0..<toSize {
                for r in 0..<toSize {
                    // Calculate original indices
                    let origR = min(Int(Float(r) * ratio), fromSize - 1)
                    let origG = min(Int(Float(g) * ratio), fromSize - 1)
                    let origB = min(Int(Float(b) * ratio), fromSize - 1)
                    
                    // Calculate flat index in original array
                    let index = origR + origG * fromSize + origB * fromSize * fromSize
                    
                    // Add downsampled vertex to new array
                    downsampled.append(vertices[index])
                }
            }
        }
        
        return downsampled
    }
    
    func convertToSCNVector3(_ textLUTData: [Float]) -> [SCNVector3] {
        var result: [SCNVector3] = []
        
        // Loop through the array in steps of 4 to process RGBA values
        for i in stride(from: 0, to: textLUTData.count, by: 4) {
            let r = textLUTData[i]
            let g = textLUTData[i + 1]
            let b = textLUTData[i + 2]
            
            // Create an SCNVector3 with r, g, and b values (ignore alpha)
            let colorVector = SCNVector3(r, g, b)
            result.append(colorVector)
        }
        
        return result
    }
    
    func convertCGImageToTextLut(cgImage: CGImage, item: LUTItem) -> ([SCNVector3], Int) {
        var colorCubeData = [Float]()
        
        let width = cgImage.width
        let height = cgImage.height

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        var buffer = [UInt8](repeating: 0, count: item.lutSize * item.lutSize * 4 * item.lutSize)
        
        guard let context = CGContext(data: &buffer,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: 8,
                                      bytesPerRow: width * 4,
                                      space: colorSpace,
                                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            print("Failed to create context")
            return (convertToSCNVector3(colorCubeData), 0)
        }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        colorCubeData = buffer.map { Float($0) / 255.0 }

        return (convertToSCNVector3(colorCubeData), item.lutSize)
    }

    func constructLuts(from lutsURL: [URL]) async -> [LUTItem] {
        var lutList : [LUTItem] = []
        for url in lutsURL {
            let lutItem = LUTItem(url: url)
            lutList.append(lutItem)
        }
        lutList.sort { $0.name.lowercased() < $1.name.lowercased() }
        return lutList
    }
    
    func removeItem(_ lutItem: LUTItem) {
        if let index = lutList.firstIndex(of:lutItem) {
            let name = lutItem.name.lowercased()
            if currentLUTItem == lutItem {
                setLUTItem(.Identity)
            }
            if favoriteLUT.contains(name) {
                let index = favoriteLUT.firstIndex(of: name)!
                favoriteLUT.remove(at: index)
            }
            
            if let url = lutItem.fileURL {
                try? FileManager.default.removeItem(at: url)
            }
            lutList.remove(at: index)
        }
    }
    
    func renameItem(_ lutItem: LUTItem, _ newName: String) {
        let oldName = lutItem.name.lowercased()
        if favoriteLUT.contains(oldName) {
            let index = favoriteLUT.firstIndex(of: oldName)!
            favoriteLUT[index] = newName.lowercased()
        }
        let lutIndex = lutList.firstIndex(of: lutItem)
        
        if lutIndex != nil {
            if lutList[lutIndex!].fileURL != nil {
                lutList[lutIndex!].name = newName
                var rv = URLResourceValues()
                rv.name = newName + ".cube"
                try? lutList[lutIndex!].fileURL!.setResourceValues(rv)
                lutList.sort { $0.name.lowercased() < $1.name.lowercased() }
            }
        }
    }
    
    ///file related
    func createFolder(named: String) -> URL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let lutURL = documentsURL.appendingPathComponent(named)

        do {
            try FileManager.default.createDirectory(at: lutURL, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Error creating directory: \(error)")
        }
        return lutURL
    }
    
    func importFromURL(_ url: URL) -> LUTError {
        guard url.pathExtension.lowercased() == "cube" ||  url.pathExtension.lowercased() == "png" else {
            return .wrongExtension
        }
        var destPath : URL = url
        var lutError : LUTError = .noError
        
        let fileName = url.deletingPathExtension().lastPathComponent
        
        if lutList.first(where: { item in
            item.name.lowercased() == fileName.lowercased()
        }) != nil {
            return .duplicatedName
        }

        do {
            if url.startAccessingSecurityScopedResource() {
                if let fileSize = url.fileSize {
                    if fileSize < 10 * 1024 * 1024 {
                        (destPath, lutError) = try LUTItem.copyLUTFile(source: url)
                        //let _ = print("destPath = \(destPath)")
                        if lutError == .duplicatedName {
                            return .duplicatedName
                        }
                    } else {
                        url.stopAccessingSecurityScopedResource()
                        return .fileTooBig
                    }
                }
            }
            url.stopAccessingSecurityScopedResource()
        } catch {
            return .noPermission
        }
        
        if lutError == .noError {
            let lutItem = LUTItem(url: destPath)
            
            if lutItem.lutError != .noError {
                try? FileManager.default.removeItem(at: destPath)
                return lutItem.lutError
            }
            lutList.append(lutItem)
            print(lutItem)
            lutList.sort { $0.name.lowercased() < $1.name.lowercased() }
        }
        return .noError
    }
    
    @MainActor
    func refreshLutList() async {
        currentLUTItem = .Identity
        let lutURL = createFolder(named: "LUT/Images")
        var lutFilesURL = [URL]()
        if let enumerator = FileManager.default
            .enumerator(at: lutURL,
                        includingPropertiesForKeys: [.isRegularFileKey],
                        options: [.skipsHiddenFiles, .skipsPackageDescendants]) {
            for case let fileURL as URL in enumerator {
                do {
                    let fileAttributes = try fileURL.resourceValues(forKeys:[.isRegularFileKey])
                    if fileAttributes.isRegularFile! {
                        lutFilesURL.append(fileURL)
                    }
                } catch { print(error, fileURL) }
            }
        }
        lutList = await constructLuts(from: lutFilesURL)
    }
    
}

// also declare the content type in the Info.plist
extension UTType {
    static var importTextLUT : UTType = UTType(importedAs: "com.noname.textLUT")
    static var importImageLUT : UTType = UTType(importedAs: "com.noname.imageLUT")
}

enum LUTOption {
    case ALL
    case Favorite
}

enum EditType {
    case BalancePanel
    case StrengthPanel
    case PresetsPanel
}
