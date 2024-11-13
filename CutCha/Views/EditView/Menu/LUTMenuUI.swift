//
//  FilterMenuView.swift
//  colorful-room
//
//  Created by macOS on 7/14/20.
//  Copyright © 2020 PingAK9. All rights reserved.
//

import SwiftUI

struct LUTMenuUI: View {
    
    @AppStorage("favoriteLUT") var favoriteLUT: [String] = []
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var photoManager : PhotoManager
    @EnvironmentObject var lutViewModel:LUTViewModel
    
    @State var showList : Bool = false
    @Binding var showEffectList : [Bool]
    
    @State private var importing = false
    
    @State private var showingErrorAlert = false
    @State private var showingRenameAlert = false
    @State private var newLutName = ""
    @State private var selectedLutItem : LUTItem!
    @State var errorString : String = ""
    
    // MARK: vh: use better condition checking comparison
    @State var showOKXBar : Bool = false
    
    var body: some View {
        ZStack {
            VStack(spacing:0) {
                HStack {
                    Spacer()
                    addNewLUT
                    Spacer()
                    allFavLutOptionIcon
                    Spacer()
                    Divider()
                    Spacer()
                    maskOptionPanel
                    Spacer()
                }
                .frame(height : UILayout.EditMenuBarHeight)
                .background(.black)
                Divider().background(.gray)
                
                GeometryReader { geo in
                    ZStack {
                        HStack{
                            Spacer()
                            ScrollViewReader { proxy in
                                ScrollView(.horizontal, showsIndicators: false) {
                                    LazyHStack(spacing : 0) {
                                        ForEach(getLUTList(lutViewModel.lutOption), id: \.self) { lutItem in
                                            LutCardView(
                                                lutItem: lutItem,
                                                favoriteLUT: $favoriteLUT,
                                                showingRenameAlert: $showingRenameAlert,
                                                selectedLutItem: $selectedLutItem
                                            )
                                            .id(lutItem)
                                            .padding([.leading, .trailing], UILayout.CommonGap)
                                            .onTapGesture {
                                                showOKXBar = true
                                                lutViewModel.setLUTItem(lutItem, refreshIcon: false)
                                                withAnimation {
                                                    proxy.scrollTo(lutItem, anchor: .center)
                                                }
                                            }
                                        }
                                    }
                                }
                                .frame(width: showOKXBar ? geo.size.width - (UILayout.OkXButtonWidth*2) : geo.size.width)
                            }
                            Spacer()
                        }
                        .overlay {
                            okCancelView(width: UILayout.OkXButtonWidth, height: UILayout.MenuOptionBarHeight)
                                .opacity(showOKXBar ? 1 : 0)
                        }
                    }
                }
                .frame(height : UILayout.MenuOptionBarHeight)
                //                .border(Color.checkred.opacity(1))
                .background(.black)
            }
        }.alert(errorString, isPresented: $showingErrorAlert) {
            Button("OK", role: .cancel) { }
        }.alert("Enter new name", isPresented: $showingRenameAlert) {
            VStack {
                TextField("New name", text: $newLutName)
                    .foregroundColor(.blue)
                HStack {
                    Button("OK", action: changeLUTName)
                    Button("Cancel", role: .cancel, action: {})
                }
            }
        }
    }
    
    func changeLUTName() {
        let fileName = newLutName.convertToValidFileName().trimmingCharacters(in: .whitespacesAndNewlines)
        if fileName.count > 0 {
            if lutViewModel.lutList.firstIndex(where: { item in
                item.name.lowercased() == fileName.lowercased()
            }) != nil {
                errorString = "Duplicate Name, rename failed."
                showingErrorAlert.toggle()
                return
            }
            lutViewModel.renameItem(selectedLutItem, fileName)
        } else {
            errorString = "Name empty, rename failed."
            showingErrorAlert.toggle()
        }
    }
    
    func okCancelView(width: CGFloat, height: CGFloat) -> some View {
        HStack {
            ZStack{
                Rectangle().fill(.black)
                    .frame(width: width, height: height)
                //                    .border(Color.checkblue.opacity(0.5))
                    .overlay {
                        IconButton(.systemImage, "xmark", colorStyle: Color.appMain)
                        //                            .foregroundStyle(Color.appMain)
                            .cornerRadius(5)
                    }
                    .onTapGesture {
                        lutViewModel.setLUTItem(.Identity)
                        showOKXBar = false
                    }
                    .shadow(color: .black, radius: CGFloat(5), x: CGFloat(5), y: CGFloat(0))
            }
            .frame(width: width + 15, height: height, alignment: .leading)
            .clipped()
            
            Spacer()
            
            ZStack{
                Rectangle().fill(.black)
                    .frame(width: width, height: height)
                //                    .border(Color.checkblue.opacity(0.5))
                    .overlay {
                        IconButton(.systemImage, "checkmark", colorStyle: Color.appMain)
                            .foregroundStyle(Color.appMain)
                            .cornerRadius(5)
                        //                        .border(Color.checkred.opacity(0.5))
                    }
                    .onTapGesture {
                        photoManager.processImage()
                        lutViewModel.currentLUTItem = .Identity
                        showOKXBar = false
                    }
                    .shadow(color: .black, radius: CGFloat(5), x: CGFloat(-5), y: CGFloat(0))
            }
            .frame(width: width + 15, height: height, alignment: .trailing)
            .clipped()
        }
        //        .border(Color.checkgreen.opacity(0.5))
    }
    
    func menuItems(for lutItem: LUTItem) -> some View {
        Group {
            Button("Rename...", action: {
                selectedLutItem = lutItem
                showingRenameAlert.toggle()
            })
            Button("Delete", action: {
                lutViewModel.removeItem(lutItem)
            })
        }
    }
    
    func setLutError(_ lutError: LUTError) {
        if lutError != .noError {
            errorString = lutError.rawValue
            showingErrorAlert = true
        }
    }
    
    func getLUTList(_ lutOption: LUTOption) -> [LUTItem] {
        let favListItem = lutViewModel.lutList.filter { favoriteLUT.contains($0.name.lowercased()) }
        let noFavList = lutViewModel.lutList.filter { !favoriteLUT.contains($0.name.lowercased()) }
        if lutOption == .Favorite {
            return favListItem
        }
        else {
            return favListItem + noFavList
        }
    }
    
    var canDisplayOption: Bool {
        if photoManager.currentDisplayImage != photoManager.lastEditImage {
            return true
        }
        return false
    }
    
    var lutOptionPanel : some View {
        HStack {
        }
    }
    
    var allFavLutOptionIcon : some View {
        VStack {
            if lutViewModel.lutOption == .ALL {
                VStack(spacing: 0){
                    IconButton(.custom, "heart-stack", customImgSize: 23)
                    Spacer().frame(height: UILayout.CommonGap/2)
                    Text("Favorite").appTextStyle()
                }
                .opacity(favoriteLUT.isEmpty ? 0.7 : 1)
            }
            else if lutViewModel.lutOption == .Favorite {
                IconButton(.systemImage, "rectangle.stack")
                Spacer().frame(height: UILayout.CommonGap/2)
                Text("All LUT").appTextStyle()
            }
        }
        .frame(width: UILayout.AdjustMaskOptionButtonWidth, height: UILayout.AdjustMaskOptionButtonHeight)
//        .border(Color.checkblue.opacity(0.5))
        .onTapGesture {
            if lutViewModel.lutOption == .ALL && !favoriteLUT.isEmpty {
                lutViewModel.lutOption = .Favorite
            } else if lutViewModel.lutOption == .Favorite {
                lutViewModel.lutOption = .ALL
            }
        }
        //            .border(Color.checkblue.opacity(0.5))
    }
    
    var addNewLUT : some View {
        VStack {
            IconButton(.systemImage, "folder.badge.plus")
            Spacer().frame(height: UILayout.CommonGap/2)
            Text("Add New").appTextStyle()
        }
        .frame(width: UILayout.AdjustMaskOptionButtonWidth, height: UILayout.AdjustMaskOptionButtonHeight)
//        .border(Color.checkblue.opacity(0.5))
        .onTapGesture {
            importing = true
        }
        .fileImporter(
            isPresented: $importing,
            allowedContentTypes: [.importTextLUT, .importImageLUT]
        ) { result in
            switch result {
            case .success(let url):
                setLutError(lutViewModel.importFromURL(url))
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
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


extension Array:@retroactive RawRepresentable where Element: Codable {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode([Element].self, from: data)
        else {
            return nil
        }
        self = result
    }

    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        return result
    }
}
