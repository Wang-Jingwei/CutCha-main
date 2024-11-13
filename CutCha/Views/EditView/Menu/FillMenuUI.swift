//
//  FilterMenuView.swift
//  colorful-room
//
//  Created by macOS on 7/14/20.
//  Copyright © 2020 PingAK9. All rights reserved.
//

import SwiftUI

struct FillMenuUI: View {
    
    @EnvironmentObject var photoManager : PhotoManager
    @EnvironmentObject var fillVM:FillBackgroundViewModel
    
    @Binding var showColorList : [Bool]
    
    var body: some View {
        ZStack {
            VStack(spacing:0) {
                HStack {
                    Spacer()
                    colorOptionPanel
                    Spacer()
                    Divider()
                        .background(.gray)
                        .padding([.top, .bottom], 5)
                    Spacer()
                    maskOptionPanel
                    Spacer()
                }
                .frame(height : UILayout.EditMenuBarHeight)
                .background(.black)
                Divider().background(.gray)
                
                if fillVM.panelType == .basicPanel {
                    ScrollViewReader { value in
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing : UILayout.CommonGap) {
                                ForEach(0 ..< fillVM.basicFillFilters.count, id: \.self) { index in
                                    VStack {
                                        IconButton(.systemImage, fillVM.basicFillFilters[index].iconName,
                                                   colorStyle: showColorList[index] ? Color.appMain : .white.opacity(0.7),
                                                   multiColor: (showColorList[index] && fillVM.basicFillFilters[index].iconName == "rainbow"))
                                        Text(fillVM.basicFillFilters[index].name)
                                            .font(.appTextFont)
                                            .foregroundStyle(showColorList[index] ? Color.appMain : .white.opacity(0.7))
                                    }
                                    .frame(width: UILayout.EditMenuIconSize, height: UILayout.EditMenuIconSize)
                                    .onTapGesture {
                                        withAnimation {
                                            showColorList[index].toggle()
                                        }completion: {
                                            if showColorList[index] {
                                                withAnimation {
                                                    value.scrollTo(index, anchor: .leading)
                                                }
                                            }
                                        }
                                    }
                                    ColorViewList(fillItem: $fillVM.basicFillFilters[index], showList: $showColorList[index])
                                        .id(index)
                                    
                                }
                            }
                        }
                    }
                    .frame(height: UILayout.MenuOptionBarHeight)
                    .background(.black)
                } else {
                    FillMaterialListView()
                    .frame(height: UILayout.MenuOptionBarHeight)
                    .background(.black)
                }
            }.opacity(fillVM.currentFillItem != .noneFill ? 0 : 1)
        }
        .onAppear {
            if photoManager.maskImage == nil {
                photoManager.masking.maskFillOption = .FULL_IMAGE
            } else {
                photoManager.masking.maskFillOption = .MASK_ONLY
            }
        }
    }
    
    
    
    var canDisplayOption: Bool {
        if photoManager.currentDisplayImage != photoManager.lastEditImage {
            return true
        }
        return false
    }
    
    var colorOptionPanel : some View {
        HStack {
            VStack {
                IconButton(.systemImage, "drop.halffull", colorStyle: fillVM.panelType == .basicPanel ? Color.appMain : Color.appLightGray)
                    .appButtonStyle2(active: fillVM.panelType == .basicPanel)
                Spacer().frame(height: UILayout.CommonGap/2)
                //                    .border(Color.checkred.opacity(0.5))
                Text("Color")
                    .appTextStyle(active: fillVM.panelType == .basicPanel)
            }.onTapGesture {
                fillVM.panelType = .basicPanel
            }
            .frame(width: UILayout.AdjustMaskOptionButtonWidth, height: UILayout.AdjustMaskOptionButtonHeight)
            //            .border(Color.checkblue.opacity(0.5))
            
            VStack {
                IconButton(.systemImage, "person.and.background.dotted", colorStyle: fillVM.panelType == .morePanel ? Color.appMain : Color.appLightGray)
                    .appButtonStyle2(active: fillVM.panelType == .morePanel)
                //                    .border(Color.checkred.opacity(0.5))
                Text("Pattern")
                    .appTextStyle(active: fillVM.panelType == .morePanel)
            }.onTapGesture {
                fillVM.panelType = .morePanel
            }
            .frame(width: UILayout.AdjustMaskOptionButtonWidth, height: UILayout.AdjustMaskOptionButtonHeight)
            //            .border(Color.checkblue.opacity(0.5))
        }
        //        .border(Color.checkgreen.opacity(0.5))
    }
    
    var maskOptionPanel : some View {
        HStack {
            Spacer()
            VStack {
                IconButton(.systemImage, "rectangle.fill", colorStyle: photoManager.masking.maskFillOption == .FULL_IMAGE ? Color.appMain : Color.appLightGray)
                    .appButtonStyle2(active: photoManager.masking.maskFillOption == .FULL_IMAGE)
                //                    .border(Color.checkred.opacity(0.5))
                Spacer().frame(height: UILayout.CommonGap/2)
                Text("Full Image")
                    .appTextStyle(active: photoManager.masking.maskFillOption == .FULL_IMAGE)
            }.onTapGesture {
                photoManager.masking.maskFillOption = .FULL_IMAGE
            }
            .frame(width: UILayout.AdjustMaskOptionButtonWidth, height: UILayout.AdjustMaskOptionButtonHeight)
            //            .border(Color.checkblue.opacity(0.5))
            Spacer()
            
            VStack {
                IconButton(.systemImage, "heart.rectangle", colorStyle: photoManager.masking.maskFillOption == .MASK_ONLY ? Color.appMain : Color.appLightGray)
                    .appButtonStyle2(active: photoManager.masking.maskFillOption == .MASK_ONLY)
                Spacer().frame(height: UILayout.CommonGap/2)
                //                    .border(Color.checkred.opacity(0.5))
                Text("Mask Only")
                    .appTextStyle(active: photoManager.masking.maskFillOption == .MASK_ONLY)
            }.onTapGesture {
                photoManager.masking.maskFillOption = .MASK_ONLY
            }
            .frame(width: UILayout.AdjustMaskOptionButtonWidth, height: UILayout.AdjustMaskOptionButtonHeight)
            //            .border(Color.checkblue.opacity(0.5))
            .opacity(photoManager.maskImage == nil ? 0.5 : 1)
            .disabled(photoManager.maskImage == nil)
            
            Spacer()
            
            VStack {
                IconButton(.systemImage, "heart.rectangle.fill", colorStyle: photoManager.masking.maskFillOption == .INVERSE_MASK ? Color.appMain : Color.appLightGray)
                    .appButtonStyle2(active: photoManager.masking.maskFillOption == .INVERSE_MASK)
                Spacer().frame(height: UILayout.CommonGap/2)
                //                    .border(Color.checkred.opacity(0.5))
                Text("Inverse Mask")
                    .appTextStyle(active:  photoManager.masking.maskFillOption == .INVERSE_MASK)
            }.onTapGesture {
                photoManager.masking.maskFillOption = .INVERSE_MASK
            }
            .frame(width: UILayout.AdjustMaskOptionButtonWidth, height: UILayout.AdjustMaskOptionButtonHeight)
            //            .border(Color.checkblue.opacity(0.5))
            .opacity(photoManager.maskImage == nil ? 0.5 : 1)
            .disabled(photoManager.maskImage == nil)
            
            Spacer()
        }
        //        .border(Color.checkgreen.opacity(0.5))
    }
}
