/*
 See LICENSE folder for this sample’s licensing information.
 
 Abstract:
 The profile image that reflects the selected item state.
 */

import SwiftUI
import PhotosUI

struct UIKitFillEditImageView: View {
    @EnvironmentObject var photoManager: PhotoManager
    @EnvironmentObject var fillVM: FillBackgroundViewModel
    @EnvironmentObject var polynomialTransformer: PolynomialTransformer
    
    @State var dragPoint: CGPoint = .zero
    @State var currentLine = Line()
    @State var brushLocation: CGPoint = .zero
    @State var showLastEditImage : Bool = false
    @State private var showShareSheet: Bool = false
    
    @State var objectBoundary : CGRect = .zero
    @State var currentObjectBoundary : CGRect = .zero
    @State var elementTransform: (Direction?, CGOffset) = (nil, .zero)
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                ZStack {
                    switch photoManager.appState.imageState {
                    case .success:
                        PhotoScrollView(showLastEditImage: $showLastEditImage,
                                        showShareSheet: $showShareSheet,
                                        geometry: geometry
                        )
                        .onAppear {
                                polynomialTransformer.sourceImage = photoManager.lastFilteringImage
                        }
                        
                    default:
                        Rectangle().foregroundStyle(Color.clear).overlay {
                            ProgressView() {
                                Text("Loading...").foregroundStyle(Color.white)
                            }.tint(.white)
                        }
                    }
                }
                
                ZStack {
                    FillMenuUI(showColorList: $photoManager.appState.showColorList)
                        .opacity(photoManager.lastFilteringImage != nil ?
                                 (fillVM.currentFillItem == .noneFill ? 1 : 0) : 0)
                        .frame(width: geometry.size.width, height: UILayout.MenuOptionBarHeight + UILayout.EditMenuBarHeight)
                    Text("Prepare fill tools ...")
                        .appTextStyle2()
                        .opacity(photoManager.lastFilteringImage == nil ? 1 : 0)
                    if fillVM.currentFillItem != .noneFill {
                        adjustFillPanel
                            .frame(width: geometry.size.width, height: UILayout.MenuOptionBarHeight + UILayout.EditMenuBarHeight)
                            .background(.black)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    var adjustFillPanel : some View {
        if fillVM.currentFillItem != .noneFill {
            VStack{
                getFillPanelView
                    .padding(.horizontal, UILayout.CommonGap)
                okCancelView
                Spacer()
            }
        }
    }
    
    var okCancelView : some View {
        return OkCancelView(
            title: "",
            actions: [
            ("xmark", {
                fillVM.reset()
                polynomialTransformer.initialHandler()
            }),
            ("checkmark", {
                photoManager.processImage()
                if fillVM.currentFillItem != .noneFill {
                    if case .gradient = fillVM.currentFillItem.fillEffect {
                        fillVM.updateOrCreateGradient(fillVM.currentFillItem)
                    }
                }
                fillVM.reset()
                polynomialTransformer.sourceImage = photoManager.currentDisplayImage
            })
            ], buttonSize: 30)
    }
    
    @ViewBuilder
    var getFillPanelView: some View {
        switch fillVM.currentFillItem.fillEffect {
        case .none:
            EmptyView()
        case .color(let color):
            FillColorView(originalColor: color)
        case .gradient(_):
            FillGradientView()
        case .image(_):
            FillMaterialView()
        }
    }
}
