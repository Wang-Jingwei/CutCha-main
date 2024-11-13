//
//  UIKitMainImageViewInPaintingExtension.swift
//  SegmentAnywhere
//
//  Created by hansoong choong on 29/2/24.
//

import SwiftUI

extension UIKitMaskEditImageView {
    
    var rotationGesture: some Gesture {
        RotateGesture()
            .onChanged { value in
                if photoManager.masking.maskToolOption == .MOVE_OBJECT {
                    objectAngle = previousObjectAngle + value.rotation.normalized()
                }
            }
            .onEnded { _ in
                if photoManager.masking.maskToolOption == .MOVE_OBJECT {
                    previousObjectAngle = objectAngle
                    if objectAngle.degrees > 0 {
                        photoManager.inPainting.canApplyInPainting = true
                    }
                }
            }
    }
    
    var dragGesture : some Gesture {
        DragGesture()
            .onChanged { value in
                self.currentDragOffset = value.translation
                
                objectBoundary = CGRect(x: currentObjectBoundary.origin.x + self.currentDragOffset.width,
                                        y: currentObjectBoundary.origin.y + self.currentDragOffset.height,
                                        width: currentObjectBoundary.size.width,
                                        height: currentObjectBoundary.size.height)
                //let _ = print("obj1 = \(objectBoundary) - \(objectBoundary.center)")
            }
            .onEnded {_ in
                self.dragOffset += currentDragOffset
                self.currentDragOffset = .zero
                
                if dragOffset != .zero {
                    photoManager.inPainting.canApplyInPainting = true
                }
                
                currentObjectBoundary = objectBoundary
                if photoManager.inPainting.inPaintingBaseImage != nil {
                    photoManager.inPainting.inPaintingResultImage = ImageRenderer(content: self.inPaintingView(isSnapShot: true)).uiImage
                }
            }
    }
        
    @ViewBuilder
    var magicView : some View {
        ZStack {
            if photoManager.inPainting.inPaintingBaseImage == nil {
                Rectangle()
                    .mask(photoManager.maskShape)
            } else {
                Image(uiImage: photoManager.inPainting.inPaintingBaseImage!)
                    //.mask(photoManager.maskShape)
            }
                
        }
        .onChange(of: photoManager.inPainting.inPaintingBaseImage) {
            if photoManager.inPainting.inPaintingBaseImage == nil {
                self.dragOffset = .zero
                self.currentDragOffset = .zero
                self.objectAngle = Angle(degrees: 0.0)
                photoManager.inPainting.canApplyInPainting = false
            } else {
                photoManager.inPainting.inPaintingResultImage = ImageRenderer(content: self.inPaintingView(isSnapShot: true)).uiImage
            }
        }
    }
    
    /// center to offset, using device coordinate, origin at left corner
    func getOffsetFromDirection(boundary: CGRect, index : Int) -> CGSize {
        let direction = Direction(rawValue: index)!
        let size = boundary.size
        
        switch direction {
            case .top:
            return CGSize(width: 0, height: -size.height / 2)
            case .topLeft:
            return CGSize(width: -size.width / 2, height: -size.height / 2)
            case .left:
            return CGSize(width:  -size.width / 2, height: 0)
            case .bottomLeft:
            return CGSize(width: -size.width / 2, height: size.height / 2)
            case .bottom:
            return CGSize(width: 0, height: size.height / 2)
            case .bottomRight:
            return CGSize(width: size.width / 2, height: size.height / 2)
            case .right:
            return CGSize(width: size.width / 2, height: 0)
            case .topRight:
            return CGSize(width: size.width / 2, height: -size.height / 2)
        }
    }
    
    func getActualTransform(of offset:CGSize, direction: Direction) -> (CGSize, CGSize) {
        switch direction {
            
        case .top:
            return (.init(width: 0, height: offset.height), .init(width: 0, height: -offset.height))
        case .topLeft:
            return (.init(width: offset.width, height: offset.height), .init(width: -offset.width, height: -offset.height))
        case .left:
            return (.init(width: offset.width, height: 0), .init(width: -offset.width, height: 0))
        case .bottomLeft:
            return (.init(width: offset.width, height: 0), .init(width: -offset.width, height: offset.height))
        case .bottom:
            return (.init(width: 0, height: 0), .init(width: 0, height: offset.height))
        case .bottomRight:
            return (.init(width: 0, height: 0), .init(width: offset.width, height: offset.height))
        case .right:
            return (.init(width: 0, height: 0), .init(width: offset.width, height: 0))
        case .topRight:
            return (.init(width: 0, height: offset.height), .init(width: offset.width, height: -offset.height))
        }
    }
    
    func transformGesture(index : Int) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged({ (touch) in
                elementTransform = (.init(rawValue: index), touch.translation)
                let direction = elementTransform.0!
                let min_size = UILayout.Min_Control_Size
                let (s1, s2) = getActualTransform(of: elementTransform.1, direction: direction)
                
                var x = currentObjectBoundary.origin.x + s1.width
                var y = currentObjectBoundary.origin.y + s1.height
                
                let width = currentObjectBoundary.size.width + s2.width
                let height = currentObjectBoundary.size.height + s2.height
                
                if width < min_size {
                    if direction == .bottomRight || direction == .right || direction == .topRight {
                        x = currentObjectBoundary.origin.x
                    } else if direction == .bottomLeft || direction == .left || direction == .topLeft {
                        x = currentObjectBoundary.origin.x + currentObjectBoundary.size.width - min_size
                    }
                }
                
                if height < min_size {
                    if direction == .bottomRight || direction == .bottomLeft || direction == .bottom {
                        y = currentObjectBoundary.origin.y
                    } else if direction == .topLeft || direction == .topRight || direction == .top {
                        y = currentObjectBoundary.origin.y + currentObjectBoundary.size.height - min_size
                    }
                }
                
                objectBoundary = CGRect(x: x,
                                        y: y,
                                        width: width < min_size ? min_size : width,
                                        height: height < min_size ? min_size : height)
                
            })
            .onEnded({ (touch) in
                currentObjectBoundary = objectBoundary
                elementTransform = (nil, .zero)
                photoManager.inPainting.canApplyInPainting = true
                if photoManager.inPainting.inPaintingBaseImage != nil {
                    photoManager.inPainting.inPaintingResultImage = ImageRenderer(content: self.inPaintingView(isSnapShot: true)).uiImage
                }
            })
    }
}
