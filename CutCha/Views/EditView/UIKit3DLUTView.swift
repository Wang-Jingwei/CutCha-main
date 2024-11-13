//
//  UIKit3DLUTView.swift
//  CutCha
//
//  Created by Wang Jingwei on 17/10/24.
//

import SwiftUI
import PhotosUI

struct UIKit3DLUTView: View {
    @EnvironmentObject var photoManager: PhotoManager
    @EnvironmentObject var lutViewModel: LUTViewModel
    
    @State var dragPoint: CGPoint = .zero
    @State var currentLine = Line()
    @State var brushLocation: CGPoint = .zero
    @State var showLastEditImage : Bool = false
    @State private var showShareSheet: Bool = false
    let OptionHeight: CGFloat = 40
    
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
                    LUTEditorMenuUI()
                        .opacity(photoManager.lastFilteringImage != nil ? 1 : 0)
                        .frame(width: geometry.size.width, height: UILayout.LUTOptionHeight + UILayout.LUTOptionHeight + UILayout.ShowFavBarHeight + UILayout.MenuOptionBarHeight)
                    Text("Prepare LUT ...")
                        .appTextStyle2()
                        .opacity(photoManager.lastFilteringImage == nil ? 1 : 0)
                }
            }
        }
    }
}
