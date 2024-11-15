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

import Metal

extension MTLTexture {
    /**
     Creates a new array of `Float16`s and copies the texture's pixels into it.
     */
    public func toFloat16Array(width: Int, height: Int, featureChannels: Int) -> [Float16] {
        
        assert(featureChannels != 3 && featureChannels <= 4, "channels must be 1, 2, or 4")
        
        var bytes = [Float16](repeating: 0, count: width * height * featureChannels)
        let region = MTLRegionMake2D(0, 0, width, height)
        getBytes(&bytes, bytesPerRow: width * featureChannels * MemoryLayout<Float16>.stride,
                 from: region, mipmapLevel: 0)
        return bytes
    }
}
