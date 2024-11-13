//
//  ViewExtension.swift
//  SegmentAnywhere
//
//  Created by hansoong choong on 31/10/23.
//

import SwiftUI

struct CardStyle: ViewModifier {
    var condition: Bool
    
    func body(content: Content) -> some View {
        content
            .frame(width: UILayout.CardHeight, height: UILayout.CardHeight)
//            .border(Color.checkorange.opacity(0.5))
            .padding(UILayout.CommonGap/4)
            .background(
                RoundedRectangle(cornerRadius: 5).fill(Color.appDarkGray)
            )
            .border(condition ? Color.appMain : Color.white.opacity(0), width: condition ? 4 : 0)
            .cornerRadius(5)
    }
}

struct InfoView: ViewModifier {
    let isShow: Bool
    @State private var animationsRunning = false

    func body(content: Content) -> some View {

        if !isShow {
            content
        } else {
            HStack {
                Image(systemName: "info.circle")
                content
            }.foregroundColor(.white)
                .bold()
            .padding()
            .background(Color.appMain)
            .font(.title3)
//            .onAppear {
//                animationsRunning.toggle()
//            }
        }
            
    }
}

struct AppTextStyle: ViewModifier {

    let active : Bool
    let biggerFont : Bool
    func body(content: Content) -> some View {
        content
            .font(biggerFont ? .appTextBigFont : .appTextFont)
            .foregroundStyle(active ? Color.appMain : Color.white)
    }
}

struct AppButtonStyle: ViewModifier {

    let active : Bool
    func body(content: Content) -> some View {
        content
            //.symbolRenderingMode(.none)
            .foregroundStyle(active ? Color.white : Color.appLightGray)
            .background(active ? Color.appMain : Color.appDarkGray)
            .cornerRadius(5)
    }
}

struct AppButtonStyle2: ViewModifier {

    let active : Bool
    func body(content: Content) -> some View {
        content
            .foregroundStyle(active ? Color.appMain : Color.appLightGray)
            .fontWeight(active ? .heavy : .regular)
    }
}

struct AppButtonStyle3: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.appDarkGray)
            .cornerRadius(5)
    }
}

struct AppButtonStyle4: ViewModifier {

    let active : Bool
    func body(content: Content) -> some View {
        content
            //.symbolRenderingMode(.none)
            .foregroundStyle(active ? Color.white : Color.appLightGray)
            .background(active ? Color.appMain : Color.appDarkGray)
//            .cornerRadius(5)
    }
}

extension View {
    func infoView(isShow: Bool) -> some View {
        return self.modifier(InfoView(isShow:isShow))
    }
    
    func appTextStyle(active : Bool = false) -> some View {
        return self.modifier(AppTextStyle(active: active, biggerFont: false))
    }
    
    func appTextStyle2(active : Bool = false) -> some View {
        return self.modifier(AppTextStyle(active: active, biggerFont: true))
    }
    
    func appButtonStyle(active : Bool = false) -> some View {
        return self.modifier(AppButtonStyle(active: active))
    }
    
    func appButtonStyle2(active : Bool = false) -> some View {
        return self.modifier(AppButtonStyle2(active: active))
    }
    
    func appButtonStyle3() -> some View{
        return self.modifier(AppButtonStyle3())
    }
    
    func appButtonStyle4(active : Bool = false) -> some View {
        return self.modifier(AppButtonStyle4(active: active))
    }
    
    func cardStyle(condition: Bool) -> some View {
        return self.modifier(CardStyle(condition: condition))
    }
}

struct iOSCheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: {
            configuration.isOn.toggle()
        }, label: {
            HStack {
                Image(systemName: configuration.isOn ? "checkmark.square" : "square")
                    .foregroundStyle(Color.white)
                configuration.label
            }
        })
    }
}
