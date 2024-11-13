//
//  DrawingHelperView.swift
//  CanvasEditor
//
//  Created by hansoong choong on 20/10/23.
//

import SwiftUI

typealias DragCallBack = (_ index : Int, _ transform: CGSize, _ done : Bool) -> Void

struct ControlBox : Shape {
    let boundary : CGRect
    
    func path(in rect: CGRect) -> Path {
        
        return Path(boundary)
    }
    
    
}


struct SelectionConfig {

    static let radius: CGFloat = 8.0
    static let lineWidth : CGFloat = 4.0
    static let dashSize : CGFloat = 5.0

    var offset: CGPoint

    var size: CGSize

    var graphicBounds: CGRect {
        CGRect(origin: .zero, size: size)
    }

    var graphicFrame: CGRect {
        CGRect(origin: offset, size: size)
    }

    var selectionBounds: CGRect {
        CGRect(origin: .zero, size: size)
    }

    var selectionFrame: CGRect {
        CGRect(origin: offset, size: size)
    }

    var position: CGPoint {
        graphicFrame.origin
    }

    var selectionPosition: CGPoint {
        selectionFrame.origin
    }

    func rect(direction: Direction) -> CGRect {
        rect(direction: direction, in: graphicBounds)
    }

    func rect(direction: Direction, in bounds: CGRect) -> CGRect {

        let size = CGSize(width: SelectionConfig.radius * 2.0, height: SelectionConfig.radius * 2.0)
        let origin: CGPoint

        switch direction {
            case .top:
                origin = CGPoint(x: bounds.midX - SelectionConfig.radius, y: bounds.minY - SelectionConfig.radius)
            case .topLeft:
                origin = CGPoint(x: bounds.minX - SelectionConfig.radius, y: bounds.minY - SelectionConfig.radius)
            case .left:
                origin = CGPoint(x: bounds.minX - SelectionConfig.radius, y: bounds.midY - SelectionConfig.radius)
            case .bottomLeft:
                origin = CGPoint(x: bounds.minX - SelectionConfig.radius, y: bounds.maxY - SelectionConfig.radius)
            case .bottom:
                origin = CGPoint(x: bounds.midX - SelectionConfig.radius, y: bounds.maxY - SelectionConfig.radius)
            case .bottomRight:
                origin = CGPoint(x: bounds.maxX - SelectionConfig.radius, y: bounds.maxY - SelectionConfig.radius)
            case .right:
                origin = CGPoint(x: bounds.maxX - SelectionConfig.radius, y: bounds.midY - SelectionConfig.radius)
            case .topRight:
                origin = CGPoint(x: bounds.maxX - SelectionConfig.radius, y: bounds.minY - SelectionConfig.radius)
        }

        return CGRect(origin: origin, size: size)
    }
}

struct SelectionBorder: Shape {

    let boundary : CGRect
    
    private struct Segment {

        /// Point to connect with previous segment
        var from: CGPoint

        /// Point to connect with next segment
        var to: CGPoint
    }

    func path(in rect: CGRect) -> Path {

        let diameter = SelectionConfig.radius * 2.0

        let segments: [Segment] = [
            // Top-Left to Top-Right
            Segment(from: CGPoint(x: boundary.minX + diameter, y: boundary.minY),
                    to: CGPoint(x: boundary.midX - SelectionConfig.radius, y: boundary.minY)),

            Segment(from: CGPoint(x: boundary.midX + SelectionConfig.radius, y: boundary.minY),
                    to: CGPoint(x: boundary.maxX - diameter, y: boundary.minY)),

            // Top-Right to Bottom-Left
            Segment(from: CGPoint(x: boundary.maxX, y: boundary.minY + diameter),
                    to: CGPoint(x: boundary.maxX, y: boundary.midY - SelectionConfig.radius)),

            Segment(from: CGPoint(x: boundary.maxX, y: boundary.midY + SelectionConfig.radius),
                    to: CGPoint(x: boundary.maxX, y: boundary.maxY - diameter)),

            // Bottom-Right to Bottom-Left
            Segment(from: CGPoint(x: boundary.maxX - diameter, y: boundary.maxY),
                    to: CGPoint(x: boundary.midX + SelectionConfig.radius, y: boundary.maxY)),

            Segment(from: CGPoint(x: boundary.midX - SelectionConfig.radius, y: boundary.maxY),
                    to: CGPoint(x: boundary.minX + diameter, y: boundary.maxY)),

            // Bottom-Left to Top-Left
            Segment(from: CGPoint(x: boundary.minX, y: boundary.maxY - diameter),
                    to: CGPoint(x: boundary.minX, y: boundary.midY + SelectionConfig.radius)),

            Segment(from: CGPoint(x: boundary.minX, y: boundary.midY - SelectionConfig.radius),
                    to: CGPoint(x: boundary.minX, y: boundary.minY + diameter))
        ]

        var path = Path()

        for segment in segments {
            path.move(to: segment.from)
            path.addLine(to: segment.to)
        }

        return path
    }
}

struct SelectionControls: Shape {

    let boundary : CGRect
    
    func path(in rect: CGRect) -> Path {

        let proxy : SelectionConfig = .init(offset: boundary.center, size: boundary.size)
        
        var path = Path()

        let controls = Direction.allCases.map {
            proxy.rect(direction: $0, in: boundary)
        }

        for control in controls {
            path.addEllipse(in: control)
        }

        return path
    }
}

struct Triangle8ControlsView : View {
    
    let proxy: SelectionConfig
    //let rects : [CGRect]

    var body: some View {
        GeometryReader { geometry in
            ForEach (Direction.allCases, id : \.self) {
                let rect = proxy.rect(direction: $0, in: geometry.frame(in: .local))
                Image(systemName: "arrow.up.and.down.and.arrow.left.and.right")
                    .foregroundColor(.red)
                    .bold()
                    .frame(width: rect.width, height: rect.height)
                    .position(rect.center)
            }
        }
    }
    
}

struct Triangle8Controls : Shape {
    let proxy: SelectionConfig

    func path(in rect: CGRect) -> Path {

        var path = Path()

        let controls = Direction.allCases.map {
            proxy.rect(direction: $0, in: rect)
        }

        for control in controls {
            path.addEllipse(in: control)
//            path.move(to: control.origin)
//            path.addLine(to: CGPoint(x: control.maxX, y: control.maxY))
//            path.move(to: CGPoint(x: control.maxX, y: control.minY))
//            path.addLine(to: CGPoint(x: control.minX, y: control.maxY))
        }

        return path
    }
}

/// Drag direction, counter clockwise
enum Direction: Int, CaseIterable {

    case top = 0

    case topLeft

    case left

    case bottomLeft

    case bottom

    case bottomRight

    case right

    case topRight
}

enum SelectState : Int {
    case None
    case Selected
}
