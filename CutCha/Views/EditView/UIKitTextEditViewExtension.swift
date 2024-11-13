//
//  UIKitTextEditViewFontOptionExtension.swift
//  SegmentAnywhere
//
//  Created by hansoong choong on 3/4/24.
//

import SwiftUI

extension UIKitTextEditImageView {
    func getShadowXY(xDisplacement : BindType, yDisplacement : BindType, radius: BindType) -> (BindType, BindType, BindType) {
        return (xDisplacement, yDisplacement, radius)
    }
    
    func getImgTextRatio() -> Double{
        let imgSize = photoManager.imageSize.width > photoManager.imageSize.height ? photoManager.imageSize.width : photoManager.imageSize.height
        let imgTextRatio = Double(imgSize)/Double(WorkingImageSize.minSize)
        
        return floor(imgTextRatio * 10) / 10.0
    }
    
    @ViewBuilder
    func textViewWithOption(_ element: some View, for index : Int, isTextBorderDisable: Bool) -> some View {
        let shadowXY = getShadowXY(
                        xDisplacement: BindType(textOptions[index].shadowXDirection * getImgTextRatio()),
                        yDisplacement: BindType(textOptions[index].shadowYDirection * getImgTextRatio()),
                        radius: BindType(Double(textOptions[index].shadowRadius) * getImgTextRatio()))
        
        if isTextBorderDisable {
            element
                .foregroundStyle(textOptions[index].foreColor)
                .shadow(color : textOptions[index].shadowColor,
                        radius: CGFloat(shadowXY.2), x: CGFloat(shadowXY.0),
                        // vh: make y negative so that on uiview it follows the xy coordinate convention
                        y: CGFloat(-(shadowXY.1)))
                .font(.custom(textOptions[index].fontName, size: CGFloat(Double(textOptions[index].fontSize) * getImgTextRatio())))
                .position(textOptions[index].boxRect.center)
        } else {
            element
                .foregroundStyle(textOptions[index].foreColor)
                .font(.custom(textOptions[index].fontName, size: CGFloat(Double(textOptions[index].fontSize) * getImgTextRatio())))
                .stroke(textBorderColor: textOptions[index].textBorderColor, textBorderWidth: CGFloat(textOptions[index].textBorderWidth) * getImgTextRatio(), shadowArg: shadowXY, shadowColor: textOptions[index].shadowColor)
                .position(textOptions[index].boxRect.center)
            
        }
    }
    
    func getAnchor(element: TextOption) -> UnitPoint {
        let anchor = UnitPoint(x: element.boxRect.center.x / photoManager.imageSize.width,
                               y: element.boxRect.center.y / photoManager.imageSize.height)
        
        return anchor
    }
    
    func viewForTextElement(_ element : some View, for index : Int, isSnapShot : Bool = false) -> some View {
        let baseElement = element
            .background(ViewGeometry())
            .onPreferenceChange(ViewSizeKey.self) {
                if !isSnapShot {
                    textOptions[index].boxSize = $0
                    textOptions[index].boxRect.size = textOptions[index].boxSize
                }
            }
        //.lineLimit(nil)
        
        let textElement = textViewWithOption(baseElement, for: index, isTextBorderDisable: textOptions[index].textBorderIsDisable)
        
        return textElement
    }
    
    func buttonWithSmallFont(_ element : some View, isActive : Bool, onTap : @escaping () -> Void) -> some View {
        element
            .appButtonStyle2(active: isActive)
            .font(.caption)
            .onTapGesture {
                onTap()
            }
    }
    
    func colorPickerFor(_ bindColor: Binding<Color>, _ height: CGFloat) -> some View {
        ColorPicker("", selection: bindColor)
            .scaleEffect(CGSize(width: colorWheelScaleRatio, height: colorWheelScaleRatio))
            .labelsHidden()
            .frame(width: leftContainerWidth, height: height)
            .appButtonStyle()
    }
    
    func translateGesture(for index: Int) -> some Gesture {
        DragGesture(minimumDistance: 0.1)
            .onChanged({ (touch) in
                textOptions[index].elementTranslate = touch.translation
                textOptions[index].boxRect = CGRect(x: textOptions[index].currentBoxRect.origin.x + textOptions[index].elementTranslate.width,
                                                   y: textOptions[index].currentBoxRect.origin.y + textOptions[index].elementTranslate.height,
                                                   width: textOptions[index].boxSize.width,
                                                   height: textOptions[index].boxSize.height)
            })
            .onEnded({ (touch) in
                textOptions[index].elementTranslate = .zero
                textOptions[index].currentBoxRect = textOptions[index].boxRect
                currentTextIndex = index
            })
    }
    
    func rotationGesture(for index: Int) -> some Gesture {
        RotateGesture()
            .onChanged { value in
                textOptions[index].objectAngle = textOptions[index].previousObjectAngle + value.rotation.normalized()
            }
            .onEnded { _ in
                textOptions[index].previousObjectAngle = textOptions[index].objectAngle
            }
    }
    
    func getTextOptionIndex(_ id:UUID) -> Int {
        return textOptions.firstIndex {
            $0.id == id
        }!
    }
    
    
    @ViewBuilder
    func backgroundStyleView(selectedShape: ShapeOption) -> some View {
        GeometryReader { geo in
            VStack {
                selectedShape.getShape
                    .stroke(selectedShape == textOptions[currentTextIndex].backShape ? Color.appMain : .white, lineWidth: backgroundSampleWidth)
                    .fill(.black)
                    .frame(width: scrollBackgroundItemSize, height: scrollBackgroundItemSize/2)
                    .onTapGesture {
                        textOptions[currentTextIndex].backShape = selectedShape
                    }
                
                Spacer().frame(height: UILayout.CommonGap)
                MarqueeText(text: selectedShape.getName, font: .systemFont(ofSize: 10, weight: selectedShape == textOptions[currentTextIndex].backShape ? .bold : .regular), leftFade: UILayout.CommonGap, rightFade: UILayout.CommonGap, startDelay: 5, fontColor: selectedShape == textOptions[currentTextIndex].backShape ? Color.appMain : .white, alignment: .center)
            }
            .frame(height: geo.size.height)
            .cornerRadius(5)
        }
    }
    
    @ViewBuilder
    func textStyleView(fontName: String) -> some View {
        VStack(spacing: UILayout.CommonGap){
            Text("AaBb")
                .font(Font.custom(fontName, size: 17))
                .foregroundStyle(fontName == textOptions[currentTextIndex].fontName ? Color.appMain : .white)
                .id(fontName)
                .onTapGesture {
                    textOptions[currentTextIndex].fontName = fontName
                }
            MarqueeText(text: fontName, font: .systemFont(ofSize: 10, weight: fontName == textOptions[currentTextIndex].fontName ? .bold : .regular), leftFade: UILayout.CommonGap, rightFade: UILayout.CommonGap, startDelay: 5, fontColor: fontName == textOptions[currentTextIndex].fontName ? Color.appMain : .white, alignment: .center)
                .frame(width: scrollItemWidth - (UILayout.CommonGap*2))
        }
        .frame(width: scrollItemWidth, height: scrollItemWidth)
        .cornerRadius(5)
    }
}
