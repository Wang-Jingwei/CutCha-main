/*
 Copyright (c) 2016-2017 M.I. Hollemans
 
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

import UIKit
import Metal

extension UIImage {
    /**
     Converts an MTLTexture into a UIImage. This is useful for debugging.
     
     - TODO: This was not necessarily designed for speed. For more speed,
     look into using the vImage functions from Accelerate.framework or
     maybe CIImage.
     
     - Note: For `.float16` textures the pixels are expected to be in the range
     0...1; if you're using a different range (e.g. 0...255) then you have
     to specify a `scale` factor and possibly an `offset`. Alternatively, you
     can use an `MPSNeuronLinear` to scale the pixels down first.
     */
    @nonobjc public class func image(texture: MTLTexture,
                                     scale: Float = 1,
                                     offset: Float = 0) -> UIImage {
        switch texture.pixelFormat {
        case .r16Float:
            return image(textureR16Float: texture, scale: scale, offset: offset)
        default:
            fatalError("Unsupported pixel format \(texture.pixelFormat.rawValue)")
        }
    }
    
    @nonobjc class func image(textureR16Float texture: MTLTexture,
                              scale: Float = 1,
                              offset: Float = 0) -> UIImage {
        
        assert(texture.pixelFormat == .r16Float)
        if let cgImage = texture.cgImage {
            return UIImage(cgImage: cgImage, scale: 0, orientation: .up)
        } else {
            return UIImage()
        }
        
    }
}

extension MTLTexture {
    public var cgImage: CGImage? {
            guard let image = CIImage(mtlTexture: self, options: nil) else {
                print("CIImage not created")
                return nil
            }
            let flipped = image.transformed(by: CGAffineTransform(scaleX: 1, y: -1))
            return CIContext().createCGImage(flipped,
                                             from: flipped.extent,
                                             format: CIFormat.LA8,
                                             colorSpace: CGColorSpaceCreateDeviceGray())
        }

}
