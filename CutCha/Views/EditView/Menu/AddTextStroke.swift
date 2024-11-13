//
//  AddTextBorder.swift
//  SegmentAnywhere
//
//  Created by vh on 27/4/24.
//

import Foundation
import SwiftUI

extension View {
    func stroke(textBorderColor: Color, textBorderWidth: CGFloat, shadowArg: (BindType, BindType, BindType), shadowColor: Color) -> some View {
        modifier(StrokeModifier(strokeSize: textBorderWidth, strokeColor: textBorderColor, shadowArg: shadowArg, shadowColor: shadowColor))
    }
}

struct StrokeModifier: ViewModifier {
    private let id = UUID()
    var strokeSize: CGFloat
    var strokeColor: Color
    var shadowArg: (BindType, BindType, BindType)
    var shadowColor: Color
    
    func body(content: Content) -> some View {
        if strokeSize > 0 {
            appliedStrokeBackground(content: content)
        } else {
            content
        }
    }

    private func appliedStrokeBackground(content: Content) -> some View {
        content
            .padding(strokeSize*2)
            .background(
                Rectangle()
                    .foregroundColor(strokeColor)
                    .mask(alignment: .center) {
                        mask(content: content)
                    }
                    .shadow(color: shadowColor, radius:  CGFloat(shadowArg.2), x: CGFloat(shadowArg.0), y:  CGFloat(-(shadowArg.1)))
            )
    }

    func mask(content: Content) -> some View {
        Canvas { context, size in
            context.addFilter(.alphaThreshold(min: 0.01))
            if let resolvedView = context.resolveSymbol(id: id) {
                context.draw(resolvedView, at: .init(x: size.width/2, y: size.height/2))
            }
        } symbols: {
            content
                .tag(id)
                .blur(radius: strokeSize/2)
        }
    }
}
