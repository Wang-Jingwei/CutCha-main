//
//  MaskShape.swift
//  SegmentAnywhere
//
//  Created by hansoong choong on 9/11/23.
//

import SwiftUI
import Vision

struct MaskShape: Shape {
    
    let maskPath : Path?
        
    func path(in rect: CGRect) -> Path {
        // cgPath returned from Vision will be in rect (0, 0) - (1.0, 1.0) coordinates
        //  so we want to scale the path to our view bounds

        guard let maskPath = maskPath else { return Path() }
       
        // we need to invert the Y-coordinate space
        var transform = CGAffineTransform.identity
            .scaledBy(x: rect.width, y: rect.height)
            .concatenating(CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: rect.height))
        
        if let imagePath = maskPath.cgPath.copy(using: &transform) {
            return Path(imagePath)
        } else {
            return Path()
        }
    }
    
}
