//
//  UIKitTextEditImageView.swift
//  SegmentAnywhere
//
//  Created by hansoong choong on 1/4/24.
//

import SwiftUI
import Combine
import ShapeBuilder

typealias BindType = Int

enum Focusable: Hashable {
  case none
  case uuid(id: UUID)
}

struct UIKitTextEditImageView: View {
    
    @EnvironmentObject var photoManager: PhotoManager
    @EnvironmentObject var effectFilter: EffectFilterViewModel
    
    @Binding var textOptions : [TextOption]
    @Binding var currentTextIndex : Int
    
    @State var tapNothing : Bool = true
    @State var showShareSheet : Bool = false
    @State var isScaleX : Bool = true
    @State var isTextBorderSelect : Bool = false
    
    @State var isEdit : Bool = false
    
    /// clean code, make constant
    let headerHeight: CGFloat = 40
    let headerWidth: CGFloat = 80
    let contentWidth: CGFloat = 120
    let contentHeight: CGFloat = 165
    let scrollItemWidth: CGFloat = 65
    let scrollBackgroundItemSize : CGFloat = 50
    let leftContainerWidth: CGFloat = 90
    let sliderHeight: CGFloat = 40
    let labelHeight: CGFloat = 20
    let colorWheelScaleRatio: CGFloat = 1.3
    let smallColorWheelRatio: CGFloat = 1.0
    let controlPointSize : CGFloat = 15
    let backgroundSampleWidth : CGFloat = 3
    let foregroundUpPanelExtend : CGFloat = 20
    let sliderEndGap: CGFloat = 15
    
    @FocusState private var focusedField: Focusable?
    
    @State var textPanelOption : TextPanelOption = .foreground
    
    func randomPosition(textBoxSize: CGSize) -> (Double, Double) {
        let workingImageSize = photoManager.currentDisplayImage!.size
        
        let xRange = {
            if textBoxSize.width * photoManager.textManager.scaleEffectWidth >= workingImageSize.width {
                return Int(workingImageSize.width/2)
            } else {
                return Int((workingImageSize.width - (textBoxSize.width * photoManager.textManager.scaleEffectWidth))/2)
            }
        }()
        
        let yRange = {
            if textBoxSize.height * photoManager.textManager.scaleEffectHeight >= workingImageSize.height {
                return Int(workingImageSize.height)
            } else {
                return Int((workingImageSize.height - (textBoxSize.height * photoManager.textManager.scaleEffectHeight))/2)
            }
        }()
        
        let randomPosition : (Double, Double) = (Double(Int.random(in: -xRange..<xRange)), Double(Int.random(in: -yRange..<yRange)))
        return randomPosition
    }
    
    var body: some View {
        VStack {
            switch photoManager.appState.imageState {
            case .success:
                AdvancedScrollView {proxy in
                    mainBody(showIndicator: true)
                }
                .onTapContentGesture { location, proxy in
                    let index = textOptions.firstIndex { textOption in
                        let boxRect = CGRectInset(textOption.boxRect, -60, -60)
                        if boxRect.contains(location) {
                            return true
                        }
                        return false
                    }
                    if index != nil {
                        tapNothing = false
                        currentTextIndex = index!
                    } else {
                        tapNothing = true
                        isEdit = false
                    }
                    focusedField = nil
                }
                .onAppear {
                    if textOptions.count == 1 && textOptions[0].boxRect == .zero {
                        let imageCenter = CGPoint(x: photoManager.currentDisplayImage!.size.width/2, y: photoManager.currentDisplayImage!.size.height/2)
                        let initBoxSize = CGSize(width: photoManager.currentDisplayImage!.size.width * 2/3, height: photoManager.currentDisplayImage!.size.height/7)
                        
                        for index in 0 ..< textOptions.count {
                            let textBoxSize = textOptions[index].boxSize == .zero ? CGSize(width: initBoxSize.width, height: initBoxSize.height) : textOptions[index].boxSize
                            textOptions[index].boxRect = .init(center: imageCenter, size: textBoxSize)
                            textOptions[index].currentBoxRect = textOptions[index].boxRect
                        }
                    }
                }.onDisappear {
                    //focusedField = false
                    focusedField = nil
                }
//                .highPriorityGesture(rotationGesture(for: photoManager.textManager.currentTextIndex))
                
            default:
                Rectangle().foregroundStyle(Color.clear).overlay {
                    ProgressView() {
                        Text("Loading...").foregroundStyle(Color.white)
                    }.tint(.white)
                }
            }
            fontOptionPanel()
                .background(.black)
        }
        .
        onChange(of: photoManager.textManager.shareAction) {
            if photoManager.textManager.shareAction != .NONE {
                photoManager.textManager.snapshotImage = ImageRenderer(content: mainBody(showIndicator: false, isSnapShot: true)).uiImage
            }
        }
        .onChange(of:photoManager.textManager.snapshotImage) {
            if let _ = photoManager.textManager.snapshotImage {
                if photoManager.textManager.shareAction == .SAVE_TO_LIBRARY {
                    photoManager.shareAction(.SAVE_TO_LIBRARY)
                } else if photoManager.textManager.shareAction == .ACTIVITY {
                    showShareSheet.toggle()
                }
                photoManager.textManager.shareAction = .NONE
            }
        }.sheet(isPresented: $showShareSheet, onDismiss: {
            //print("Dismiss")
        }, content: {
            UIShareView(items: [photoManager.textManager.snapshotImage!])
        })
    }
    
    func viewForTextFieldElement(_ element : some View, for index : Int) -> some View {
        
        let baseElement = element
            .frame(width: textOptions[index].boxSize.width, height: textOptions[index].boxSize.height)
            .onChange(of: focusedField) {
                if case let .uuid(id) = focusedField {
                    tapNothing = false
                    isEdit = true
                    currentTextIndex = getTextOptionIndex(id)
                }
            }
        
        return textViewWithOption(baseElement, for: index, isTextBorderDisable:  textOptions[index].textBorderIsDisable)
    }
    
    private static let fontNames: [String] = {
        var allNames = [String]()
        var selected_font_index = [3, 4, 21, 27, 63, 64, 68, 77, 81, 82, 87, 92, 96, 117, 121, 127, 137, 140, 165, 172, 192, 197, 217, 262, 271, 273, 276, 278, 279]
        var selected_font = [String]()
        
        UIFont.familyNames.indices.forEach { index in
                allNames.append(contentsOf: UIFont.fontNames(forFamilyName: UIFont.familyNames[index]))
        }
        allNames.sort()
        selected_font.append(allNames[26])  // <-- brute force arrange default font to the front
        
        allNames.indices.forEach { index in
            if selected_font_index.contains(index) {
                selected_font.append(allNames[index])
            }
        }
        
        return selected_font
    }()
    
    @ViewBuilder
    func mainBody(showIndicator : Bool, isSnapShot : Bool = false) -> some View {
        ZStack {
            Image(uiImage: photoManager.currentDisplayImage!)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .overlay {
                    ZStack {
                        ForEach(0 ..< textOptions.count, id :\.self) { index in
                            
                            //let anchorpt = getAnchor(element: textOptions[index])
                            
                            ZStack {
                                textOptions[index].backShape.getShape
                                    .stroke(textOptions[index].borderColor, lineWidth: textOptions[index].borderIsDisable ? 0 : CGFloat(textOptions[index].backBorderWidth) * getImgTextRatio())
                                    // force setting the background to nearly 0.
                                    .fill(textOptions[index].backColor.opacity(textOptions[index].backIsDisable ? 0.0001 : 1))
                                    .scaleEffect(textOptions[index].scaleEffect)
                                    .frame(width:textOptions[index].boxSize.width, height:textOptions[index].boxSize.height)
                                    .position(textOptions[index].boxRect.center)
                                /// clean code, complicated condition checking
                                    .opacity(isSnapShot ? 1 : (tapNothing ? 1 : (isEdit ? (currentTextIndex == index ? 1 : 0.5) : 1)))
                                
                                viewForTextElement(
                                    Text(textOptions[index].inputText), for: index, isSnapShot: isSnapShot
                                )
                                /// clean code, complicated condition checking
                                .opacity(isSnapShot ? 1 : (tapNothing ? 1 : (isEdit ? (currentTextIndex == index ? 0 : 1) : 1)))
                                
                                
                                if !isSnapShot {
                                    viewForTextFieldElement(
                                        TextField("", text: $textOptions[index].inputText, axis: .vertical)
                                            .focused($focusedField, equals: .uuid(id: textOptions[index].id))
                                        ,
                                        for: index
                                    )
                                    /// clean code, complicated condition checking
                                    .opacity(tapNothing ? 0 : (isEdit ? (currentTextIndex == index ? 1 : 0.5) : 1))
                                }
                                
                                indicatorView(index, showIndicator: showIndicator)
                            }
                            .gesture(translateGesture(for: index))
//                            .rotationEffect(textOptions[index].objectAngle, anchor: anchorpt)
//                            .onLongPressGesture(minimumDuration: 0.01){
//                                tapNothing = false
//                                isEdit = true
//                                currentTextIndex = index
//                            }
                        }
                    }
                }
        }//.clipped()
    }
    
    @ViewBuilder
    func indicatorView(_ index: Int, showIndicator: Bool) -> some View {
        if index == currentTextIndex && !tapNothing && showIndicator {
            if textOptions[index].inputText.count > 0 {
                Circle()
                    .stroke(Color.appMain, lineWidth: 5)
                    //.fill(Color.white)
                    .frame(width: controlPointSize, height: controlPointSize)
                    .position(CGPoint(x : textOptions[index].boxRect.minX - controlPointSize, y : textOptions[index].boxRect.midY))
                
                Circle()
                    .stroke(Color.appMain, lineWidth: 5)
                    //.fill(Color.white)
                    .frame(width: controlPointSize, height: controlPointSize)
                    .position(CGPoint(x : textOptions[index].boxRect.maxX + controlPointSize, y : textOptions[index].boxRect.midY))
            }
        }
    }
    
    @ViewBuilder
    func fontOptionPanel() -> some View {
        VStack {
            fontOptionHeaderView()
                .padding(EdgeInsets(top: UILayout.ColorEditButtonVerticalPadding, leading: UILayout.CommonGap, bottom: 0, trailing: UILayout.CommonGap))
            Divider()
                .padding([.leading, .trailing], UILayout.CommonGap)
            
            fontOptionContentView()
                .padding(EdgeInsets(top: 0, leading: UILayout.CommonGap, bottom: UILayout.CommonGap, trailing: UILayout.CommonGap))
                .frame(height: contentHeight, alignment: .topLeading)
            
        }
    }
    
    @ViewBuilder
    func fontOptionHeaderView() -> some View {
        HStack {
            HStack(spacing: UILayout.CommonGap) {
                Image("add-text")
                    .resizable()
                    .scaledToFit()
                    .padding(10)
                    .frame(width : headerHeight,
                           height: headerHeight)
                    .appButtonStyle()
                
                    .onTapGesture {
                        if textOptions.count == 1 {
                            if textOptions[0].inputText.count == 0 {
                                textOptions[0].inputText = "Add Text"
                                return
                            }
                        }
                        var textOption = textOptions[currentTextIndex]
                        textOption.id = UUID()
                        let imageCenter = CGPoint(x: photoManager.imageSize.width/2, y: photoManager.imageSize.height/2)
                        
                        let randomXY = randomPosition(textBoxSize: textOption.boxSize)
                        textOption.boxRect = .init(center: CGPoint(x: imageCenter.x + randomXY.0, y: imageCenter.y + randomXY.1) , size: textOption.boxSize)
                        textOption.currentBoxRect = textOption.boxRect
                        
                        textOptions.append(textOption)
                    }
                Image("del-text")
                    .resizable()
                    .scaledToFit()
                    .padding(10)
                    .frame(width : headerHeight,
                           height: headerHeight)
                    .appButtonStyle()
                    .onTapGesture {
                        if textOptions.count == 1 {
                            textOptions[0].inputText = ""
                            return
                        }
                        textOptions.remove(at: currentTextIndex)
                        if currentTextIndex >= textOptions.count {
                            currentTextIndex = 0
                        }
                    }
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: UILayout.CommonGap) {
                    Spacer().frame(width:UILayout.CommonGap)
                    ForEach(TextPanelOption.allOptions, id: \.self) { option in
                        HStack{
                            Spacer()
                            Text(option.name)
                                .appTextStyle2(active: textPanelOption == option.type)
                                .onTapGesture {
                                    textPanelOption = option.type
                                }
                            Spacer()
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func fontOptionContentView() -> some View {
        switch textPanelOption {
        case .foreground:
            foregroundOptionView
        case .background:
            backgroundOptionView
        case .shadow:
            shadowOptionView
        case .border:
            borderOptionView
        default:
            Rectangle().foregroundColor(.clear)
        }
    }
    
    @ViewBuilder
    var foregroundOptionView : some View {
        GeometryReader { foregroundGeo in
            
            VStack {
                HStack {
                    CustomColorPicker(colorWheelScaleRatio: colorWheelScaleRatio, pickerWidth: leftContainerWidth, pickerHeight: scrollItemWidth, gap: UILayout.CommonGap, containerHeight: foregroundGeo.size.height * 4/7, isPickerOnly: true, isDisableColor: $textOptions[currentTextIndex].fontIsDisable, bindColor: $textOptions[currentTextIndex].foreColor, lastColor: $textOptions[currentTextIndex].lastBackColor)
                    
                    Divider()
                        .padding([.leading, .trailing], 2)
                    
                    VStack {
                        ScrollViewReader { reader in
                            ScrollView(.horizontal) {
                                LazyHStack(spacing: 8) {
                                    ForEach(UIKitTextEditImageView.fontNames, id: \.self) { item in
                                        textStyleView(fontName: item)
                                            .frame(width: scrollItemWidth, height: scrollItemWidth, alignment: .center)
                                    }
                                }
                            }
                            .frame(height: scrollItemWidth)
                            .onAppear {
                                reader.scrollTo(textOptions[currentTextIndex].fontName)
                            }
                        }
                        Spacer().frame(minHeight:UILayout.CommonGap)
                        Text("Style : \(textOptions[currentTextIndex].fontName)")
                            .appTextStyle()
                        
                    }.frame(height: foregroundGeo.size.height * 4/7, alignment: .topLeading)
                }.frame(height: foregroundGeo.size.height * 4/7)
                
                Divider()
                    .padding([.bottom] , 5)
                
                TextEditControl(sliderArg: Double(photoManager.textManager.fontSize), textOptions: $photoManager.textManager.textOptions, currentTextIndex: $photoManager.textManager.currentTextIndex, sliderCase: .fontSize, range: (10, 200), step: 1, rangeDisplay: (5,100), label: "Font Size",
                decimalPlace: 0)
            }
        }.frame(height: contentHeight)
    }
    
    @ViewBuilder
    var backgroundOptionView : some View {
        HStack(spacing: UILayout.CommonGap)  {
            CustomColorPicker(colorWheelScaleRatio: smallColorWheelRatio, pickerWidth: leftContainerWidth, pickerHeight: scrollItemWidth, gap: UILayout.CommonGap, containerHeight: contentHeight - UILayout.CommonGap, isPickerOnly: false, isBackgroundShape: true ,isDisableColor: $textOptions[currentTextIndex].backIsDisable, bindColor: $textOptions[currentTextIndex].backColor, lastColor: $textOptions[currentTextIndex].lastBackColor)
            
            Divider()
                .padding([.leading, .trailing], 2)
            
            GeometryReader { backgroundGeo in
                VStack {
                    ScrollViewReader { reader in
                        ScrollView(.horizontal) {
                            HStack(spacing: UILayout.CommonGap) {
                                ForEach(ShapeOption.allCases, id: \.self) { item in
                                    backgroundStyleView(selectedShape: item)
                                        .frame(width:scrollItemWidth ,height: backgroundGeo.size.height/2 - UILayout.CommonGap/2)
                                }
                            }
                        }
                        .onAppear {
                            reader.scrollTo(textOptions[currentTextIndex].backShape)
                        }
                    }.frame(height: backgroundGeo.size.height/2 - UILayout.CommonGap/2, alignment: .topLeading)
                    
                    VStack {
                        HStack {
                            Spacer()
                            Text("Width")
                                .appTextStyle2(active: isScaleX)
                                .onTapGesture {
                                    isScaleX = true
                                }
                            Spacer()
                            Text("Height")
                                .appTextStyle2(active: !isScaleX)
                                .onTapGesture {
                                    isScaleX = false
                                }
                            Spacer()
                        }
                        
                        Spacer().frame(height: UILayout.CommonGap)
                        
                        if isScaleX {
                            TextEditControl(sliderArg: photoManager.textManager.scaleEffectWidth,
                                            textOptions: $photoManager.textManager.textOptions, 
                                            currentTextIndex: $photoManager.textManager.currentTextIndex,
                                            sliderCase: .scaleEffectWidth, range: (0.1, 5),
                                            step: 1, rangeDisplay: (1, 50), label: "", decimalPlace: 2)
                            
                        } else {
                            TextEditControl(sliderArg: photoManager.textManager.scaleEffectHeight, 
                                            textOptions: $photoManager.textManager.textOptions,
                                            currentTextIndex: $photoManager.textManager.currentTextIndex,
                                            sliderCase: .scaleEffectHeight, range: (0.1, 5),
                                            step: 1, rangeDisplay: (1, 50), label: "", decimalPlace: 2)
                        }
                    }.frame(height: backgroundGeo.size.height/2 - UILayout.CommonGap/2, alignment: .topLeading)
                }.frame(height: contentHeight - UILayout.CommonGap, alignment: .topLeading)
            }
            .disabled(textOptions[currentTextIndex].backIsDisable)
            .opacity(textOptions[currentTextIndex].backIsDisable ? 0.7 : 1)
        }
    }
    
    @ViewBuilder
    var shadowOptionView : some View {
        HStack(spacing: UILayout.CommonGap) {
            CustomColorPicker(colorWheelScaleRatio: smallColorWheelRatio, pickerWidth: leftContainerWidth, pickerHeight: scrollItemWidth, gap: UILayout.CommonGap, containerHeight: contentHeight - UILayout.CommonGap, isPickerOnly: false, isDisableColor: $textOptions[currentTextIndex].shadowIsDisable, bindColor: $textOptions[currentTextIndex].shadowColor, lastColor: $textOptions[currentTextIndex].lastShadowColor)
            
            Divider()
            
            VStack {
                TextEditControl(sliderArg: photoManager.textManager.shadowXDirection, textOptions: $photoManager.textManager.textOptions, currentTextIndex: $photoManager.textManager.currentTextIndex, sliderCase: .shadowXDirection, range: (-30,30), step: 1, rangeDisplay: (-30,30), label: "X", decimalPlace: 0)
                
                Spacer().frame(minHeight: UILayout.CommonGap)
                
                TextEditControl(sliderArg: photoManager.textManager.shadowYDirection, textOptions: $photoManager.textManager.textOptions, currentTextIndex: $photoManager.textManager.currentTextIndex, sliderCase: .shadowYDirection, range: (-30,30), step: 1, rangeDisplay: (-30,30), label: "Y", decimalPlace: 0)
                
                Spacer().frame(minHeight: UILayout.CommonGap)
                
                TextEditControl(sliderArg: Double(photoManager.textManager.shadowRadius), textOptions: $photoManager.textManager.textOptions, currentTextIndex: $photoManager.textManager.currentTextIndex, sliderCase: .shadowRadius, range: (0,30), step: 0.1, rangeDisplay: (0,30), label: "Blur", decimalPlace: 0)
                
                Spacer().frame(height: UILayout.CommonGap)
            }
            .disabled(textOptions[currentTextIndex].shadowIsDisable)
            .opacity(textOptions[currentTextIndex].shadowIsDisable ? 0.7 : 1)
            Spacer(minLength: 5)
        }
    }
    
    @ViewBuilder
    var borderOptionView : some View {
        HStack(spacing: UILayout.CommonGap) {
            VStack{
                if isTextBorderSelect {
                    CustomColorPicker(colorWheelScaleRatio: smallColorWheelRatio, pickerWidth: leftContainerWidth, pickerHeight: scrollItemWidth, gap: UILayout.CommonGap, containerHeight: contentHeight - UILayout.CommonGap, isPickerOnly: false, isDisableColor: $textOptions[currentTextIndex].textBorderIsDisable, bindColor: $textOptions[currentTextIndex].textBorderColor, lastColor: $textOptions[currentTextIndex].lastTextBorderColor)
                } else {
                    CustomColorPicker(colorWheelScaleRatio: smallColorWheelRatio, pickerWidth: leftContainerWidth, pickerHeight: scrollItemWidth, gap: UILayout.CommonGap, containerHeight: contentHeight - UILayout.CommonGap, isPickerOnly: false, isDisableColor: $textOptions[currentTextIndex].borderIsDisable, bindColor: $textOptions[currentTextIndex].borderColor, lastColor: $textOptions[currentTextIndex].lastBorderColor)
                }
            }
            
            Divider()
            
            GeometryReader { borderGeo in
                VStack {
                    HStack(spacing:0){
                        Text("Text")
                            .appTextStyle2(active: isTextBorderSelect)
                            .onTapGesture {
                                isTextBorderSelect = true
                            }
                            .frame(width: borderGeo.size.width/2, height: borderGeo.size.height * 2/7, alignment: .top)
                        Text("Background")
                            .appTextStyle2(active: !isTextBorderSelect)
                            .onTapGesture {
                                isTextBorderSelect = false
                            }
                            .frame(width: borderGeo.size.width/2, height: borderGeo.size.height * 2/7, alignment: .top)
                    }.frame(height: borderGeo.size.height * 2/7, alignment: .topLeading)
                    
                    if isTextBorderSelect {
                        TextEditControl(sliderArg: Double(photoManager.textManager.textBorderWidth), textOptions: $photoManager.textManager.textOptions, currentTextIndex: $photoManager.textManager.currentTextIndex, sliderCase: .textBorderWidth, range: (0,50), step: 1, rangeDisplay: (0,50), label: "", decimalPlace: 0)
                            .disabled(textOptions[currentTextIndex].textBorderIsDisable)
                            .opacity(textOptions[currentTextIndex].textBorderIsDisable ? 0.7 : 1)
                        
                    } else {
                        TextEditControl(sliderArg: Double(photoManager.textManager.backBorderWidth), textOptions: $photoManager.textManager.textOptions, currentTextIndex: $photoManager.textManager.currentTextIndex, sliderCase: .backBorderWidth, range: (0,50), step: 1, rangeDisplay: (0,50), label: "", decimalPlace: 0)
                            .disabled(textOptions[currentTextIndex].borderIsDisable)
                            .opacity(textOptions[currentTextIndex].borderIsDisable ? 0.7 : 1)
                        
                    }
                    Spacer(minLength: UILayout.CommonGap)
                }
            }.frame(height: contentHeight - UILayout.CommonGap)
        }
    }
}

struct ViewSizeKey: PreferenceKey {
    static var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

struct ViewGeometry: View {
    var body: some View {
        GeometryReader { geometry in
            Color.clear
                .preference(key: ViewSizeKey.self, value: geometry.size)
        }
    }
}

class FontOptionItem : Hashable {
    static func == (lhs: FontOptionItem, rhs: FontOptionItem) -> Bool {
        lhs.name == rhs.name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    var name:String
    var imageName:String
    var systemImage:String
    var type:TextPanelOption
    
    static var noneItem = FontOptionItem("", type:.none)
    
    init(_ name:String, imageName:String = "", systemImage:String = "", type:TextPanelOption) {
        self.name = name
        if(imageName.isEmpty){
            self.imageName = name.lowercased()
        }else{
            self.imageName = imageName
        }
        self.systemImage = systemImage
        self.type = type
    }
}

enum TextPanelOption {
    case none
    case foreground
    case background
    case shadow
    case border

    static var allOptions:[FontOptionItem] = [
        FontOptionItem("Font", imageName: "", type: .foreground),
        FontOptionItem("Border", imageName: "", type: .border),
        FontOptionItem("Background", imageName: "", type: .background),
        FontOptionItem("Shadow", imageName: "", type: .shadow)
    ]
}


enum ShapeOption: String, CaseIterable {
    case rectangle
    case roundedRectangle
    case capsule
    case ellipse
    case circle

    @ShapeBuilder
    var getShape : some Shape {
        switch self {
        case .capsule:
            Capsule()
        case .rectangle:
            Rectangle()
        case .roundedRectangle:
            RoundedRectangle(cornerRadius: 15)
        case .ellipse:
            Ellipse()
        case .circle:
            Circle()
        }
    }
    
    var getName : String {
        switch self {
        case .capsule:
            return "Capsule"
        case .rectangle:
            return "Rectangle"
        case .roundedRectangle:
            return "Rounded"
        case .ellipse:
            return "Ellipse"
        case .circle:
            return "Circle"
        }
    }
}

enum SliderBindingCase {
    case fontSize
    case scaleEffectWidth
    case scaleEffectHeight
    case shadowXDirection
    case shadowYDirection
    case shadowRadius
    case textBorderWidth
    case backBorderWidth
}

class BoundFormatter: Formatter {
    
    @Binding var max: BindType
    @Binding var min: BindType
    
    // you have to add initializers
    init(min: Binding<BindType>, max: Binding<BindType>) {
        self._min = min
        self._max = max
        
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func clamp(with value: BindType, min: BindType, max: BindType) -> BindType {
        guard value <= max else {
            return max
        }
        
        guard value >= min else {
            return min
        }
        
        return value
    }
    
    func setMax(_ max: BindType) {
        self.max = max
    }
    func setMin(_ min: BindType) {
        self.min = min
    }
    
    override func string(for obj: Any?) -> String? {
        guard let number = obj as? Int else {
            return nil
        }
        return String(number)
        
    }
    
    override func getObjectValue(_ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?, for string: String, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        
        guard let number = Int(string) else {
            return false
        }
        
        let fNumber = BindType(number)
        
        obj?.pointee = clamp(with: fNumber, min: self.min, max: self.max) as AnyObject
        
        return true
    }
    
}

//struct texteditpreview : PreviewProvider {
//    static var previews: some View {
//        let photoManager = PhotoManager()
//        @State var texoptions = [TextOption(), TextOption()]
//        @State var index = 1
//        let panel : TextPanelOption = .border
//
//        UIKitTextEditImageView(textOptions: $texoptions, currentTextIndex: $index, textPanelOption: panel)
//            .environmentObject(photoManager)
//    }
//}

//Text("Underline") { $0.underlineColor = Color.green }
///// extension to make applying AttributedString even easier
//extension Text {
//    init(_ string: String, configure: ((inout AttributedString) -> Void)) {
//        var attributedString = AttributedString(string) /// create an `AttributedString`
//        configure(&attributedString) /// configure using the closure
//        self.init(attributedString) /// initialize a `Text`
//    }
//}
