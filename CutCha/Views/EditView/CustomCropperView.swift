//
//  CropperViewController.swift
//  colorful-room
//
//  Created by Ping9 on 26/11/2020.
//  Copyright © 2020 PingAK9. All rights reserved.
//

import Foundation
import SwiftUI
import CutchaCropper

struct CustomCropperView: UIViewControllerRepresentable {
    
    @EnvironmentObject var photoManager:PhotoManager
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<CustomCropperView>) -> CropperViewController {
        let picker = CropperViewController(workingImage: photoManager.currentDisplayImage!, initialState: nil)
        picker.delegate = context.coordinator
        
        return picker
    }
    
    func updateUIViewController(_ uiViewController: CropperViewController, context: UIViewControllerRepresentableContext<CustomCropperView>) {
        
    }
    
    func makeCoordinator() -> CropperViewCoordinator {
        return CropperViewCoordinator(self)
    }
}

class CropperViewCoordinator: NSObject, UINavigationControllerDelegate, CropperViewControllerDelegate {
    
    let parent: CustomCropperView
    
    init(_ parent:CustomCropperView) {
        self.parent = parent
    }
    
    func cropperDidConfirm(_ cropper: CropperViewController, state: CropperState?) {
        if let cropState = state {
            
            parent.photoManager.updateCropState(cropState: cropState)
            parent.photoManager.resetCrop()
            DispatchQueue.main.asyncAfter(deadline: .now() + UILayout.DisplayImageDelay) { [self] in
                parent.photoManager.appState.currentMenuType = .filter
            }
        }
    }
    
    func cropperDidCancel(_ cropper: CropperViewController) {
    }
    
    func cropperSetIntialState(_ cropper: CropperViewController, state: CropperState?) {
    }
}

//struct croppreview : PreviewProvider {
//    static var previews: some View {
//        let photoManager = PhotoManager()
//
//        CustomCropperView()
//            .environmentObject(photoManager)
//    }
//}
