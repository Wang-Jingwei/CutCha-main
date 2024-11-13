//
//  GradientPatternView.swift
//  CutCha
//
//  Created by hansoong choong on 1/10/24.
//

import SwiftUI

struct FillGradientView : View {
    @EnvironmentObject var fillVM:FillBackgroundViewModel
    @State var pattern: GradientPattern = .init()
    
    @State var xyRatioLinear : [CGPoint] = [.init(x: 0.0, y: 0.0), .init(x: 1.0, y: 1.0)]
    @State var xyRatioAngular : [CGPoint] = [.init(x: 0.5, y: 0.5)]
    @State var xyRatioRadial : [CGPoint] = [.init(x: 0.5, y: 0.5)]
    @State var opacity : Double = 1.0
    @State var isEditing: Bool = false
    let boxWidth : CGFloat = 75
     
    func getXyRatioBinding(for type: GradientType) -> Binding<[CGPoint]> {
        switch type {
        case .linear:
            return $xyRatioLinear
        case .radial:
            return $xyRatioRadial
        case .angular:
            return $xyRatioAngular
            
        }
    }
    
    func getXyRatio(for type: GradientType) -> [CGPoint] {
        switch type {
        case .linear:
            return xyRatioLinear
        case .radial:
            return xyRatioRadial
        case .angular:
            return xyRatioAngular
            
        }
    }
    
    var body: some View {
        
        GeometryReader { metrics in
            if isEditing {
                    GradientEditView(pattern: $pattern,
                                     isEditing: $isEditing,
                                     directions: getXyRatioBinding(for: pattern.type),
                                     size: metrics.size)
                        .frame(maxWidth: .infinity)
                        .transition(.move(edge: .trailing))
            } else {
                VStack {
                    //Spacer()
                    HStack {
                        Toggle(isOn: $fillVM.keepBackground) {
                            Text("Keep Background")
                                .font(.system(size: 10, weight: .regular))
                                .foregroundColor(.white)
                        }
                        .toggleStyle(iOSCheckboxToggleStyle())
                        Spacer()
                        Toggle(isOn: $fillVM.strokeOnly) {
                            Text("Stroke")
                                .font(.system(size: 10, weight: .regular))
                                .foregroundColor(.white)
                        }
                        .toggleStyle(iOSCheckboxToggleStyle())
                        Picker("", selection: $fillVM.lineWidth) {
                            ForEach(1 ..< 101, id: \.self) { index in
                                Text("\(index)")
                            }
                        }
                        .tint(.white)
                        .scaleEffect(0.8)
                        .disabled(!fillVM.strokeOnly)
                        
                        Spacer()
                        
                        FilterSlider(value: $opacity, range: (0, 1),
                                     defaultValue: 1, rangeDisplay: (0, 100), isDisplayValue: false, decimalPlace: 2)
                    }
                    HStack {
                        ForEach(GradientType.allCases) { item in
                            ZStack {
                                GradientOnlyView(pattern: pattern.type(item))
                                    .border(item == pattern.type ? Color.appMain : .clear, width: 2)
                                    .cornerRadius(5)
                                    .tag(item)
                                    .frame(width: boxWidth, height: boxWidth)
                                    .onTapGesture {
                                        withAnimation {
                                            if pattern.type != item {
                                                pattern.type = item
                                                pattern.direction = getXyRatio(for:item).map {
                                                    .init(x: $0.x, y: $0.y)
                                                }
                                            }
                                        }
                                    }
                                TrackPad(xyRatio: getXyRatioBinding(for: item), keepBackground: false, biggerSize: true)
                                    .frame(width: boxWidth, height: boxWidth)
                                    .opacity(item == pattern.type ? 1 : 0)
                            }
                        }
                        Spacer()
                        Button(action : {
                            withAnimation {
                                isEditing.toggle()
                            }
                        }) {
                            VStack {
                                Image(systemName: "arrowshape.turn.up.forward")
                                Spacer()
                                Text("More options")
                                    .appTextStyle()
                                    
                            }
                        }.foregroundStyle(Color.appLightGray)
                            .frame(height: 45)
                        Spacer()
                    }.frame(maxWidth : .infinity)
                    Spacer()
                }.transition(.move(edge: .leading))
            }
        }
        .onChange(of: pattern.type) {
            valueChanged()
        }
        .onChange(of: opacity) {
            valueChanged()
        }
        .onChange(of: xyRatioLinear) {
            valueChanged()
        }
        .onChange(of: xyRatioRadial) {
            valueChanged()
        }
        .onChange(of: xyRatioAngular) {
            valueChanged()
        }
        .onChange(of: fillVM.keepBackground) {
            valueChanged()
        }
        .onChange(of: fillVM.strokeOnly) {
            valueChanged()
        }
        .onChange(of: fillVM.lineWidth) {
            valueChanged()
        }
        .onAppear {
            self.opacity = fillVM.opacity
            if case let .gradient(pattern) = fillVM.currentFillItem.fillEffect {
                self.pattern = pattern
            }
            valueChanged()
        }
        
    }
    
    func valueChanged() {
        let colors = self.pattern.colors.map {
            let r = $0.components.red
            let g = $0.components.green
            let b = $0.components.blue
            return Color(red: r, green: g, blue: b).opacity(opacity)
        }
        let direction = getXyRatioBinding(for: self.pattern.type).wrappedValue.map {
            UnitPoint(x: $0.x, y: $0.y)
        }
        fillVM.opacity = self.opacity
        let fillEffect : FillEffect = .gradient(.init(colors: colors,
                                                      direction: direction,
                                                      locations: self.pattern.locations,
                                                      type: self.pattern.type))
        fillVM.setFill(effect: fillEffect)
    }
}

struct GradientOnlyView : View {
    var pattern: GradientPattern
    var cgPath : CGPath?
    var lineWidth : CGFloat = 1.0
    
    init(pattern: GradientPattern, cgPath: CGPath? = nil, lineWidth: CGFloat = 1) {
        self.pattern = pattern
        self.cgPath = cgPath
        self.lineWidth = lineWidth
    }
    
    var body: some View {
        GeometryReader { metrics in
            if let cgPath = self.cgPath {
                let gradiant = pattern.gradiant(size: metrics.size)
                
                if let concrete = gradiant as? LinearGradient {
                    Path(cgPath)
                        .stroke(
                            concrete,
                            lineWidth: lineWidth
                        )
                } else if let concrete = gradiant as? RadialGradient {
                    Path(cgPath)
                        .stroke(
                            concrete,
                            lineWidth: lineWidth
                        )
                } else if let concrete = gradiant as? AngularGradient {
                    Path(cgPath)
                        .stroke(
                            concrete,
                            lineWidth: lineWidth
                        )
                }
            } else {
                ConcreteGradientView(pattern: pattern, size: metrics.size)
            }
        }
    }
}

struct GradientEditView : View {
    @EnvironmentObject var fillVM:FillBackgroundViewModel
    @Binding var pattern: GradientPattern
    @Binding var isEditing:Bool
    @Binding var directions: [CGPoint]
    var size : CGSize
    let offsetY: CGFloat = 30
    //var pentagons : [PentagonWithRectangle] = []
    @State var offsetWidth : [CGFloat] = []
    @GestureState var dragState = DragState.inactive
    @State var oldOffsetWidth : [CGFloat] = []
    
    @State private var selectedColor: Color = .blue // The currently selected color
    @State private var showColorPicker: Bool = false
    
    @State var currentIndex: Int = 0
    
    var body: some View {
        VStack {
            HStack {
                Button(action : {
                    withAnimation {
                        isEditing.toggle()
                    }
                }) {
                    Image(systemName: "arrowshape.turn.up.backward")
                        .appButtonStyle2()
                }
                Spacer()
                ColorPicker("", selection: $selectedColor, supportsOpacity: false)
                    .appTextStyle2()
                    .labelsHidden()
                    .onChange(of: selectedColor) {
                        pattern.colors[currentIndex] = selectedColor
                        valueChange()
                    }
                Button(action : {
                    resetData()
                    currentIndex = self.pattern.insert(at: currentIndex)
                    fillData()
                }) {
                    Image(systemName: "plus").foregroundStyle(.white)
                        .frame(width: 30, height: 30)
                        .appButtonStyle()
                }
                .disabled(pattern.colors.count >= 7)
                .opacity(pattern.colors.count >= 7 ? 0.5 : 1)
                Button(action : {
                    resetData()
                    currentIndex = self.pattern.remove(at: currentIndex)
                    fillData()
                }) {
                    Image(systemName: "minus").foregroundStyle(.white)
                        .frame(width: 30, height: 30)
                        .appButtonStyle()
                }
                .disabled(pattern.colors.count <= 2)
                .opacity(pattern.colors.count <= 2 ? 0.5 : 1)

            }.frame(width: size.width - offsetY, height: size.height / 3 - 5)
            VStack {
                ConcreteGradientView(pattern: pattern, size: size)
                    .frame(width: size.width - offsetY, height: size.height / 3 - 5)
                if offsetWidth.count > 0 {
                    ZStack {
                        ForEach(0 ..< pattern.locations.count, id:\.self) { index in
                            PentagonWithRectangle()
                                .fill(pattern.colors[index])
                                .stroke(index == currentIndex ? Color.appMain : Color.gray.opacity(0.7),
                                        lineWidth: 2)
                                .frame(width: size.height / 5, height: size.height / 4)
                                .position(x: offsetWidth[index])
                                .offset(y : size.height / 8)
                                .zIndex(zInt(index))
                                .gesture(
                                    dragGesture(index: index).simultaneously(with: tapGesture(index: index))
                                )
                        }.frame(width: size.width - offsetY, height: size.height / 3)
                    }
                }
            }
        }.onAppear {
            fillData()
        }
    }
    func resetData() {
        offsetWidth = []
        oldOffsetWidth = []
    }
    func fillData() {
        //pentagons = []
        for index in 0 ..< pattern.colors.count {
            //pentagons.append(PentagonWithRectangle())
            offsetWidth.append(pattern.locations[index] * (size.width - offsetY))
            oldOffsetWidth.append(pattern.locations[index] * (size.width - offsetY))
        }
        selectedColor = pattern.colors[currentIndex]
        valueChange()
    }
    
    func zInt(_ index : Int) -> Double {
        return (index == 0 || index == pattern.colors.count - 1) ? 0 : Double(index)
    }
    
    func getOffsetFor(_ activeIndex:Int, offset : CGFloat) {
        if offsetWidth.count < 2 { return }
        
        for index in 0 ..< offsetWidth.count {
            if activeIndex == index {
                if index == 0 {
                    offsetWidth[index] = minMax(minValue: 0,
                                                maxValue: offsetWidth[index + 1],
                                                value: oldOffsetWidth[index] + offset)
                } else if index == offsetWidth.count - 1 {
                    offsetWidth[index] = minMax(minValue: oldOffsetWidth[index - 1],
                                                maxValue: size.width - offsetY,
                                                value: oldOffsetWidth[index] + offset)
                } else {
                    offsetWidth[index] = minMax(minValue: oldOffsetWidth[index - 1],
                                                maxValue: oldOffsetWidth[index + 1],
                                                value: oldOffsetWidth[index] + offset)
                }
            }
        }
    }
    
    func dragGesture(index : Int) -> some Gesture {
        DragGesture()
            .onChanged { value in
                // Update the offset based on the current drag translation
                getOffsetFor(index, offset: value.translation.width)
                valueChange()
            }
            .onEnded { value in
                for index in 0 ..< offsetWidth.count {
                    oldOffsetWidth[index] = offsetWidth[index]
                }
                valueChange()
                currentIndex = index
                selectedColor = pattern.colors[index]
            }
    }
    
    func tapGesture(index : Int) -> some Gesture {
        TapGesture()
            .onEnded {
                currentIndex = index
                selectedColor = pattern.colors[index]
            }
    }
    
    func valueChange() {
        
        let colors = self.pattern.colors.map {
            let r = $0.components.red
            let g = $0.components.green
            let b = $0.components.blue
            return Color(red: r, green: g, blue: b).opacity(fillVM.opacity)
        }
        let unitDirection: [UnitPoint] = directions.map {
            .init(x: $0.x, y: $0.y)
        }
        
        let locations = offsetWidth.map { $0 / (size.width - offsetY) }
        pattern.locations = locations
        let fillEffect : FillEffect = .gradient(.init(colors: colors,
                                                      direction: unitDirection,
                                                      locations: locations,
                                                      type: pattern.type))
        fillVM.setFill(effect: fillEffect)
    }
}
