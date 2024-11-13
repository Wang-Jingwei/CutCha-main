//
//  GPUPhotoManager.swift
//  SegmentAnywhere
//
//  Created by hansoong choong on 1/12/23.
//

import SwiftUI
import Metal
import MetalPerformanceShaders
import CoreML

let MPSFloat16 = MPSImageFeatureChannelFormat.float16
typealias FloatType16 = Float16

class GPUPhotoManager: ObservableObject {
    
    static let shared = GPUPhotoManager()
    
   
    func upsamplingBilinear(_ multiArray: MLMultiArray, _ originalSize : CGSize, _ bestIndex : Int = 0) -> UIImage {
        let device = MTLCreateSystemDefaultDevice()!

        var mpsImage : MPSImage?
        var mpsImage2: MPSImage?
        var maskWidth : Int = 256
        var maskHeight : Int = 256
        let originalWidth : Int = Int(originalSize.width)
        let originalHeight : Int = Int(originalSize.height)
        
        if originalSize.width > originalSize.height {
            maskHeight = Int(CGFloat(maskWidth) * originalSize.height / originalSize.width)
        } else {
            maskWidth = Int(CGFloat(maskHeight) * originalSize.width / originalSize.height)
        }
        
        let imageDescriptor = MPSImageDescriptor(channelFormat: MPSFloat16,
                                                 width : maskWidth,
                                                 height: maskHeight,
                                                 featureChannels: 1)
        
        let imageDescriptor2 = MPSImageDescriptor(channelFormat: MPSFloat16,
                                                 width : originalWidth,
                                                 height: originalHeight,
                                                 featureChannels: 1)
        ///to avid gpu to cpu crash
        imageDescriptor.storageMode = .shared
        imageDescriptor2.storageMode = .shared
        
        // Initialize an MPSImage with the descriptor
        mpsImage = MPSImage(device: device, imageDescriptor: imageDescriptor)
        var inputData = [FloatType16](repeating: FloatType16(1.0), count: maskWidth * maskHeight)
        
        for h in 0 ..< maskHeight {
            for w in 0 ..< maskWidth {
                let index = [bestIndex, h, w] as [NSNumber]
                inputData[w + h * maskWidth] = FloatType16(multiArray[index].floatValue)
            }
        }
        
        mpsImage!.writeBytes(&inputData, dataLayout: MPSDataLayout.featureChannelsxHeightxWidth, imageIndex: 0)
        mpsImage2 = MPSImage(device: device, imageDescriptor: imageDescriptor2)
        
        let upsample = MPSNNResizeBilinear(device: device,
                                           resizeWidth: originalWidth,
                                           resizeHeight: originalHeight,
                                           alignCorners: true)

        // Create a command queue
        guard let commandQueue = device.makeCommandQueue() else {
            fatalError("Failed to create Metal command queue")
        }
        // Create a command buffer
        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            fatalError("Failed to create Metal command buffer")
        }
        upsample.encode(commandBuffer: commandBuffer, sourceImage: mpsImage!, destinationImage: mpsImage2!)

        // Commit and wait for the command buffer
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()

        let bilinearMaskImage = UIImage.image(texture: mpsImage2!.texture)
        return bilinearMaskImage
    }
    
    
}
