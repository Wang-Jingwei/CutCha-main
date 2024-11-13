//
//  Extension.swift
//  Emoji Art
//
//  Created by CS193p Instructor on 5/8/23.
//  Copyright (c) 2023 Stanford University
//

import SwiftUI
import AVKit

/// coordinate
typealias CGOffset = CGSize

extension CGRect {
    var center: CGPoint {
        CGPoint(x: midX, y: midY)
    }
    init(center: CGPoint, size: CGSize) {
        self.init(origin: CGPoint(x: center.x-size.width/2, y: center.y-size.height/2), size: size)
    }
    
    var sizeString : String {
        "\(Int(self.width)) x \(Int(self.height))"
    }
    
    static func / (lhs: Self, rhs: CGFloat) -> CGRect {
        CGRect(origin: lhs.origin / rhs, size: lhs.size / rhs)
    }
    
    static func * (lhs: Self, rhs: CGFloat) -> CGRect {
        CGRect(origin: lhs.origin * rhs, size: lhs.size * rhs)
    }
}

extension CGPoint {
    static func - (lhs: Self, rhs: Self) -> CGSize {
        CGSize(width: lhs.x - rhs.x, height: lhs.y - rhs.y)
    }

    static func + (lhs: Self, rhs: CGSize) -> CGPoint {
        CGPoint(x: lhs.x + rhs.width, y: lhs.y + rhs.height)
    }

    static func - (lhs: Self, rhs: CGSize) -> CGPoint {
        CGPoint(x: lhs.x - rhs.width, y: lhs.y - rhs.height)
    }

    static func * (lhs: Self, rhs: CGFloat) -> CGPoint {
        CGPoint(x: lhs.x * rhs, y: lhs.y * rhs)
    }

    static func / (lhs: Self, rhs: CGFloat) -> CGPoint {
        CGPoint(x: lhs.x / rhs, y: lhs.y / rhs)
    }
    
    static prefix func - (me: Self) -> CGPoint {
        CGPoint(x: -1 * me.x, y: -1 * me.y)
    }
}

extension CGSize {
    // the center point of an area that is our size
    var center: CGPoint {
        CGPoint(x: width / 2, y: height / 2)
    }

    static func + (lhs: Self, rhs: Self) -> CGSize {
        CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }

    static func - (lhs: Self, rhs: Self) -> CGSize {
        CGSize(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
    }

    static func * (lhs: Self, rhs: CGFloat) -> CGSize {
        CGSize(width: lhs.width * rhs, height: lhs.height * rhs)
    }

    static func / (lhs: Self, rhs: CGFloat) -> CGSize {
        CGSize(width: lhs.width / rhs, height: lhs.height / rhs)
    }
    
    static func +=(lhs: inout CGOffset, rhs: CGOffset) {
        lhs = lhs + rhs
    }
    
    static func -=(lhs: inout CGOffset, rhs: CGOffset) {
        lhs = lhs - rhs
    }
}

/// string
extension String {
    // removes any duplicate Characters
    // preserves the order of the Characters
    var uniqued: String {
        // not super efficient
        // would only want to use it on small(ish) strings
        // and we wouldn't want to call it in a tight loop or something
        reduce(into: "") { sofar, element in
            if !sofar.contains(element) {
                sofar.append(element)
            }
        }
    }
    
    mutating func remove(_ ch: Character) {
        removeAll(where: { $0 == ch })
    }
    
    func convertToValidFileName() -> String {
        let invalidFileNameCharactersRegex = "[^a-zA-Z0-9_ ]+"
        let fullRange = startIndex..<endIndex
        let validName = replacingOccurrences(of: invalidFileNameCharactersRegex,
                                           with: "-",
                                        options: .regularExpression,
                                          range: fullRange)
        return validName
    }
}

extension Character {
    var isEmoji: Bool {
        // Swift does not have a way to ask if a Character isEmoji
        // but it does let us check to see if our component scalars isEmoji
        // unfortunately unicode allows certain scalars (like 1)
        // to be modified by another scalar to become emoji (e.g. 1️⃣)
        // so the scalar "1" will report isEmoji = true
        // so we can't just check to see if the first scalar isEmoji
        // the quick and dirty here is to see if the scalar is at least the first true emoji we know of
        // (the start of the "miscellaneous items" section)
        // or check to see if this is a multiple scalar unicode sequence
        // (e.g. a 1 with a unicode modifier to force it to be presented as emoji 1️⃣)
        if let firstScalar = unicodeScalars.first, firstScalar.properties.isEmoji {
            return (firstScalar.value >= 0x238d || unicodeScalars.count > 1)
        } else {
            return false
        }
    }
}

/// collection
extension Set where Element: Identifiable {
    mutating func toggleMembership(of element: Element) {
        if let index = index(matching: element) {
            remove(at: index)
        } else {
            insert(element)
        }
    }
}

extension Collection where Element: Identifiable {
    
    func index(matching element: Element) -> Self.Index? {
        firstIndex(where: { $0.id == element.id })
    }
}

extension Collection {
    // this will crash if after >= endIndex
    func suffix(after: Self.Index) -> Self.SubSequence {
        suffix(from: index(after: after))
    }
}

extension RangeReplaceableCollection where Element: Identifiable {
    mutating func remove(_ element: Element) {
        if let index = index(matching: element) {
            remove(at: index)
        }
    }
    
    mutating func removeElements(_ elements: [Element]) {
        for element in elements {
            remove(element)
        }
    }

    subscript(_ element: Element) -> Element {
        get {
            if let index = index(matching: element) {
                return self[index]
            } else {
                return element
            }
        }
        set {
            if let index = index(matching: element) {
                replaceSubrange(index ... index, with: [newValue])
            }
        }
    }
}

// the extensions below are just helpers for Sturldata
extension URL {
    var imageURL: URL {
        if let queryItems = URLComponents(url: self, resolvingAgainstBaseURL: true)?.queryItems {
            for queryItem in queryItems {
                if let value = queryItem.value, value.hasPrefix("http"), let imgurl = URL(string: value) {
                    return imgurl
                }
            }
        }
        return self
    }
    
    var dataSchemeImageData: Data? {
        let urlString = absoluteString
        // is this a data scheme url with some sort of image as the mime type?
        if urlString.hasPrefix("data:image") {
            // yes, find the comma that separates the meta info from the image data
            if let comma = urlString.firstIndex(of: ","), comma < urlString.endIndex {
                let meta = urlString[..<comma]
                // we can only handle base64 encoded data
                if meta.hasSuffix("base64") {
                    let data = String(urlString.suffix(after: comma))
                    // get the data
                    if let imageData = Data(base64Encoded: data) {
                        return imageData
                    }
                }
            }
        }
        // not a data scheme or the data doesn't seem to be a base64 encoded image
        return nil
    }
}

extension TimeInterval {

    func stringFromTimeInterval() -> String {

        let time = NSInteger(self + 0.5)

        if time == 0 { return "00:00" }
        //let ms = Int((self.truncatingRemainder(dividingBy: 1)) * 1000)
        let seconds = time % 60
        let minutes = (time / 60) % 60
        let hours = (time / 3600)
        
        if hours > 0 {
            return String(format: "%0.2d:%0.2d:%0.2d", hours, minutes,seconds)
        }
        return String(format: "%0.2d:%0.2d", minutes,seconds)

    }
}

extension UIImage {

    func image(in region: CGRect, with imageSize: CGSize = CGSize(width: 1, height: 1),
               baseImage: UIImage? = nil, blendMode : CGBlendMode = .normal, alpha : CGFloat = 1) -> UIImage {
        //if baseImage != nil {
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 1.0)
        let areaSize = CGRect(origin: .zero, size: imageSize)
        if baseImage != nil {
            baseImage!.draw(in: areaSize)
        }
        self.draw(in: region, blendMode: blendMode, alpha: alpha)
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        //}
        return colorImage
    }
    
    #if os(iOS)
    func maxLength(to length: CGFloat) -> UIImage {
        
        let imageHeight = self.size.height
        let imageWidth = self.size.width
        var newSize: CGSize
        
        if max(imageWidth, imageHeight) <= length {
            return self
        }
        
        if imageWidth > imageHeight {
            newSize = CGSize(width: length, height: imageHeight * length / imageWidth)
        } else {
            newSize = CGSize(width: imageWidth * length / imageHeight, height: length)
        }
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: newSize.width, height: newSize.height), true, 1.0)
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return resizedImage
        
    }


    func cropToSquare() -> UIImage? {
        guard let cgImage = self.cgImage else {
            return nil
        }
        var imageHeight = self.size.height
        var imageWidth = self.size.width

        if imageHeight > imageWidth {
            imageHeight = imageWidth
        }
        else {
            imageWidth = imageHeight
        }

        let size = CGSize(width: imageWidth, height: imageHeight)

        let x = ((CGFloat(cgImage.width) - size.width) / 2).rounded()
        let y = ((CGFloat(cgImage.height) - size.height) / 2).rounded()

        let cropRect = CGRect(x: x, y: y, width: size.height, height: size.width)
        if let croppedCgImage = cgImage.cropping(to: cropRect) {
            return UIImage(cgImage: croppedCgImage, scale: 0, orientation: self.imageOrientation)
        }

        return nil
    }

    func pixelBuffer() -> CVPixelBuffer? {
        let width = self.size.width
        let height = self.size.height
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
                     kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                         Int(width),
                                         Int(height),
                                         kCVPixelFormatType_32ARGB,
                                         attrs,
                                         &pixelBuffer)

        guard let resultPixelBuffer = pixelBuffer, status == kCVReturnSuccess else {
            return nil
        }

        CVPixelBufferLockBaseAddress(resultPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(resultPixelBuffer)

        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(data: pixelData,
                                      width: Int(width),
                                      height: Int(height),
                                      bitsPerComponent: 8,
                                      bytesPerRow: CVPixelBufferGetBytesPerRow(resultPixelBuffer),
                                      space: rgbColorSpace,
                                      bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue) else {
                                        return nil
        }

        context.translateBy(x: 0, y: height)
        context.scaleBy(x: 1.0, y: -1.0)

        UIGraphicsPushContext(context)
        self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(resultPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        //resultPixelBuffer.
        return resultPixelBuffer
    }

    var imageData: Data? { jpegData(compressionQuality: 1.0) }
    
    var fixedOrientation: UIImage {
        guard imageOrientation != .up else { return self }
        
        var transform: CGAffineTransform = .identity
        switch imageOrientation {
        case .down, .downMirrored:
            transform = transform
                .translatedBy(x: size.width, y: size.height).rotated(by: .pi)
        case .left, .leftMirrored:
            transform = transform
                .translatedBy(x: size.width, y: 0).rotated(by: .pi)
        case .right, .rightMirrored:
            transform = transform
                .translatedBy(x: 0, y: size.height).rotated(by: -.pi/2)
        case .upMirrored:
            transform = transform
                .translatedBy(x: size.width, y: 0).scaledBy(x: -1, y: 1)
        default:
            break
        }
        
        guard
            let cgImage = cgImage,
            let colorSpace = cgImage.colorSpace,
            let context = CGContext(
                data: nil, width: Int(size.width), height: Int(size.height),
                bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0,
                space: colorSpace, bitmapInfo: cgImage.bitmapInfo.rawValue
            )
        else { return self }
        context.concatenate(transform)
        
        var rect: CGRect
        switch imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            rect = CGRect(x: 0, y: 0, width: size.height, height: size.width)
        default:
            rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        }
        
        context.draw(cgImage, in: rect)
        return context.makeImage().map { UIImage(cgImage: $0) } ?? self
    }
    #endif
}

extension Font {
    static let appTextFont = Font.system(size: 10, weight: .regular)
    static let appTextBigFont = Font.system(size: 14, weight: .regular)
    static let appButtonBigFont = Font.system(size: 25, weight: .regular)
    static let appButtonListFont = Font.system(size: 30, weight: .regular)
    static let appButtonNormalFont = Font.system(size: 20, weight: .regular)
    static let appButtonNormal2Font = Font.system(size: 28, weight: .regular)
}

extension Color {
    static let appMain : Color = .hex("#FEAD38")
    static let appLightGray : Color = .hex("#C8C8C8")
    static let appDarkGray : Color = .hex("#1F1F1F")
    
    static let checkred : Color = Color(.systemRed)
    static let checkblue : Color = Color(.systemBlue)
    static let checkgreen : Color = Color(.systemGreen)
    static let checkcyan : Color = .cyan
    static let checkorange : Color = .orange
}

extension Angle {
  /// Returns an Angle in the range `0° ..< 360°`
  func normalized() -> Angle {
    var degrees = self.degrees.truncatingRemainder(dividingBy: 360)
    if degrees < 0 {
      degrees = degrees + 360
    }
    return Angle(degrees: degrees)
  }
    
    func normalizedDelta() -> Angle {
        var normalized = normalized()
        if normalized >= Angle(degrees: 180) {
          normalized = normalized - Angle(degrees: 360)
        }
        return normalized
      }
}
