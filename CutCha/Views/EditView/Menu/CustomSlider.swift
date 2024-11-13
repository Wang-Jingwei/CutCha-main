//
//  CustomSlider.swift
//  colorful-room
//
//  Created by macOS on 7/15/20.
//  Copyright © 2020 PingAK9. All rights reserved.
//

import SwiftUI

struct FilterSlider : View {
    var label:String
    var defaultValue:Double
    @Binding var value:Double
    var range: (Double, Double)
    var rangeDisplay: (Double, Double)
    var spacing:CGFloat
    var isDisplayValue: Bool
    var decimalPlace : Int
    let sliderGap: CGFloat
    var formatString : String
    
    init(value: Binding<Double>, range: (Double, Double) = (0, 1), label:String = "", 
         defaultValue: Double, rangeDisplay: (Double, Double) = (-100, 100),
         spacing:CGFloat = 4, isDisplayValue: Bool = true, decimalPlace: Int = 0, sliderGap: CGFloat = 10)
    {
        _value = value
        self.range = range
        self.label = label
        self.defaultValue = defaultValue
        self.rangeDisplay = rangeDisplay
        self.spacing = spacing
        self.isDisplayValue = isDisplayValue
        self.decimalPlace = decimalPlace
        self.sliderGap = sliderGap
        self.formatString = "%.\(decimalPlace)f"
    }
    
    var body: some View{
        
        VStack(spacing: spacing){
            HStack{
                if(label.isEmpty == false){
                    Text(label)
//                        .border(Color.checkred.opacity(0.5))
                }
                Spacer()
                
                if self.isDisplayValue {
                    Text(String(format: formatString, value))
//                        .border(Color.checkred.opacity(0.5))
                }
            }
            .font(.system(size: 12, weight: .regular))
            .foregroundColor(.white)
//            .border(Color.checkblue.opacity(0.5))
            
            CustomSlider(value: $value, defaultValue: defaultValue ,range: range) { modifiers in
                ZStack {
                    Color.white.cornerRadius(2).frame(height: 3.5).modifier(modifiers.bar)
//                    Circle()
//                        .fill(.white)
//                        .frame(height: 5)
//                        .modifier(modifiers.defaultDot)
                    ZStack {
                        Circle()
                            .fill(Color.appMain)
                            .frame(width: 15, height: 15)
//                        Circle().stroke(Color.appMain, lineWidth: 1)
                        
                    }.modifier(modifiers.knob)
                }
            }
            .frame(height: 15)
//            .border(Color.checkred.opacity(0.5))
            .padding([.leading, .trailing], sliderGap)
//            .border(Color.checkblue.opacity(0.5))
        }
    }
    
    func displayValue(_ value:Double) -> String{
        return String(format: "%.0f", value.convert(fromRange: range, toRange: rangeDisplay))
    }
}

struct CustomSlider<Component: View> : View {
    
    @EnvironmentObject var photoManager: PhotoManager
    @State var counter = 0
    @Binding var value: Double
    var defaultValue:Double
    var range: (Double, Double)
    var knobWidth: CGFloat?
    var dotWidth:  CGFloat = 5
    let viewBuilder: (CustomSliderComponents) -> Component
    
    init(value: Binding<Double>, defaultValue:Double = 0,range: (Double, Double), knobWidth: CGFloat? = nil,
         _ viewBuilder: @escaping (CustomSliderComponents) -> Component
    ) {
        _value = value
        self.range = range
        self.viewBuilder = viewBuilder
        self.knobWidth = knobWidth
        self.defaultValue = defaultValue
    }
    
    var body: some View {
        return GeometryReader { geometry in
            self.view(geometry: geometry) // function below
        }
    }
    
    private func view(geometry: GeometryProxy) -> some View {
        
        let frame = geometry.frame(in: .global)
        let drag = DragGesture(minimumDistance: 0).onChanged{ drag in
            if photoManager.appState.currentMenuType == .filter {
                if counter % 5 == 0 {
                    self.onDragChange(drag, frame)
                }
            } else {
                self.onDragChange(drag, frame)
            }
            counter = counter + 1
        }.onEnded { drag in
            counter = 0
        }
        
        let offsetX = self.getOffsetX(frame: frame)
        
        let offsetDefault = getOffsetXDefaultDot(frame: frame)
        
        
        let knobSize = CGSize(width: knobWidth ?? frame.height, height: frame.height)
         let barSize = CGSize(width: frame.width, height:  frame.height)
//        let barLeftSize = CGSize(width: CGFloat(offsetX + knobSize.width * 0.5), height:  frame.height)
//        let barRightSize = CGSize(width: frame.width - barLeftSize.width, height: frame.height)
        let dotSize = CGSize(width: dotWidth, height: frame.height)
        
        let modifiers = CustomSliderComponents(
            bar: CustomSliderModifier(name: .bar, size: barSize, offset: 0),
//            barLeft: CustomSliderModifier(name: .barLeft, size: barLeftSize, offset: 0),
//            barRight: CustomSliderModifier(name: .barRight, size: barRightSize, offset: barLeftSize.width),
            knob: CustomSliderModifier(name: .knob, size: knobSize, offset: offsetX),
            defaultDot: CustomSliderModifier(name: .defaultDot, size: dotSize, offset: offsetDefault)
            )
        
        
        return ZStack { viewBuilder(modifiers).gesture(drag) }
        
    }
    
    private func onDragChange(_ drag: DragGesture.Value,_ frame: CGRect) {
        let width = (knob: Double(knobWidth ?? frame.size.height), view: Double(frame.size.width))
        let xrange = (min: Double(0), max: Double(width.view - width.knob))
        var value = Double(drag.startLocation.x + drag.translation.width) // knob center x
        value -= 0.5*width.knob // offset from center to leading edge of knob
        value = value > xrange.max ? xrange.max : value // limit to leading edge
        value = value < xrange.min ? xrange.min : value // limit to trailing edge
        value = value.convert(fromRange: (xrange.min, xrange.max), toRange: range)
        self.value = value
    }
    
    private func getOffsetX(frame: CGRect) -> CGFloat {
        let width = (knob: knobWidth ?? frame.size.height, view: frame.size.width)
        let xrange: (Double, Double) = (0, Double(width.view - width.knob))
        let result = self.value.convert(fromRange: range, toRange: xrange)
        return CGFloat(result)
    }
    private func getOffsetXDefaultDot(frame: CGRect) -> CGFloat {
        let width = (knob: dotWidth, view: frame.size.width)
        let xrange: (Double, Double) = (0, Double(width.view - width.knob))
        let result = self.defaultValue.convert(fromRange: range, toRange: xrange)
        return CGFloat(result)
    }
}

struct CustomSliderComponents {
//    let barLeft: CustomSliderModifier
//    let barRight: CustomSliderModifier
    
    let bar: CustomSliderModifier
    let knob: CustomSliderModifier
    let defaultDot: CustomSliderModifier
}

struct CustomSliderModifier: ViewModifier {
    enum Name {
//        case barLeft
//        case barRight
        
        case bar
        case knob
        case defaultDot
    }
    
    let name: Name
    let size: CGSize
    let offset: CGFloat
    
    func body(content: Content) -> some View {
        content
            .frame(width: size.width)
            .position(x: size.width*0.5, y: size.height*0.5)
            .offset(x: offset)
    }
}

extension Double {
    func convert(fromRange: (Double, Double), toRange: (Double, Double)) -> Double {
        // Example: if self = 1, fromRange = (0,2), toRange = (10,12) -> solution = 11
        var value = self
        value -= fromRange.0
        value /= Double(fromRange.1 - fromRange.0)
        value *= toRange.1 - toRange.0
        value += toRange.0
        return value
    }
}
