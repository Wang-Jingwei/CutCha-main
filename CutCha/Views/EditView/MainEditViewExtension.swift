//
//  MainEditViewExtension.swift
//  SegmentAnywhere
//
//  Created by hansoong choong on 13/6/24.
//

import SwiftUI

extension MainEditView {
    
    @ViewBuilder
    func thumbnailView(geometry: GeometryProxy) -> some View {
        if photoManager.appState.currentMenuType != .text {
            if let maskImage = thumbnailMaskImage {
                //let offsetY = 2 * UILayout.EditMaskBarHeight + UILayout.EditMaskButtonHightLightHeight + 10
                Image(uiImage: maskImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: UILayout.EditMaskThumbnailSize)
                    .border(Color.gray)
                    .opacity(0.7).overlay {
                        Rectangle()
                            .stroke(Color.appMain, lineWidth: 1)
                    }
                    .offset(x : currentOffsetX + dragState.translation.width,
                            y : UILayout.EditMenuTopBarHeight + 5)
                    .scaleEffect(dragState.isDragging ? 0.95 : 1)
                    .animation(.interpolatingSpring(stiffness: 120, damping: 120), value: 1)
                    .gesture(LongPressGesture(minimumDuration: 0.01)
                        .sequenced(before: DragGesture())
                        .updating(self.$dragState, body: { (value, dstate, transaction) in
                            switch value {
                            case .first:
                                dstate = .pressing
                            case .second(true, let drag):
                                dstate = .dragging(translation: drag?.translation ?? .zero)
                            default:
                                break
                            }
                        })
                        .onEnded({ value in
                            switch value {
                            case .second(true, let drag):
                                let maxOffsetX = (geometry.size.width - UILayout.EditMaskThumbnailSize) / 2
                                currentOffsetX = currentOffsetX + ((drag != nil) ? drag!.translation.width : 0)
                                currentOffsetX = minMax(minValue: -maxOffsetX, maxValue: maxOffsetX, value: currentOffsetX)
                            default:
                                break
                            }
                            let maxOffsetX = (geometry.size.width - UILayout.EditMaskThumbnailSize) / 2
                            currentOffsetX = minMax(minValue: -maxOffsetX, maxValue: maxOffsetX, value: currentOffsetX)
                        })
                    )
            }
        }
    }
//    
//    func getOffsetX(geometry: GeometryProxy) -> CGFloat {
//        let maxOffsetX = (geometry.size.width - UILayout.EditMaskThumbnailSize) / 2
//        currentOffsetX = currentOffsetX + dragState.translation.width
//        currentOffsetX = minMax(minValue: -maxOffsetX, maxValue: maxOffsetX, value: currentOffsetX)
//        return currentOffsetX
//    }
}

enum DragState {
    case inactive
    case pressing
    case dragging(translation: CGSize)
    
    var translation: CGSize {
        switch self {
        case .inactive, .pressing:
            return .zero
        case .dragging(let translation):
            return translation
        }
    }
    
    var isDragging: Bool {
        switch self {
        case .dragging:
            return true
        case .pressing, .inactive:
            return false
        }
    }
    
    var isPressing: Bool {
        switch self {
        case .inactive:
            return false
        case .pressing, .dragging:
            return true
        }
    }
}
