/*
 See LICENSE folder for this sample’s licensing information.
 
 Abstract:
 The profile image that reflects the selected item state.
 */

import SwiftUI
import PhotosUI

struct UIKitColorEditImageView: View {
    @EnvironmentObject var photoManager: PhotoManager
    @EnvironmentObject var effectFilter: EffectFilterViewModel
    @EnvironmentObject var polynomialTransformer: PolynomialTransformer
    
    @State var dragPoint: CGPoint = .zero
    @State var currentLine = Line()
    @State var brushLocation: CGPoint = .zero
    @State var showLastEditImage : Bool = false
    @State private var showShareSheet: Bool = false
    
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
                    FilterMenuUI(showEffectList: $photoManager.appState.showEffectList)
                        .opacity(photoManager.lastFilteringImage != nil ?
                                 (effectFilter.currentEffectItem == .noneEffect ? 1 : 0) : 0)
                        .frame(width: geometry.size.width, height: UILayout.MenuOptionBarHeight + UILayout.EditMenuBarHeight)
                    Text("Prepare filters ...")
                        .appTextStyle2()
                        .opacity(photoManager.lastFilteringImage == nil ? 1 : 0)
                    if effectFilter.currentEffectItem != .noneEffect {
                        effectFilterPanel
                            //.frame(height: UILayout.EditMaskBarHeight)
                            .frame(width: geometry.size.width, height: effectFilter.currentEffectItem.ciFilterEffect.preferHeight)
                            .background(.black)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    var effectFilterPanel : some View {
        if effectFilter.currentEffectItem != .noneEffect {
            VStack{
                Spacer()
                getEffectView.padding(UILayout.CommonGap)
                Spacer()
                okCancelView
            }
//            .border(Color.checkred.opacity(0.5))
        }
    }
    
    var okCancelView : some View {
        let title = effectFilter.panelType == .basicPanel ? effectFilter.currentEffectItem.name : effectFilter.currentEffectItem.iconName
        return OkCancelView(
            title: title,
            actions: [
            ("xmark", {
                effectFilter.currentEffectItem = .noneEffect
                polynomialTransformer.initialHandler()
            }),
            ("checkmark", {
                photoManager.processImage()
                effectFilter.currentEffectItem = .noneEffect
                polynomialTransformer.sourceImage = photoManager.currentDisplayImage
            })
        ])
    }
}
