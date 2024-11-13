//
//  GradientShape.swift
//  CanvasEditor
//
//  Created by hansoong choong on 6/10/23.
//

import SwiftUI

struct GradientPattern: Codable {
    var colors : [Color] = [.red, .blue]
    var direction : [UnitPoint] = [.topLeading, .bottomTrailing]
    var locations : [CGFloat] = [0, 1]
    var type : GradientType = .linear
    
    mutating func insert(at index: Int) -> Int {
        let locations = self.locations
        let colors = self.colors
        if locations.count < 2  { return 0 }
            
        if index == 0 {
            self.colors.insert(Color.average(of: colors[0], and: colors[1]), at: 1)
            self.locations.insert(CGFloat((locations[0] + locations[1]) / 2), at: 1)
            return 1
        } else if index == locations.count - 1 {
            self.colors.insert(Color.average(of: colors[index - 1], and: colors[index]), at: index - 1)
            self.locations.insert(CGFloat((locations[index - 1] + locations[index]) / 2), at: index)
            return index
        } else {
            self.colors.insert(Color.average(of: colors[index], and: colors[index + 1]), at: index + 1)
            self.locations.insert(CGFloat((locations[index] + locations[index + 1]) / 2), at: index + 1)
            return index + 1
        }
    }
    
    mutating func remove(at index: Int) -> Int {
        
        if locations.count <= 2  { return 0 }
        
        self.colors.remove(at: index)
        self.locations.remove(at: index)
        return min(index, self.colors.count - 1)
    }
    
    func type(_ newType: GradientType) -> Self {
        var p = self
        p.type = newType
        if newType != .linear {
            p.direction = [.center]
        } else {
            p.direction = [.topLeading, .bottomTrailing]
        }
        return p
    }
    
    func fullColor() -> Self {
        var p = self
        p.colors = self.colors.map {
            $0.toOpacity(1.0)
        }
        return p
    }
    
    func gradiant(size: CGSize) -> any ShapeStyle {
        let stops: [Gradient.Stop] = zip(colors, locations).map { color, location in
                .init(color: color, location: location)
        }
        switch type {
        case .linear :
            return LinearGradient(
                stops: stops,
                startPoint: direction.first ?? .leading,
                endPoint: direction.last ?? .trailing
            )
        case .radial :
            return RadialGradient(
                stops: stops,
                center: direction.first ?? .center,
                startRadius: 0,
                endRadius: min(size.width/2, size.height/2)
            )
        case .angular :
            return AngularGradient(
                stops: stops,
                center: direction.first ?? .center,
                angle:.degrees(360)
            )
        }
    }
}

enum GradientType : String, Codable, CaseIterable, Identifiable {
    
    var id: Self { return self }
    
    case linear
    case radial
    case angular
}

extension GradientPattern {
    func image(in region: CGRect, with imageSize: CGSize = CGSize(width: 1, height: 1), baseImage: UIImage? = nil) -> UIImage {
        var colorImage  = GradientOnlyView(pattern: self).screenshot(of: .init(origin: .zero, size: imageSize))!
        //if baseImage != nil {
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 1.0)
        let areaSize = CGRect(origin: .zero, size: imageSize)
        if baseImage != nil {
            baseImage!.draw(in: areaSize)
        }
        colorImage.draw(in: region, blendMode: .normal, alpha: 0.85)
        colorImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        //}
        return colorImage
    }
    
    func image(path: CGPath, lineWidth: CGFloat = 1,
               with imageSize: CGSize = CGSize(width: 1, height: 1),
               baseImage: UIImage? = nil) -> UIImage {
        var colorImage  = GradientOnlyView(pattern: self, cgPath: path, lineWidth: lineWidth).screenshot(of: .init(origin: .zero, size: imageSize))!
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 1.0)
        let areaSize = CGRect(origin: .zero, size: imageSize)
        if baseImage != nil {
            baseImage!.draw(in: areaSize)
        }
        
        colorImage.draw(in: areaSize)
        colorImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        //}
        return colorImage
    }
}

extension View {
    func screenshot(of rect: CGRect) -> UIImage? {
        let window = UIWindow(frame: rect)
        let host = UIHostingController(rootView: self)
        window.addSubview(host.view)
        host.view.frame = window.frame
        return host.view.asImage
    }
}

extension UIView {
    var asImage: UIImage? {
        backgroundColor = .clear
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 1.0)
        defer { UIGraphicsEndImageContext() }
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        layer.render(in: context)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

extension UnitPoint {
    func cgPointWithSize(_ size: CGSize) -> CGPoint {
        .init(x: self.x * size.width, y: self.y * size.height)
    }
}
