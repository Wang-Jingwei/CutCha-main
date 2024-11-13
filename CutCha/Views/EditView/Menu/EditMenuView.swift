//
//  EditMenuControlView.swift
//  colorful-room
//
//  Created by macOS on 7/8/20.
//  Copyright © 2020 PingAK9. All rights reserved.
//

import SwiftUI

struct EditMenuView: View {
    
    @EnvironmentObject var photoManager : PhotoManager
    
    var body: some View {
        GeometryReader { geo in
            ZStack{
                HStack {
                    ScrollViewReader { proxy in
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing : 0) {
                                ForEach(EditMenuType.allCases.filter { $0 != .lutCube }, id: \.self) { item in
                                    //                if item == .background && photoManager.maskImage == nil { EmptyView() }
                                    //                else {
                                    VStack {
                                        Spacer()
                                        Image(systemName: item.imageIcon)
                                            .appButtonStyle2(active: photoManager.appState.currentMenuType == item)
                                            .font(.appButtonNormalFont)
                                        Spacer()
                                        Text(item.rawValue)
                                            .appTextStyle(active: photoManager.appState.currentMenuType == item)
                                    }
                                    .padding([.top, .bottom], UILayout.CommonGap/2)
                                    .frame(width: UILayout.EditMenuIconSize, height: UILayout.EditMenuIconSize, alignment: .bottom)
                                    .onTapGesture {
                                        if item == .crop {
                                            photoManager.masking.maskToolOption = .SELECT_MASK
                                            photoManager.inPainting = InPainting()
                                        }
                                        //                                    if item == .lut{
                                        //                                        withAnimation {
                                        //                                            proxy.scrollTo(item, anchor: .center)
                                        //                                        }
                                        //                                    }
                                        photoManager.appState.currentMenuType = item
                                    }
                                    Spacer()
                                }
                            } //.animation(.linear, value: photoManager.maskImage)
                        }
                        .frame(width: photoManager.appState.currentMenuType == .lut ? geo.size.width - (UILayout.EditMenuIconSize) : geo.size.width)
                    }
                    Spacer()
                }
                .overlay {
                    lutcubeView(width: UILayout.EditMenuIconSize, height: UILayout.EditMenuIconSize)
                        .opacity(photoManager.appState.currentMenuType == .lut || photoManager.appState.currentMenuType == .lutCube ? 1 : 0)
                }
            }
        }
    }
    
    func lutcubeView(width: CGFloat, height: CGFloat) -> some View {
        HStack{
            Spacer()
            Divider()
            ZStack{
                Rectangle().fill(.black)
                    .frame(width: width, height: height)
                    .overlay{
                        VStack {
                            Spacer()
                            Image(systemName: "rotate.3d.fill")
                                .appButtonStyle2(active: photoManager.appState.currentMenuType == .lutCube)
                                .font(.appButtonNormalFont)
                            Spacer()
                            Text("3D View")
                                .appTextStyle(active: photoManager.appState.currentMenuType == .lutCube)
                        }
                        .padding([.top, .bottom], UILayout.CommonGap/2)
                        .frame(width: UILayout.EditMenuIconSize, height: UILayout.EditMenuIconSize, alignment: .bottom).clipped()
                        .onTapGesture {
                            photoManager.appState.currentMenuType = .lutCube
                        }
                    }
            }
        }
    }
}

public enum EditMenuType : String, CaseIterable {
    case mask = "Mask Edit"
    case lut = "LUT"
    case filter = "Adjust"
    case crop = "Crop"
    case text = "Text"
    case background = "Fill"
    case lutCube = "3D View"
    
    var imageIcon : String {
        switch self {
        case .mask :
            "scissors"
        case .lut:
            "cube"
        case .filter:
            "camera.filters"
        case .crop:
            "crop.rotate"
        case .text:
            "textformat"
        case .background:
            "circle.rectangle.filled.pattern.diagonalline"
            //"person.and.background.striped.horizontal"
        case .lutCube:
            "rotate.3d.fill"
        }
    }
}
