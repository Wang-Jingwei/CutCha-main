//
//  LUTEditorMenuUI.swift
//  CutCha
//
//  Created by Wang Jingwei on 17/10/24.
//

import SwiftUI

struct LUTEditorMenuUI: View {
    @AppStorage("favoriteLUT") var favoriteLUT: [String] = []
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var photoManager : PhotoManager
    @EnvironmentObject var lutViewModel:LUTViewModel
    
    @State private var importing = false
    @State var showOKXBar : Bool = false
    @State private var showingErrorAlert = false
    @State private var showingRenameAlert = false
    @State private var newLutName = ""
    @State private var selectedLutItem : LUTItem!
    @State var errorString : String = ""
    
    var body: some View {
        ZStack{
            VStack(spacing:0) {
                maskOptionPanel
                    .frame(height : UILayout.LUTOptionHeight)
                    .background(.black.opacity(0.1))
                if photoManager.appState.currentMenuType == .lutCube {
                    LutSampleView(length: UILayout.LUTOptionHeight + UILayout.MenuOptionBarHeight + UILayout.ShowFavBarHeight)
                        .edgesIgnoringSafeArea(.all)
                        .transition(.opacity)
                }else{
                    lutEditPanel
                        .frame(height : UILayout.LUTOptionHeight)
                        .background(.black)
                    Divider().background(.gray)
                    switch lutViewModel.editType {
                    case .BalancePanel:
                        LutBalanceView()
                            .frame(height : UILayout.MenuOptionBarHeight + UILayout.ShowFavBarHeight, alignment: .center)
                            .background(.black)
                    case .StrengthPanel:
                        LutStrengthView()
                            .frame(height : UILayout.MenuOptionBarHeight + UILayout.ShowFavBarHeight, alignment: .center)
                            .background(.black)
                    case .PresetsPanel:
                        showPresets
                            .frame(height : UILayout.MenuOptionBarHeight + UILayout.ShowFavBarHeight, alignment: .center)
                            .background(.black)
                    
                    }
                }
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
    
    var showPresets: some View{
        VStack(spacing: 0){
            showFav
                .frame(height : UILayout.ShowFavBarHeight)
                .background(.black)
            GeometryReader { geo in
                VStack {
                    Spacer()
                    ZStack{
                        HStack{
                            addNewLUT
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
                                .frame(width: showOKXBar ? geo.size.width - (UILayout.OkXButtonWidth*2) : geo.size.width - UILayout.OkXButtonWidth)
                            }
                            Spacer()
                        }
                        .overlay {
                            okCancelView(width: UILayout.OkXButtonWidth, height: UILayout.MenuOptionBarHeight)
                                .opacity(showOKXBar ? 1 : 0)
                        }
                    }
                    Spacer()
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
    
    var maskOptionPanel : some View {
        HStack {
            Spacer()
            Text("Full")
                    .appTextStyle2(active: photoManager.masking.maskFillOption == .FULL_IMAGE)
            .onTapGesture {
                photoManager.masking.maskFillOption = .FULL_IMAGE
            }
            Spacer()
            
            Text("Masked")
                    .appTextStyle2(active: photoManager.masking.maskFillOption == .MASK_ONLY)
            .onTapGesture {
                photoManager.masking.maskFillOption = .MASK_ONLY
            }
            .opacity(photoManager.maskImage == nil ? 0.5 : 1)
            .disabled(photoManager.maskImage == nil)
            
            Spacer()
            
            Text("Inversed")
                    .appTextStyle2(active:  photoManager.masking.maskFillOption == .INVERSE_MASK)
            .onTapGesture {
                photoManager.masking.maskFillOption = .INVERSE_MASK
            }
            .opacity(photoManager.maskImage == nil ? 0.5 : 1)
            .disabled(photoManager.maskImage == nil)
            
            Spacer()
        }
    }
    
    var lutEditPanel : some View {
        HStack {
            Spacer()
            Text("Balance")
                    .appTextStyle2(active: lutViewModel.editType == .BalancePanel)
            .onTapGesture {
                lutViewModel.editType = .BalancePanel
            }
            Spacer()
            
            Text("Strength")
                    .appTextStyle2(active: lutViewModel.editType == .StrengthPanel)
            .onTapGesture {
                lutViewModel.editType = .StrengthPanel
            }
            
            Spacer()
            
            Text("Presets")
                    .appTextStyle2(active: lutViewModel.editType == .PresetsPanel)
            .onTapGesture {
                lutViewModel.editType = .PresetsPanel
            }
            Spacer()
        }
    }
    
    var showFav : some View{
        VStack{
            Spacer()
            HStack {
                Spacer()
                Text("All presets")
                    .appTextStyle(active: lutViewModel.lutOption == .ALL)
                    .onTapGesture {
                        lutViewModel.lutOption = .ALL
                    }
                Spacer()
                
                Text("Favourites")
                    .appTextStyle(active: lutViewModel.lutOption == .Favorite)
                    .onTapGesture {
                        if !favoriteLUT.isEmpty{
                            lutViewModel.lutOption = .Favorite
                        }
                    }
                    .opacity(favoriteLUT.isEmpty ? 0.5 : 1)
                    .disabled(favoriteLUT.isEmpty)
                Spacer()
            }
        }
    }
    
    func okCancelView(width: CGFloat, height: CGFloat) -> some View {
        HStack {
            ZStack{
                Rectangle().fill(.black)
                    .frame(width: width, height: height)
                    //               .border(Color.checkblue.opacity(0.5))
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
                       //             .border(Color.checkblue.opacity(0.5))
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
               // .border(Color.checkgreen.opacity(0.5))
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
    
    var addNewLUT : some View {
        VStack {
            IconButton(.systemImage, "folder.badge.plus")
            Spacer().frame(height: UILayout.CommonGap/2)
            Text("Add New").appTextStyle()
        }
        .frame(width: UILayout.OkXButtonWidth, height: UILayout.AdjustMaskOptionButtonHeight)
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
    
    func setLutError(_ lutError: LUTError) {
        if lutError != .noError {
            errorString = lutError.rawValue
            showingErrorAlert = true
        }
    }
}

