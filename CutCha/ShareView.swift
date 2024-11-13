//
//  ShareView.swift
//  SegmentAnywhere
//
//  Created by hansoong choong on 7/3/24.
//

import SwiftUI

struct ShareView: View {
    @EnvironmentObject var photoManager : PhotoManager
    @Binding var showShareSheet : Bool
    var showFillBackground : Bool = false
    var shareFullImage : Bool = true
    
    var body: some View {
        Section("Main Option") {
//            Button(action: {
//                photoManager.shareAction(.SAVE_TO_LIBRARY, objectOnly: !shareFullImage)
//            }, label: {
//                Label("Save \(shareFullImage ? "image" : "object")", systemImage: "rectangle.portrait.and.arrow.right.fill")
//            })
            Button(action: {
                showShareSheet.toggle()
            }, label: {
                Label("Share \(shareFullImage ? "image" : "object") ...", systemImage: "square.and.arrow.up")
            })
            if showFillBackground {
                Button(action: {
                    photoManager.masking.maskToolOption = .MOVE_OBJECT
                }, label: {
                    Label("Move object ...", systemImage: "hands.and.sparkles.fill")
                })
                
                Button(action: {
                    photoManager.masking.maskToolOption = .REMOVE_OBJECT
                    photoManager.inPainting.canApplyInPainting = true
                    photoManager.applyInPainting()
                }, label: {
                    Label("Remove object", systemImage: "sparkles")
                })
            }
        }
        if photoManager.maskImage != nil && photoManager.appState.currentMenuType == .mask {
            Section("Mask Option") {
                Button(action: {
                    photoManager.masking.maskToolOption = .EXPAND_MASK
                }, label: {
                    Label("Grow/Shrink ...", systemImage: "square.arrowtriangle.4.outward")
                })
            }
        }
    }
}
