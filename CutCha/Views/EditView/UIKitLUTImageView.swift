/*
 See LICENSE folder for this sample’s licensing information.
 
 Abstract:
 The profile image that reflects the selected item state.
 */

import SwiftUI
import PhotosUI

struct UIKitLUTImageView: View {
    @EnvironmentObject var photoManager: PhotoManager
    @EnvironmentObject var lutViewModel: LUTViewModel
    
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
                    default:
                        Rectangle().foregroundStyle(Color.clear).overlay {
                            ProgressView() {
                                Text("Loading...").foregroundStyle(Color.white)
                            }.tint(.white)
                        }
                    }
                }
                
                ZStack(alignment: .bottom){
                    LUTMenuUI(showEffectList: $photoManager.appState.showEffectList)
                        .opacity(photoManager.lastFilteringImage != nil ? 1 : 0)
                        .frame(width: geometry.size.width, height: UILayout.MenuOptionBarHeight + UILayout.EditMenuBarHeight)
                    Text("Prepare LUT ...")
                        .appTextStyle2()
                        .opacity(photoManager.lastFilteringImage == nil ? 1 : 0)
                }
            }
        }
    }
}
