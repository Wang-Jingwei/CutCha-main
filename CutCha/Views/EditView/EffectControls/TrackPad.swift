//
//  TrackPad.swift
//  SegmentAnywhere
//
//  Created by hansoong choong on 21/5/24.
//

import SwiftUI

struct TrackPad: View {
    @Binding var xyRatio : [CGPoint]
    @State var positions : [CGPoint] = []
    @State var radius: CGFloat = 1
    var keepBackground: Bool = true
    var biggerSize : Bool = false
    
    var body: some View {
        GeometryReader { geo in
            Rectangle()
                .fill(keepBackground ? Color.appDarkGray : Color.clear)
                .stroke(Color.white, lineWidth: 2)
                .frame(width: geo.size.width, height: geo.size.height)
                .overlay(
                    ZStack {
                        Rectangle()
                            .stroke(keepBackground ? Color.appLightGray : Color.clear, lineWidth: 1)
                            .padding([.horizontal], radius)
                            .padding([.vertical], radius)
                        circles(geo: geo)
                    }
                ).onAppear {
                    self.radius = min(geo.size.width / 8, geo.size.height / 8)
                    if biggerSize {
                        self.radius = min(geo.size.width / 6, geo.size.height / 6)
                    }
                    for index in 0 ..< xyRatio.count {
                        let limitedX = max(min(xyRatio[index].x * geo.size.width, geo.size.width - radius), radius)
                        let limitedY = max(min(xyRatio[index].y * geo.size.height, geo.size.height - radius), radius)
                        
                        self.positions.append(.init(x: limitedX, y: limitedY))
                    }
                }
        }
    }
    
    @ViewBuilder
    func circles(geo: GeometryProxy) -> some View {
        ForEach(0 ..< positions.count, id:\.self) { index in
            Circle()
                .stroke(keepBackground ? Color.clear : Color.white, lineWidth: 3)
                .fill(Color.appMain)
                .frame(width: 2 * radius, height: 2 * radius)
                .position(positions[index])
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            // limit movement to min and max value
                            let limitedX = max(min(value.location.x, geo.size.width - radius), radius)
                            let limitedY = max(min(value.location.y, geo.size.height - radius), radius)
                            
                            self.positions[index] = CGPoint(x: limitedX, y: limitedY)
                            self.xyRatio[index] = CGPoint(x: (limitedX - radius) / (geo.size.width - 2 * radius),
                                                          y: (limitedY - radius) / (geo.size.height - 2 * radius))
                        }
                )
        }
    }
}
