//
//  LandingPage2.swift
//  SegmentAnywhere
//
//  Created by hansoong choong on 11/3/24.
//

import SwiftUI
//import Giffy

struct LandingPage2: View {
    
    @EnvironmentObject var photoManager:PhotoManager
    
    @State private var scale = 0.7
    @Binding var isActive: Bool
    @Binding var presentLibrary : Bool
    @State private var flag = false
    
    var body: some View {
        ZStack {
            //Image(uiImage: UIImage(named: "GetStarted-Background")!)
            Rectangle().foregroundColor(.black)
            VStack {
                Image(uiImage: UIImage(named: "cutcha-app-icon")!)
                    .resizable()
                    .frame(maxWidth: 100, maxHeight: 100)
                Text("CutCha")
                    .foregroundStyle(photoManager.appState.imageState == .empty ? .white : Color.appMain)
                    .font(.largeTitle)
                    .animation(.easeInOut.speed(0.5), value: photoManager.appState.imageState)
            }
            .scaleEffect(scale)
            .onTapGesture {
                presentLibrary = true
            }
        }
        .onAppear {
            withAnimation(.easeIn(duration: 0.7)) {
                self.scale = 1.0
                //self.flag.toggle()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation {
                    self.isActive = true
                    self.presentLibrary = true
                }
            }
            DispatchQueue.global(qos: .userInteractive).async {
                let _ = EdgeSAMImageSegmenter.shared
            }
        }
    }
}

extension Double {
    var rad: Double { return self * .pi / 180 }
    var deg: Double { return self * 180 / .pi }
}

struct WaveText: View {
    let text: String
    let pct: Double
    let waveWidth: Int
    var size: CGFloat
    
    init(_ text: String, waveWidth: Int, pct: Double, size: CGFloat = 34) {
        self.text = text
        self.waveWidth = waveWidth
        self.pct = pct
        self.size = size
    }
    
    var body: some View {
        Text(text).foregroundColor(Color.clear).modifier(WaveTextModifier(text: text, waveWidth: waveWidth, pct: pct, size: size))
    }
    
    struct WaveTextModifier: AnimatableModifier {
        let text: String
        let waveWidth: Int
        var pct: Double
        var size: CGFloat
        
        var animatableData: Double {
            get { pct }
            set { pct = newValue }
        }
        
        func body(content: Content) -> some View {
            
            HStack(spacing: 0) {
                ForEach(Array(text.enumerated()), id: \.0) { (n, ch) in
                    Text(String(ch))
                        .font(Font.custom("Menlo", size: self.size).bold())
                        .scaleEffect(self.effect(self.pct, n, self.text.count, Double(self.waveWidth)))
                }
            }
        }
        
        func effect(_ pct: Double, _ n: Int, _ total: Int, _ waveWidth: Double) -> CGFloat {
            let n = Double(n)
            let total = Double(total)
            
            return CGFloat(1 + valueInCurve(pct: pct, total: total, x: n/total, waveWidth: waveWidth))
        }
        
        func valueInCurve(pct: Double, total: Double, x: Double, waveWidth: Double) -> Double {
            let chunk = waveWidth / total
            let m = 1 / chunk
            let offset = (chunk - (1 / total)) * pct
            let lowerLimit = (pct - chunk) + offset
            let upperLimit = (pct) + offset

            guard x >= lowerLimit && x < upperLimit else { return 0 }
            
            let angle = ((x - pct - offset) * m)*360-90
            
            return (sin(angle.rad) + 1) / 2
        }
    }
}
