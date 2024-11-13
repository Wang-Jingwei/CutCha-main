//
//  EditView.swift
//  SegmentAnywhere
//
//  Created by hansoong choong on 29/12/23.
//

import SwiftUI
import PhotosUI
import StoreKit

struct MainEditView: View {
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var photoManager : PhotoManager
    @EnvironmentObject var polynomialTransformer: PolynomialTransformer
    @EnvironmentObject var morphologyTransformer: MorphologyTransformer
    @Environment(\.requestReview) var requestReview
    
    //@State var maskEditState = MaskEditState()
    
    /// display setting page
    @State var showSetting : Bool = false
    @State var presentLibrary : Bool = false
    @State private var showShareSheet: Bool = false
    @State var captureInfo : String = ""
    
    ///masked image sharing
    @State private var showSharePopover = false
    @State private var showFeedback = false
    
    @State var counter : Int = 1
    @GestureState var dragState = DragState.inactive
    @State var currentOffsetX : CGFloat = 0
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ZStack(alignment:.top) {
                    HStack {
                        leadingView
                        Spacer()
                        trailingView
                    }
                    .frame(height: UILayout.EditMenuTopBarHeight)
                    .zIndex(1000)
                    VStack(spacing:0) {
                        if photoManager.appState.imageState != .empty {
                            switch photoManager.appState.currentMenuType {
                                
                            case .mask:
                                MainMaskView(manualMaskState:$photoManager.manualMaskState)
                                    .frame(width: geo.size.width, height: geo.size.height - UILayout.EditMenuBarHeight)
                                    .id(counter)
                                
                            case .lut, .lutCube:
                                UIKit3DLUTView()
                                    .frame(width: geo.size.width, height: geo.size.height - UILayout.EditMenuBarHeight)
                                    .id(counter)

                            case .filter:
                                UIKitColorEditImageView()
                                    .frame(width: geo.size.width, height: geo.size.height - UILayout.EditMenuBarHeight)
                                    .id(counter)

                            case .crop:
                                CustomCropperView()
                                    .frame(width: geo.size.width, height: geo.size.height - UILayout.EditMenuBarHeight)
                            
                            case .text:
                                UIKitTextEditImageView(textOptions: $photoManager.textManager.textOptions, currentTextIndex: $photoManager.textManager.currentTextIndex)
                                    .frame(width: geo.size.width, height: geo.size.height - UILayout.EditMenuBarHeight)
                                    .id(counter)
                                
                            case .background:
                                UIKitFillEditImageView()
                                    .frame(width: geo.size.width, height: geo.size.height - UILayout.EditMenuBarHeight)
                                    .id(counter)
                            }
                            
                            Divider()
                                .background(.gray)
                                .padding([.leading, .trailing], 5)
                            
                            EditMenuView()
                                .frame(width:geo.size.width, height:UILayout.EditMenuBarHeight)
                                .background(Color.black)
                                .disabled(photoManager.inPainting.inPaintingInfo == .empty ? false : true)
                        } else {
                            Spacer()
                        }
                    }
                    //if photoManager.maskImage != nil {
                    thumbnailView(geometry: geo)
                }
                if showSetting {
                    SettingView(showSetting: $showSetting)
                }
                Text(captureInfo)
                    .font(.caption)
                    .infoView(isShow: captureInfo.isEmpty ? false : true)
            }
            .navigationBarHidden(true)
            .frame(maxWidth: .infinity, maxHeight : .infinity)
            .sheet(isPresented: $showShareSheet, onDismiss: {
                //print("Dismiss")
            }, content: {
                if photoManager.currentDisplayImage != nil {
                    UIShareView(items: [photoManager.currentDisplayImage!])
                } else {
                    UIShareView(items: [URL(string: "https://mmlab-ntu.github.io/project/edgesam/")!])
                }
            })
            .onAppear {
                if photoManager.appState.imageState == .empty {
                    presentLibrary = true
                }
                let lastIndex = photoManager.appState.showEffectList.count - 1
                photoManager.appState.showEffectList[lastIndex] = true
                
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                    if photoManager.appState.currentMenuType == .filter || photoManager.appState.currentMenuType == .mask {
                        DispatchQueue.main.asyncAfter(deadline: .now() + UILayout.DisplayImageDelay) {
                            counter = counter + 1
                        }
                    }
                }
                currentOffsetX = (geo.size.width - UILayout.EditMaskThumbnailSize) / 2
            }
        }.background (
            Rectangle()
                .fill(PresetGradient.SLAB_EDIT)
                .opacity(1.0)
        )
        .onChange(of: photoManager.appState.currentMenuType) {
            if photoManager.appState.currentMenuType == .mask {
                if photoManager.isDirty {
                    Task {
                        photoManager.appState.imageState = .loading(.discreteProgress(totalUnitCount: 10))
                        photoManager.resetEdit()
                        DispatchQueue.main.asyncAfter(deadline: .now() + UILayout.DisplayImageDelay) {
                            photoManager.prepareEdgeSAM()
                        }
                    }
                }
            }
        }
        .onChange(of: photoManager.appState.loadingInfo) {
            switch photoManager.appState.loadingInfo {
            case .loading(let info):
                captureInfo = info
            default:
                captureInfo = ""
            }
        }
    }
    
    var thumbnailMaskImage : UIImage? {
        if photoManager.maskImage == nil {
            return nil
        }
        
        if photoManager.appState.currentMenuType == .mask {
            return photoManager.maskImage!
        } else {
            switch photoManager.masking.maskFillOption {
            case .MASK_ONLY:
                return photoManager.maskImage!
            case .INVERSE_MASK:
                return photoManager.maskImage?.imageColorInvert()
            default:
                return nil
            }
        }
    }
    
    @ViewBuilder
    var leadingView: some View {
        HStack {
            ZStack {
                Image(systemName: "photo.on.rectangle.angled")
                    .photosPicker(isPresented: $presentLibrary,
                                  selection: $photoManager.imageSelection,
                                  matching: .images,
                                  photoLibrary: .shared())
                    .opacity(0)
                    .font(.title3)
//                    .border(Color.checkred.opacity(0.5))
                Button {
                    presentLibrary = true
                } label: {
                    Color.black.opacity(0.01).overlay {
                        MKSymbolShape(systemName: "photo.on.rectangle.angled")
                            .stroke(.black, lineWidth: 2)
                            .fill(.white)
                            .background(.black.opacity(0.01))
                            .frame(width:28, height: 24)
                    }
                }
                .frame(width:UILayout.EditMenuTopBarHeight, height: UILayout.EditMenuTopBarHeight)
                .opacity(canShowPhotoLibrary ? 1 : 0)
//                .border(Color.checkblue.opacity(0.5))
            }
        }
    }
    
    var canShowPhotoLibrary : Bool {
        if photoManager.appState.currentMenuType == .crop || photoManager.inPainting.inPaintingInfo != .empty ||
            photoManager.appState.imageState == .loading(Progress(totalUnitCount: 10)) {
            return false
        }
        return true
    }
    
    @ViewBuilder
    var trailingView: some View {
        HStack {
            
            Button {
                if photoManager.appState.currentMenuType != .text {
                    photoManager.shareAction(.SAVE_TO_LIBRARY)
                } else {
                    photoManager.textManager.shareAction = .SAVE_TO_LIBRARY
                }
            } label: {
                Color.black.opacity(0.01).overlay {
                    MKSymbolShape(systemName: "square.and.arrow.down")
                        .stroke(.black, lineWidth: 2)
                        .fill(.white)
                        .background(.black.opacity(0.01))
                        .frame(width:20, height: 24)
//                        .border(Color.checkred.opacity(0.5))
                }
            }
            .frame(width:UILayout.EditMenuTopBarHeight, height: UILayout.EditMenuTopBarHeight)
            .opacity(UIDevice.isiOSAppOnMac() ? 0 : 1)
//            .border(Color.checkblue.opacity(0.5))
            
            Button {
                if photoManager.appState.currentMenuType != .text {
                    showShareSheet.toggle()
                }else {
                    photoManager.textManager.shareAction = .ACTIVITY
                }
            } label: {
                Color.black.opacity(0.01).overlay {
                    MKSymbolShape(systemName: "square.and.arrow.up")
                        .stroke(.black, lineWidth: 2)
                        .fill(.white)
                        .background(.black.opacity(0.01))
                        .frame(width:20, height: 24)
//                        .border(Color.checkred.opacity(0.7))
                }
            }.frame(width:UILayout.EditMenuTopBarHeight, height: UILayout.EditMenuTopBarHeight)
//                .border(Color.checkblue.opacity(0.5))
            
            Button {
                showFeedback.toggle()
            } label: {
                Color.black.opacity(0.01).overlay {
                    MKSymbolShape(systemName: "ellipsis")
                        .stroke(.black, lineWidth: 2)
                        .fill(.white)
                        .background(.black.opacity(0.01))
                        .frame(width:24, height: 6)
//                        .border(Color.checkred.opacity(0.5))
                }
            }
            .frame(width:UILayout.EditMenuTopBarHeight, height: UILayout.EditMenuTopBarHeight)
            .sheet(isPresented: $showFeedback) {
                feedbackContent
                    .presentationBackground(.clear)
                    .presentationDetents([.height(250)])
                
                    
            }
//            .border(Color.checkblue.opacity(0.5))
        }
    }
    
    var settingButton : some View {
        Button {
            withAnimation {
                showSetting.toggle()
            }
        } label: {
            AppAsset.settings.0
        }
    }
    
    @ViewBuilder
    var feedbackContent : some View {
        VStack {
            VStack {
                
                Button("Review the app") {
                    showFeedback.toggle()
                    requestReview()
                    
                }.frame(maxWidth: .infinity, maxHeight: 50)
                Divider()
                Button("Settings") {
                    showFeedback.toggle()
                    showSetting.toggle()
                }.frame(maxWidth: .infinity, maxHeight: 50)
                Divider()
                Button(role: .destructive, action: {
                    showFeedback.toggle()
                    photoManager.handleImageSizeChanged()
                    if photoManager.appState.currentMenuType == .crop {
                        photoManager.appState.currentMenuType = .filter
                    }
                }, label: {
                    Text("Revert to Original")
                })
                .frame(maxWidth: .infinity, maxHeight: 50)
                
            }
            .background(Color.appLightGray)
            .cornerRadius(10)
            
            Button("Cancel"){
                showFeedback.toggle()
            }
            .frame(maxWidth: .infinity, maxHeight: 50)
            .background(.white)
            .cornerRadius(10)
        }
        .padding()
        .bold()
        //.scrollContentBackground(.hidden)
        //.contentMargins(.vertical, 1)
        
            
    }
    
    var shareContent : some View {
        HStack {
            Button {
                photoManager.shareAction(.SAVE_TO_LIBRARY)
                showSharePopover.toggle()
            } label: {
                AppAsset.saveToLibrary.0
            }
            Spacer(minLength: 20)
            Button {
                photoManager.shareAction(.PASTEBOARD)
                showSharePopover.toggle()
            } label: {
                AppAsset.copyPasteboard.0
            }
        }
        .presentationCompactAdaptation(.none)
        .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
    }
}

//struct CheckToggleStyle: ToggleStyle {
//    func makeBody(configuration: Configuration) -> some View {
//        Button {
//            configuration.isOn.toggle()
//        } label: {
//            Label {
//                configuration.label
//            } icon: {
//                Image(uiImage: UIImage(named: configuration.isOn ? "Manual_Edit" : "Touch")!)
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .padding(5)
//            }
//        }
//        .frame(height: 40)
//        .buttonStyle(.plain)
//    }
//}

struct ManualMaskState {
    var manualMaskEdit : Bool = false
    var maskColor = Color.green
    var brushSize : Int = 25
    var paintTool : PaintTool = .brush
}

enum PaintTool {
    case brush
    case eraser
}
