/*
 Copyright (c) 2017-2019 M.I. Hollemans
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to
 deal in the Software without restriction, including without limitation the
 rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
 sell copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
 IN THE SOFTWARE.
 */

#if canImport(UIKit)

import UIKit

extension UIImage {
    /**
     Resizes the image.
     
     - Parameters:
     - scale: If this is 1, `newSize` is the size in pixels.
     */
    
    @nonobjc public func crop(using imageSize: CGSize, scale: CGFloat = 1) -> UIImage {
        
        var cropRect : CGRect = .zero
        
        if abs(imageSize.width - imageSize.height) < 1 {
            return self
        }
        
        let originalSize = self.size
        
        if imageSize.width > imageSize.height {
            let y1 = originalSize.width * imageSize.height / imageSize.width
            cropRect = .init(origin: .zero, size: .init(width: originalSize.width, height: y1))

        } else {
            let x1 = originalSize.height * imageSize.width / imageSize.height
            cropRect = .init(origin: .zero, size: .init(width: x1, height: originalSize.height))
        }
        // Center crop the image
        if cropRect != .zero {
            let croppedCGImage = self.cgImage!.cropping(to: cropRect)!
            return UIImage(cgImage: croppedCGImage)
        }
        return self
    }
    
    @nonobjc public func resized(to newSize: CGSize, scale: CGFloat = 1) -> UIImage {
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = scale
        let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
        let image = renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
        return image
    }
    
    @nonobjc public func resizedFixRatioTopLeft(to newSize: CGSize, scale: CGFloat = 1) -> UIImage {
        
        let imageSize = self.size
        if abs(imageSize.width - imageSize.height) < 1 {
            return resized(to: newSize)
        } else {
            let format = UIGraphicsImageRendererFormat.default()
            format.scale = 1
            var rect1 : CGRect = .zero
            var rect2: CGRect = .zero
            
            if imageSize.width > imageSize.height {
                let y1 = newSize.width * imageSize.height / imageSize.width
                rect1 = .init(origin: .zero, size: .init(width: newSize.width, height: y1))
                rect2 = .init(origin: .init(x: 0, y: y1), size: .init(width: newSize.width, height: newSize.width - y1))
            } else {
                let x1 = newSize.height * imageSize.width / imageSize.height
                rect1 = .init(origin: .zero, size: .init(width: x1, height: newSize.height))
                rect2 = .init(origin: .init(x: x1, y: 0), size: .init(width: newSize.height - x1, height: newSize.height))
            }
            let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
            let image = renderer.image { context in
                draw(in: CGRect(origin: rect1.origin, size: rect1.size))
                UIColor.black.setFill()
                context.fill(rect2)
            }
            return image
        }
    }
}

#endif
