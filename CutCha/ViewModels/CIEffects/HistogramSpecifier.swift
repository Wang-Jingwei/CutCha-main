/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The histogram specifier class.
*/

import Foundation
import SwiftUI
import Accelerate

class HistogramSpecifier: ObservableObject, FilterModel {
    
    var photoManager : PhotoManager
    @Published var histogramSamples: [UIImage] = []
    
    init(photoManager : PhotoManager) {
        self.photoManager = photoManager
        self.photoManager.histogramSpecifier = self
        histogramSamples.append(UIImage(named: "H1")!)
        histogramSamples.append(UIImage(named: "H2")!)
        histogramSamples.append(UIImage(named: "H3")!)
    }

    func updateDisplayImage() {
        self.photoManager.updateDisplayImage(usingModel: self)
    }
    
    
    struct Image: Identifiable, Hashable {
        let id = UUID()
        var cgImage: CGImage
    }
    
    @Published var outputImage: CGImage!
    
    func proceed(histogramSourceImage: CGImage,
                 imageSourceImage: CGImage) {
        outputImage = applyHistogramSpecification(
                    histogramSourceImage: histogramSourceImage,
                    imageSourceImage: imageSourceImage)
        updateDisplayImage()
    }
    
    var imageFormat = vImage_CGImageFormat(
        bitsPerComponent: 8,
        bitsPerPixel: 8 * 4,
        colorSpace: CGColorSpaceCreateDeviceRGB(),
        bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipLast.rawValue))!
    
    /// A Boolean value that specifies whether to use the `vImage.PixelBuffer` or the `vImage_Buffer`
    /// version of the histogram specification operation.
    let usePixelBuffer = true
    
    /// Performs a histogram specification operation.
    func applyHistogramSpecification(histogramSourceImage: CGImage,
                                            imageSourceImage: CGImage) -> CGImage {
        if usePixelBuffer {
            return applyHistogramSpecification_PixelBuffer(
                histogramSourceImage: histogramSourceImage,
                imageSourceImage: imageSourceImage)
        } else {
            return applyHistogramSpecification_vImageBuffer(
                histogramSourceImage: histogramSourceImage,
                imageSourceImage: imageSourceImage)
        }
    }
    
    /// Performs a histogram specification operation using `vImage.PixelBuffer` structures.
    func applyHistogramSpecification_PixelBuffer(
        histogramSourceImage: CGImage,
        imageSourceImage: CGImage) -> CGImage {
            
            let histogramSource = try! vImage.PixelBuffer<vImage.Interleaved8x4>(
                cgImage: histogramSourceImage,
                cgImageFormat: &imageFormat)
            
            let imageSource = try! vImage.PixelBuffer<vImage.Interleaved8x4>(
                cgImage: imageSourceImage,
                cgImageFormat: &imageFormat)
            
            let destinationBuffer = vImage.PixelBuffer<vImage.Interleaved8x4>(
                size: imageSource.size)
            
            let histogram = histogramSource.histogram()
            
            imageSource.specifyHistogram(histogram, destination: destinationBuffer)
            
            return destinationBuffer.makeCGImage(cgImageFormat: imageFormat)!
        }
    
    /// Performs a histogram specification operation using `vImage_Buffer` structures.
    func applyHistogramSpecification_vImageBuffer(
        histogramSourceImage: CGImage,
        imageSourceImage: CGImage) -> CGImage {
            
            // Create `vImage_Buffer` structures.
            
            var histogramSource = vImage_Buffer()
            vImageBuffer_InitWithCGImage(&histogramSource,
                                         &imageFormat,
                                         [0],
                                         histogramSourceImage,
                                         vImage_Flags(kvImageNoFlags))
            
            var imageSource = vImage_Buffer()
            vImageBuffer_InitWithCGImage(&imageSource,
                                         &imageFormat,
                                         [0],
                                         imageSourceImage,
                                         vImage_Flags(kvImageNoFlags))
            
            var destinationBuffer = vImage_Buffer()
            vImageBuffer_Init(&destinationBuffer,
                              imageSource.height,
                              imageSource.width,
                              8 * 4,
                              vImage_Flags(kvImageNoFlags))
            
            defer {
                histogramSource.data.deallocate()
                imageSource.data.deallocate()
                destinationBuffer.data.deallocate()
            }
            
            // Calculate the reference image histogram.
            
            var histogramBinZero = [vImagePixelCount](repeating: 0, count: 256)
            var histogramBinOne = [vImagePixelCount](repeating: 0, count: 256)
            var histogramBinTwo = [vImagePixelCount](repeating: 0, count: 256)
            var histogramBinThree = [vImagePixelCount](repeating: 0, count: 256)
            
            histogramBinZero.withUnsafeMutableBufferPointer { zeroPtr in
                histogramBinOne.withUnsafeMutableBufferPointer { onePtr in
                    histogramBinTwo.withUnsafeMutableBufferPointer { twoPtr in
                        histogramBinThree.withUnsafeMutableBufferPointer { threePtr in
                            
                            var histogramBins = [zeroPtr.baseAddress, onePtr.baseAddress,
                                                 twoPtr.baseAddress, threePtr.baseAddress]
                            
                            histogramBins.withUnsafeMutableBufferPointer { histogramBinsPtr in
                                let error = vImageHistogramCalculation_ARGB8888(&histogramSource,
                                                                                histogramBinsPtr.baseAddress!,
                                                                                vImage_Flags(kvImageNoFlags))
                                
                                guard error == kvImageNoError else {
                                    fatalError("Error calculating histogram: \(error)")
                                }
                            }
                        }
                    }
                }
            }

            // Specify the input image histogram.
            
            histogramBinZero.withUnsafeBufferPointer { zeroPtr in
                histogramBinOne.withUnsafeBufferPointer { onePtr in
                    histogramBinTwo.withUnsafeBufferPointer { twoPtr in
                        histogramBinThree.withUnsafeBufferPointer { threePtr in
                            
                            var histogramBins = [zeroPtr.baseAddress, onePtr.baseAddress,
                                                 twoPtr.baseAddress, threePtr.baseAddress]
                            
                            histogramBins.withUnsafeMutableBufferPointer { histogramBinsPtr in
                                let error = vImageHistogramSpecification_ARGB8888(&imageSource,
                                                                                  &destinationBuffer,
                                                                                  histogramBinsPtr.baseAddress!,
                                                                                  vImage_Flags(kvImageNoFlags))
                                
                                guard error == kvImageNoError else {
                                    fatalError("Error specifying histogram: \(error)")
                                }
                            }
                        }
                    }
                }
            }
            
            // Return a `CGImage` that represents the histogram specification result.
            
            return vImageCreateCGImageFromBuffer(&destinationBuffer,
                                                 &imageFormat, nil, nil,
                                                 vImage_Flags(kvImageNoFlags),
                                                 nil).takeRetainedValue()
        }
}
