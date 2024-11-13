//
//  ColorViewList.swift
//  CutCha
//
//  Created by hansoong choong on 1/10/24.
//


import SwiftUI
import CoreImage

struct ColorViewList: View {
    
    @EnvironmentObject var fillVM : FillBackgroundViewModel
    @EnvironmentObject var photoManager : PhotoManager
    
    @State var currentIndex : Int = 0
    
    @State var circleAnimate : Bool = false
    //@State var colorList : [FillItem] = []
    @State private var bgColor = Color.white
    @Binding var fillItemGroup : FillItem
    @Binding var showList : Bool
    
    var rows: [GridItem] = [
            GridItem(.adaptive(minimum: 30)) // Minimum item width of 50
        ]
    
    init(fillItem : Binding<FillItem>, showList : Binding<Bool>) {
        self._fillItemGroup = fillItem
        //self.colorList = fillItemGroup.items
        self._showList = showList
    }
    
    var body: some View {
        if showList {
            LazyHGrid(rows: self.rows) {
                ForEach(fillItemGroup.items, id: \.self) { item in
                    
                    if case FillEffect.color(let color) = item.fillEffect {
                        Rectangle()
                            .fill(color)
                            .border(Color.gray)
                            .aspectRatio(1.0, contentMode: .fit)
                            .onTapGesture {
                                fillVM.currentFillItem = item
                            }
                    } else if case FillEffect.gradient(let pattern) = item.fillEffect {
                        GradientOnlyView(pattern: pattern)
                            .border(Color.gray)
                            .aspectRatio(1.0, contentMode: .fit)
                            .onTapGesture {
                                fillVM.currentFillItem = item
                            }
                    }
                }
                
                if fillItemGroup.name.lowercased() == "fill" {
                    ColorPicker("", selection: $bgColor, supportsOpacity: false)
                        .labelsHidden()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .frame(minWidth : -1, maxWidth: .infinity)
            .padding(5)
            .onChange(of: bgColor) {
                let item : FillItem = .init(CutchaFileHelper.shared.generateID(), fillEffect: .color(bgColor))
                fillVM.currentFillItem = item
            }
        } else {
            EmptyView()
        }
    }
}
