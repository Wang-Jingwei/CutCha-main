//
//  SlabImageSegmenter.swift
//  SegmentAnywhere
//
//  Created by hansoong choong on 14/11/23.
//

import CoreML
import Foundation
import SwiftUI
import UIKit
import CoreImage
import Accelerate.vImage

let MLFloatType32 = MLMultiArrayDataType.float32
typealias FloatType32 = Float32

typealias EdgeSAM_EncoderInput = edge_sam_m23_10x_encoderInput
typealias EdgeSAM_EncoderOutput = edge_sam_m23_10x_encoderOutput

typealias EdgeSAM_DecoderInput = edge_sam_m23_10x_decoderInput
typealias EdgeSAM_DecoderOutput = edge_sam_m23_10x_decoderOutput

typealias EdgeSAM_Encoder = edge_sam_m23_10x_encoder
typealias EdgeSAM_Decoder = edge_sam_m23_10x_decoder

class EdgeSAMImageSegmenter: ObservableObject {
    
    static let shared = EdgeSAMImageSegmenter()
    var minValue : Float = 1000
    var maxValue : Float = -1000
    
    var encoderInput : EdgeSAM_EncoderInput?
    var encoderOutput : EdgeSAM_EncoderOutput?
    
    var decoderInput : EdgeSAM_DecoderInput?
    var decoderOutput : EdgeSAM_DecoderOutput?
    
    var encoder : EdgeSAM_Encoder?
    var decoder : EdgeSAM_Decoder?
    
    var debugMode : Bool = false
    
    init() {
        let mlconfig = MLModelConfiguration()
        mlconfig.setValue(1, forKey: "experimentalMLE5EngineUsage")
        if !UIDevice.canRunEdgeSamNeuralEngine { mlconfig.computeUnits = .cpuAndGPU }
        
        ///preload edgesam encoder/decoder
        DispatchQueue.global(qos: .userInteractive).async { [self] in
            encoder = try? EdgeSAM_Encoder(configuration: mlconfig)
        }
        DispatchQueue.global(qos: .userInteractive).asyncAfter(deadline: .now() + 0.3) { [self] in
            decoder = try? EdgeSAM_Decoder(configuration: mlconfig)
        }
    }

    func setupEncoder(_ imageData: Data, _ imageSize: CGSize)  {
        
        let uiImage = UIImage(data: imageData)!.resizedFixRatioTopLeft(to: .init(width: 1024, height: 1024))
        guard
            let cgImage = uiImage.cgImage,
            let sourceImageFormat = vImage_CGImageFormat(cgImage: cgImage),
            let rgbDestinationImageFormat = vImage_CGImageFormat(
                bitsPerComponent: 8,
                bitsPerPixel: 32,
                colorSpace: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.first.rawValue),
                renderingIntent: .defaultIntent)
        else {
            print("Unable to initialize cgImage or colorSpace.")
            return
        }
        
        guard
            let sourceBuffer = try? vImage_Buffer(cgImage: cgImage),
            var rgbDestinationBuffer = try? vImage_Buffer(width: Int(sourceBuffer.width),
                                                          height: Int(sourceBuffer.height),
                                                          bitsPerPixel: rgbDestinationImageFormat.bitsPerPixel) else {
                                                            fatalError("Error initializing source and destination buffers.")
        }
        
        defer {
            sourceBuffer.free()
            rgbDestinationBuffer.free()
        }

        do {
            let toRgbConverter = try vImageConverter.make(sourceFormat: sourceImageFormat,
                                                          destinationFormat: rgbDestinationImageFormat)
            
            try toRgbConverter.convert(source: sourceBuffer,
                                       destination: &rgbDestinationBuffer)
            
            let result = try? rgbDestinationBuffer.createCGImage(format: rgbDestinationImageFormat)

            if let result = result {
                let consistentUIImage = UIImage(cgImage: result)
                let consistent4d = consistentUIImage.getEdgeSAMMLMultiArrayUsingNorm(imageSize)
                encoderInput = EdgeSAM_EncoderInput(image: consistent4d)
                encoderOutput = try? encoder?.prediction(input: encoderInput!)
            }
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func getMaskFromData(usingPts pts: [CGPoint],
                         imageSize: CGSize,
                         containRect: Bool = false) -> UIImage? {
        if encoderOutput == nil { return nil }
        let numOfPts : NSNumber = pts.count as NSNumber
        let point_coords = try! MLMultiArray(shape: [1, numOfPts, 2], dataType: MLFloatType32)
        let point_coords0 = point_coords.strides[0].intValue
        let point_coords1 = point_coords.strides[1].intValue
        let point_coords2 = point_coords.strides[2].intValue
        let ptr_point_coords = UnsafeMutablePointer<FloatType32>(OpaquePointer(point_coords.dataPointer))
        
        for i in 0 ..< pts.count {
            ptr_point_coords[0 * point_coords0 + i * point_coords1 + 0 * point_coords2] = FloatType32(abs(pts[i].x))
            ptr_point_coords[0 * point_coords0 + i * point_coords1 + 1 * point_coords2] = FloatType32(abs(pts[i].y))
        }
        
        let point_labels = try! MLMultiArray(shape: [1, numOfPts], dataType: MLFloatType32)
        let point_labels0 = point_labels.strides[0].intValue
        let point_labels1 = point_labels.strides[1].intValue
        let ptr_point_labels = UnsafeMutablePointer<FloatType32>(OpaquePointer(point_labels.dataPointer))
        for i in 0 ..< pts.count {
            if pts[i].x < 0 || pts[i].y < 0 {
                ptr_point_labels[0 * point_labels0 + i * point_labels1] = 0
            } else {
                ptr_point_labels[0 * point_labels0 + i * point_labels1] = 1
            }
        }
        
        if containRect {
            ptr_point_labels[0 * point_labels0 + (pts.count - 2) * point_labels1] = 2
            ptr_point_labels[0 * point_labels0 + (pts.count - 1) * point_labels1] = 3
        }
        
        decoderInput = .init(image_embeddings: encoderOutput!.image_embeddings,
                             point_coords: point_coords,
                             point_labels: point_labels)
        if decoderInput == nil { return nil }
        decoderOutput = try? decoder?.prediction(input: decoderInput!)
        let maskQualityArray = decoderOutput?.scores
        if maskQualityArray == nil {
            return nil
        }
        let bestIndex =  containRect ? 0 : getBestIndex(maskQualityArray!).intValue
        let decoderMask = try? decoderOutput!.masks.reshaped(to: [4, 256, 256])
        let bilinearMask = GPUPhotoManager.shared
            .upsamplingBilinear(decoderMask!, imageSize, bestIndex)
        return bilinearMask
    }
    
    func getBestIndex(_ mlArray: MLMultiArray) -> NSNumber {
        precondition(mlArray.count == 4, "must be array of 4")
        var bestIndex : [NSNumber] =  [0, 0]
        var bestQuality = mlArray[bestIndex]
        for i in 1 ..< Int(mlArray.count) {
            let currentIndex : [NSNumber] = [0, i as NSNumber]
            let currentQuality = mlArray[currentIndex]
            if currentQuality.floatValue > bestQuality.floatValue {
                bestQuality = currentQuality
                bestIndex = currentIndex
            }
        }
        return bestIndex[1]
    }
}

extension UIImage {
    func getEdgeSAMMLMultiArrayUsingNorm(_ imageSize: CGSize) -> MLMultiArray {
        let imagePixel = self.getEdgeSAMNormPixelRgb(rgbMean: [123.675, 116.28, 103.52],
                                              rgbStd: [58.395, 57.12, 57.375],
                                              imageSize: imageSize)
        let size = self.size
        let mlArray = try! MLMultiArray(shape: [1, 3,  NSNumber(value: size.height), NSNumber(value: size.width)],
                                        dataType: MLFloatType32)
        mlArray.dataPointer.initializeMemory(as: FloatType32.self, from: imagePixel, count: imagePixel.count)
        return mlArray
    }
     
    /// cgImage is actually store image in bgr order
    func getEdgeSAMNormPixelRgb(rgbMean: [FloatType32] = [1, 1, 1], rgbStd: [FloatType32] = [1, 1, 1], imageSize: CGSize) -> [FloatType32]
    {
        guard let cgImage = self.cgImage else {
            return []
        }
        
        var padHeight : Int = cgImage.height
        var padWidth : Int = cgImage.width
        
        let bytesPerRow = cgImage.bytesPerRow
        let width = cgImage.width
        let height = cgImage.height
        
        if imageSize.width > imageSize.height {
            padHeight = Int(CGFloat(height) * imageSize.height / imageSize.width)
        } else if imageSize.height > imageSize.width {
            padWidth = Int(CGFloat(width) * imageSize.width / imageSize.height)
        }
        
        let bytesPerPixel = Int(bytesPerRow / width)
        let pixelData = cgImage.dataProvider!.data! as Data
        var r_buf : [FloatType32] = []
        var g_buf : [FloatType32] = []
        var b_buf : [FloatType32] = []
        
        for j in 0 ..< height {
            for i in 0 ..< width {
                let pixelInfo = bytesPerRow * j + i * bytesPerPixel
                let r = FloatType32(pixelData[pixelInfo])
                let g = FloatType32(pixelData[pixelInfo+1])
                let b = FloatType32(pixelData[pixelInfo+2])
                
                if j < padHeight - 1 && i < padWidth - 1 {
                    r_buf.append(FloatType32(r - rgbMean[0]) / rgbStd[0])
                    g_buf.append(FloatType32(g - rgbMean[1]) / rgbStd[1])
                    b_buf.append(FloatType32(b - rgbMean[2]) / rgbStd[2])
                } else {
                    r_buf.append(FloatType32(0))
                    g_buf.append(FloatType32(0))
                    b_buf.append(FloatType32(0))
                }
            }
        }
        return (r_buf + g_buf) + b_buf
    }
}

// `CoreMLConverter` is a utility class that provides a function to convert a 3D MLMultiArray to a 3D Array.
//class CoreMLConverter {
//    
//    static func convertTo1DMultiArray(_ multiArray: MLMultiArray, 
//                                      isRect : Bool,
//                                      maskThreshold: Double = 0,
//                                      bestIndex: Int = 0) throws -> (MLMultiArray, Float, Float) {
//        // Check if the MLMultiArray has a shape of (depth, height, width).
//        guard multiArray.shape.count == 3 else {
//            throw CoreMLConversionError.invalidShape
//        }
//        let height = multiArray.shape[1].intValue
//        let width = multiArray.shape[2].intValue
//
//        var minValue : Float = 1000
//        var maxValue : Float = -1000
//        
//        var maskValue : NSNumber = 0
//        let mask_array = try! MLMultiArray(shape: [3, 256, 256], dataType: mlFloatType)
//       
//        let finalDeepIndex = isRect ? 0 : bestIndex
//        for h in 0..<height {
//            for w in 0..<width {
//                
//                let index = [finalDeepIndex, h, w] as [NSNumber]
//                let value = multiArray[index].floatValue
//                minValue = min(minValue, value)
//                maxValue = max(maxValue, value)
//                
//                maskValue = value as NSNumber
//                
//                var maskIndex = [0, h, w] as [NSNumber]
//                mask_array[maskIndex] = maskValue
//                maskIndex = [1, h, w] as [NSNumber]
//                mask_array[maskIndex] = maskValue
//                maskIndex = [2, h, w] as [NSNumber]
//                mask_array[maskIndex] = maskValue
//            }
//        }
//        return (mask_array, minValue, maxValue)
//    }
//
//    enum CoreMLConversionError: Error {
//        case invalidShape
//    }
//}

///unuse code
//let _ = print("UIDevice.canRunEdgeSamNeuralEngine = \(UIDevice.canRunEdgeSamNeuralEngine)")
//if debugMode {
//    images = try? CoreMLConverter.getRawMasks(decoderMask!)
//}

//func write(cgimage: CGImage, to url: URL) throws {
//    let cicontext = CIContext()
//    let ciimage = CIImage(cgImage: cgimage)
//    try cicontext.writePNGRepresentation(of: ciimage, to: url, format: .RGBA8, colorSpace: ciimage.colorSpace!)
//}

//static func getRawMasks(_ multiArray: MLMultiArray) throws -> [UIImage] {
//    // Check if the MLMultiArray has a shape of (depth, height, width).
//    guard multiArray.shape.count == 3 else {
//        throw CoreMLConversionError.invalidShape
//    }
//
//    let depth = multiArray.shape[0].intValue
//    let height = multiArray.shape[1].intValue
//    let width = multiArray.shape[2].intValue
//    
//    var maskValue : NSNumber = 0
//    
//    var images : [UIImage] = []
//    let threshold : Float = Float(maskThreshold)
//    
//    for d in 0..<depth {
//        let mask_array = try! MLMultiArray(shape: [3, 256, 256], dataType: mlFloatType)
//        for h in 0..<height {
//            for w in 0..<width {
//                maskValue = 0
//                let index = [d, h, w] as [NSNumber]
//                let value = multiArray[index].floatValue
//                if value > threshold {
//                    maskValue = 1
//                }
//                var maskIndex = [0, h, w] as [NSNumber]
//                mask_array[maskIndex] = maskValue
//                maskIndex = [1, h, w] as [NSNumber]
//                mask_array[maskIndex] = maskValue
//                maskIndex = [2, h, w] as [NSNumber]
//                mask_array[maskIndex] = maskValue
//            }
//        }
//        let cgImage = mask_array.cgImage(min: 0, max: 1)
//        images.append(UIImage(cgImage: cgImage!))
//    }
//    return images
//}

//if debugMode {
//    try? write(cgimage: result, to: URL(filePath: "/Users/hansoong/Downloads/consistentinput.png"))
//    let array3d = try? consistent4d.reshaped(to: [3, Int(consistentUIImage.size.height), Int(consistentUIImage.size.width)])
//    let cgimageback = array3d!.cgImage(min:-2, max:2)
//    try? write(cgimage: cgimageback!, to: URL(filePath: "/Users/hansoong/Downloads/consisteninputback.png"))
//}
