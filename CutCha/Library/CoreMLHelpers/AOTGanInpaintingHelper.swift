//
//  CoreMLHelpers.swift
//  Inpating
//
//  Created by 間嶋大輔 on 2023/01/12.
//

import Accelerate
import CoreML
import SwiftUI

extension UIImage {
    func mlMultiArray(scale preprocessScale:Double=1/255, rBias preprocessRBias:Double=0, gBias preprocessGBias:Double=0, bBias preprocessBBias:Double=0) -> MLMultiArray {
        let imagePixel = self.getPixelRgb(scale: preprocessScale, rBias: preprocessRBias, gBias: preprocessGBias, bBias: preprocessBBias)
        let mlArray = try! MLMultiArray(shape: [1,3,  NSNumber(value: Float(512)), NSNumber(value: Float(512))], dataType: MLMultiArrayDataType.double)
        mlArray.dataPointer.initializeMemory(as: Double.self, from: imagePixel, count: imagePixel.count)
    
        return mlArray
    }
    
    func mlMultiArrayGrayScale(scale preprocessScale:Double=1/255,bias preprocessBias:Double=0) -> MLMultiArray {
        let imagePixel = self.getPixelGrayScale(scale: preprocessScale, bias: preprocessBias)
        let mlArray = try! MLMultiArray(shape: [1,1,  NSNumber(value: Float(512)), NSNumber(value: Float(512))], dataType: MLMultiArrayDataType.double)
        mlArray.dataPointer.initializeMemory(as: Double.self, from: imagePixel, count: imagePixel.count)
        return mlArray
    }
    
    func mlMultiArrayComposite(outImage out:UIImage, inputImage input:UIImage, maskImage mask: UIImage, scale preprocessScale:Double=1/255, rBias preprocessRBias:Double=0, gBias preprocessGBias:Double=0, bBias preprocessBBias:Double=0) -> MLMultiArray {
        let imagePixel = self.getMaskedPixelRgb(out: out, input: input, mask: mask)

        let mlArray = try! MLMultiArray(shape: [1,3,  NSNumber(value: Float(512)), NSNumber(value: Float(512))], dataType: MLMultiArrayDataType.double)
        mlArray.dataPointer.initializeMemory(as: Double.self, from: imagePixel, count: imagePixel.count)
    
        return mlArray
    }
   
    func getMaskedPixelRgb(out: UIImage,input: UIImage, mask:UIImage, scale preprocessScale:Double=1, rBias preprocessRBias:Double=0, gBias preprocessGBias:Double=0, bBias preprocessBBias:Double=0) -> [Double]
    {
        guard let outCGImage = out.cgImage?.resize(size: CGSize(width: 512, height: 512)) else {
            return []
        }
        let outbytesPerRow = outCGImage.bytesPerRow
        let outwidth = outCGImage.width
        let outheight = outCGImage.height
        let outbytesPerPixel = 4
        let outpixelData = outCGImage.dataProvider!.data! as Data

        guard let inputCGImage = input.cgImage?.resize(size: CGSize(width: 512, height: 512)) else {
            return []
        }
        let inputpixelData = inputCGImage.dataProvider!.data! as Data
        
        guard let maskCgImage = mask.cgImage?.resize(size: CGSize(width: 512, height: 512)) else {
            return []
        }
        let maskBytesPerRow = maskCgImage.bytesPerRow
        let maskBytesPerPixel = 4
        let maskPixelData = maskCgImage.dataProvider!.data! as Data

        var r_buf : [Double] = []
        var g_buf : [Double] = []
        var b_buf : [Double] = []

        for j in 0..<outheight {
            for i in 0..<outwidth {
                let pixelInfo = outbytesPerRow * j + i * outbytesPerPixel
                let maskPixelInfo = maskBytesPerRow * j + i * maskBytesPerPixel
                let v = Double(maskPixelData[maskPixelInfo])
                
                let r = Double(outpixelData[pixelInfo])
                let g = Double(outpixelData[pixelInfo+1])
                let b = Double(outpixelData[pixelInfo+2])
                let bgr = Double(inputpixelData[pixelInfo+1])
                let bgg = Double(inputpixelData[pixelInfo+2])
                let bgb = Double(inputpixelData[pixelInfo+3])
                if v > 0 {
                    r_buf.append(Double(r*preprocessScale)+preprocessRBias)
                    g_buf.append(Double(g*preprocessScale)+preprocessGBias)
                    b_buf.append(Double(b*preprocessScale)+preprocessBBias)
                } else {
                    r_buf.append(Double(bgr*preprocessScale)+preprocessRBias)
                    g_buf.append(Double(bgg*preprocessScale)+preprocessGBias)
                    b_buf.append(Double(bgb*preprocessScale)+preprocessBBias)

                }
            }
        }

        return ((r_buf + g_buf) + b_buf)
    }
    
    func getPixelRgb(scale preprocessScale:Double=1/255, rBias preprocessRBias:Double=0, gBias preprocessGBias:Double=0, bBias preprocessBBias:Double=0) -> [Double]
    {
        guard let cgImage = self.cgImage?.resize(size: CGSize(width: 512, height: 512)) else {
            return []
        }
        let bytesPerRow = cgImage.bytesPerRow
        let width = cgImage.width
        let height = cgImage.height
        let bytesPerPixel = 4
        let pixelData = cgImage.dataProvider!.data! as Data

        var r_buf : [Double] = []
        var g_buf : [Double] = []
        var b_buf : [Double] = []
        
        for j in 0..<height {
            for i in 0..<width {
                let pixelInfo = bytesPerRow * j + i * bytesPerPixel
                let r = Double(pixelData[pixelInfo+1])
                let g = Double(pixelData[pixelInfo+2])
                let b = Double(pixelData[pixelInfo+3])
                r_buf.append(Double(r*preprocessScale)+preprocessRBias)
                g_buf.append(Double(g*preprocessScale)+preprocessGBias)
                b_buf.append(Double(b*preprocessScale)+preprocessBBias)
            }
        }

        return ((r_buf + g_buf) + b_buf)
    }
    
    func getPixelGrayScale(scale preprocessScale:Double=1/255, bias preprocessBias:Double=0) -> [Double]
    {
        guard let cgImage = self.cgImage?.resize(size: CGSize(width: 512, height: 512)) else {
            return []
        }
        let bytesPerRow = cgImage.bytesPerRow
        let width = cgImage.width
        let height = cgImage.height
        let bytesPerPixel = 4
        let pixelData = cgImage.dataProvider!.data! as Data
        
        var buf : [Double] = []
        
        for j in 0..<height {
            for i in 0..<width {
                let pixelInfo = bytesPerRow * j + i * bytesPerPixel
                let v = Double(pixelData[pixelInfo])
                buf.append(Double(v*preprocessScale)+preprocessBias)
            }
        }
        return buf
    }
}
