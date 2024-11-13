//
//  FilterMenuView.swift
//  colorful-room
//
//  Created by macOS on 7/14/20.
//  Copyright © 2020 PingAK9. All rights reserved.
//

import SwiftUI

struct FilterMenuUI: View {
    
    @EnvironmentObject var photoManager : PhotoManager
    @EnvironmentObject var effectFilter:EffectFilterViewModel
    
    //@State var showList : Bool = false
    
    @Binding var showEffectList : [Bool]
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
                
                if effectFilter.panelType == .basicPanel {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing : UILayout.CommonGap) {
                            Spacer()
                            
                            ForEach(EffectConstants.supportFilters, id: \.name) { filter in
                                VStack {
                                    IconButton(.systemImage, filter.iconName)
                                        .rotationEffect(filter.rotation)
                                    //                                        .border(Color.checkblue.opacity(0.5))
                                    Text(filter.name)
                                        .font(.appTextFont)
                                        .lineLimit(1)
                                        .foregroundColor(.white)
                                }.onTapGesture {
                                    effectFilter.currentEffectItem = filter
                                }
                                .frame(width: UILayout.EditMenuIconSize, height: UILayout.EditMenuIconSize)
                                //                                .border(Color.checkgreen.opacity(0.5))
                            }
                            
                            Spacer()
                        }
                    }
                    .frame(height: UILayout.MenuOptionBarHeight)
                    //                    .border(Color.checkcyan.opacity(0.5))
                    .background(.black)
                } else {
                    ScrollViewReader { value in
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: UILayout.CommonGap) {
                                Spacer()
                                
                                ForEach(0 ..< EffectConstants.moreEffects.count, id: \.self) { index in
                                    VStack {
                                        IconButton(.systemImage, EffectConstants.moreEffects[index].iconName, colorStyle: showEffectList[index] ? Color.appMain : .white.opacity(0.7))
                                        Text(EffectConstants.moreEffects[index].name)
                                            .font(.appTextFont)
                                            .foregroundStyle(showEffectList[index] ? Color.appMain : .white.opacity(0.7))
                                    }
                                    .frame(width: UILayout.EditMenuIconSize, height: UILayout.EditMenuIconSize)
                                    //                                    .border(Color.checkblue.opacity(0.5))
                                    .onTapGesture {
                                        withAnimation {
                                            showEffectList[index].toggle()
                                        }completion: {
                                            if showEffectList[index] {
                                                withAnimation {
                                                    value.scrollTo(index, anchor: .leading)
                                                }
                                            }
                                        }
                                    }
                                    //if effectFilter.currentEffectItem == .noneEffect {
                                        EffectViewList(effectItem: EffectConstants.moreEffects[index],showList: $showEffectList[index])
                                            .id(index)
                                    //}
                                }
                                
                                Spacer()
                            }
                            //                            .border(Color.checkcyan.opacity(0.5))
                        }
                    }
                    .frame(height: UILayout.MenuOptionBarHeight)
                    //                    .border(Color.checkorange.opacity(0.5))
                    .background(.black)
                }
            }.opacity(effectFilter.currentEffectItem != .noneEffect ? 0 : 1)
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
                IconButton(.systemImage, "camera.filters", colorStyle: effectFilter.panelType == .basicPanel ? Color.appMain : Color.appLightGray)
                    .appButtonStyle2(active: effectFilter.panelType == .basicPanel)
                Spacer().frame(height: UILayout.CommonGap/2)
                //                    .border(Color.checkred.opacity(0.5))
                Text("Basic")
                    .appTextStyle(active: effectFilter.panelType == .basicPanel)
            }.onTapGesture {
                effectFilter.panelType = .basicPanel
            }
            .frame(width: UILayout.AdjustMaskOptionButtonWidth, height: UILayout.AdjustMaskOptionButtonHeight)
            //            .border(Color.checkblue.opacity(0.5))
            
            VStack {
                IconButton(.systemImage, "circle.hexagongrid", colorStyle: effectFilter.panelType == .morePanel ? Color.appMain : Color.appLightGray)
                    .appButtonStyle2(active: effectFilter.panelType == .morePanel)
                //                    .border(Color.checkred.opacity(0.5))
                Text("More")
                    .appTextStyle(active: effectFilter.panelType == .morePanel)
            }.onTapGesture {
                effectFilter.panelType = .morePanel
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
