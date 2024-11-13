/// Copyright (c) 2021 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import CoreGraphics
import VideoToolbox
import SwiftUI

extension CGImage {
  static func create(from cvPixelBuffer: CVPixelBuffer?) -> CGImage? {
    guard let pixelBuffer = cvPixelBuffer else {
      return nil
    }

    var image: CGImage?
    VTCreateCGImageFromCVPixelBuffer(
      pixelBuffer,
      options: nil,
      imageOut: &image)
    return image
  }
    func resize(size:CGSize) -> CGImage? {
        let width: Int = Int(size.width)
        let height: Int = Int(size.height)

        let bytesPerPixel = self.bitsPerPixel / self.bitsPerComponent
        let destBytesPerRow = width * bytesPerPixel

        guard let colorSpace = self.colorSpace else { return nil }
        guard let context = CGContext(data: nil, width: width, height: height,
                                      bitsPerComponent: self.bitsPerComponent, bytesPerRow: destBytesPerRow,
                                      space: colorSpace, bitmapInfo: self.alphaInfo.rawValue) else {
            return nil
        }

        context.interpolationQuality = .high
        context.draw(self, in: CGRect(x: 0, y: 0, width: width, height: height))

        return context.makeImage()
    }
    
    func masked(by cgMask: CGImage) -> CIImage {
        let selfCI = CIImage(cgImage: self)
        let maskCI = CIImage(cgImage: cgMask)
        
        let invertFilter = CIFilter(name: "CIColorInvert")!
        invertFilter.setValue(maskCI, forKey: kCIInputImageKey)
        let invertMaskImage = invertFilter.outputImage
        
        let maskFilter = CIFilter(name: "CIMaskToAlpha")
        maskFilter?.setValue(invertMaskImage, forKey: "inputImage")
        
        let scaleFilter = CIFilter(name: "CILanczosScaleTransform")
        scaleFilter?.setValue(maskFilter?.outputImage, forKey: "inputImage")
        scaleFilter?.setValue(selfCI.extent.height / maskCI.extent.height, forKey: "inputScale")
        let maskOutput = scaleFilter?.outputImage
        
        let filter: CIFilter! = CIFilter(name: "CIBlendWithAlphaMask")
        filter.setValue(selfCI, forKey: "inputBackgroundImage")
        filter.setValue(maskOutput, forKey: "inputMaskImage")
        let outputImage = filter.outputImage!
        return outputImage
    }
    
    var bounds: CGRect {
        CGRect(x: 0, y: 0, width: width, height: height)
    }
    
    var frame: CGRect {
        return CGRect(x: 0, y: 0, width: self.width, height: self.height)
    }
}

extension UIImage {
    
    func imageColorInvert() -> UIImage {
        let context = CIContext()
        let inputImage = CIImage(image: self)
        let filter = CIFilter(name: "CIColorInvert")!
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        if let invertCIImage = filter.outputImage {
            if let cgImageInvert = context.createCGImage(invertCIImage, from: invertCIImage.extent) {
                return UIImage(cgImage: cgImageInvert)
            }
        }
        return UIImage()
    }
//    
    func colorToAlpha() -> UIImage {
        
        let context = CIContext()
        let filterMaskToAlpha = CIFilter(name: "CIMaskToAlpha")
        let ciMaskImage = CIImage(cgImage: self.cgImage!)
        filterMaskToAlpha!.setValue(ciMaskImage, forKey: kCIInputImageKey)
        let output = filterMaskToAlpha!.outputImage!
        let cgMask = context.createCGImage(output, from: ciMaskImage.extent)
        return UIImage(cgImage: cgMask!)
    }
    
    func cropAlpha(boundary: inout CGRect) -> UIImage {

        let cgImage = self.cgImage!
        let width = cgImage.width
        let height = cgImage.height
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel:Int = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        let bitmapInfo: UInt32 = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue

        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo),
            let ptr = context.data?.assumingMemoryBound(to: UInt8.self) else {
                return self
        }

        context.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: width, height: height))

        var minX = width
        var minY = height
        var maxX: Int = 0
        var maxY: Int = 0
        boundary = .zero

        for x in 1 ..< width {
            for y in 1 ..< height {

                let i = bytesPerRow * Int(y) + bytesPerPixel * Int(x)
                let a = CGFloat(ptr[i + 3]) / 255.0

                if(a > 0) {
                    if (x < minX) { minX = x }
                    if (x > maxX) { maxX = x }
                    if (y < minY) { minY = y }
                    if (y > maxY) { maxY = y }
                }
            }
        }

        boundary = CGRect(x: CGFloat(minX),y: CGFloat(minY), width: CGFloat(maxX-minX), height: CGFloat(maxY-minY))
        let imageScale:CGFloat = self.scale
        let croppedImage =  self.cgImage!.cropping(to: boundary)!
        let ret = UIImage(cgImage: croppedImage, scale: imageScale, orientation: self.imageOrientation)

        return ret;
    }
    
    /// Make the same image with orientation being `.up`.
    /// - Returns:  A copy of the image with .up orientation or `nil` if the image could not be
    /// rotated.
    func transformOrientationToUp() -> UIImage? {
      // Check if the image orientation is already .up and don't need any rotation.
      guard imageOrientation != UIImage.Orientation.up else {
        // No rotation needed so return a copy of this image.
        return self.copy() as? UIImage
      }

      // Make sure that this image has an CGImage attached.
      guard let cgImage = self.cgImage else { return nil }

      // Create a CGContext to draw the rotated image to.
      guard let colorSpace = cgImage.colorSpace,
        let context = CGContext(
          data: nil,
          width: Int(size.width),
          height: Int(size.height),
          bitsPerComponent: cgImage.bitsPerComponent,
          bytesPerRow: 0,
          space: colorSpace,
          bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )
      else { return nil }

      var transform: CGAffineTransform = CGAffineTransform.identity

      // Calculate the transformation matrix that needed to bring the image orientation to .up
      switch imageOrientation {
      case .down, .downMirrored:
        transform = transform.translatedBy(x: size.width, y: size.height)
        transform = transform.rotated(by: CGFloat.pi)
        break
      case .left, .leftMirrored:
        transform = transform.translatedBy(x: size.width, y: 0)
        transform = transform.rotated(by: CGFloat.pi / 2.0)
        break
      case .right, .rightMirrored:
        transform = transform.translatedBy(x: 0, y: size.height)
        transform = transform.rotated(by: CGFloat.pi / -2.0)
        break
      case .up, .upMirrored:
        break
      @unknown default:
        break
      }

      // If the image is mirrored then flip it.
      switch imageOrientation {
      case .upMirrored, .downMirrored:
          transform = transform.translatedBy(x: size.width, y: 0)
          transform = transform.scaledBy(x: -1, y: 1)
        break
      case .leftMirrored, .rightMirrored:
          transform = transform.translatedBy(x: size.height, y: 0)
          transform = transform.scaledBy(x: -1, y: 1)
      case .up, .down, .left, .right:
        break
      @unknown default:
        break
      }

      // Apply transformation matrix to the CGContext.
      context.concatenate(transform)

      switch imageOrientation {
      case .left, .leftMirrored, .right, .rightMirrored:
        context.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
      default:
        context.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        break
      }

      // Create a CGImage from the context.
      guard let newCGImage = context.makeImage() else { return nil }

      // Convert it to UIImage.
      return UIImage.init(cgImage: newCGImage, scale: 1, orientation: .up)
    }
}
