//
//  Pentogon.swift
//  CutCha
//
//  Created by hansoong choong on 7/10/24.
//

import SwiftUI

struct PentagonWithRectangle: Shape {
    func path(in rect: CGRect) -> Path {
        let width = rect.width
        let height = rect.height
        
        // Calculate points for the pentagon
        let triangleHeight = height * 0.5 // Height of the pentagon
        
        let topPoint = CGPoint(x: width / 2, y: 0)
        let leftPoint = CGPoint(x: 0, y: triangleHeight)
        let rightPoint = CGPoint(x: width, y: triangleHeight)
        
        var path = Path()
        
        path.move(to: topPoint)
        path.addLine(to: leftPoint)
        path.addLine(to: rightPoint)
        path.closeSubpath()
        
        // Draw rectangle at the bottom
        path.addRect(CGRect(x: 0, y: triangleHeight, width: width, height: triangleHeight))
        
        return path
    }
}

//struct ContentView: View {
//    var body: some View {
//        PentagonWithRectangle()
//            .fill(Color.blue) // Fill color for the shape
//            .frame(width: 200, height: 200) // Set frame for the shape
//            .padding()
//    }
//}
