//
//  Constants.swift
//  SegmentAnywhere
//
//  Created by hansoong choong on 1/11/23.
//

import Foundation
import SwiftUI

struct ViewModel {
    static let IconSize : CGFloat = 100
    static let CustomActivity : String = "com.noname.cutcha.savematerial"
}

struct UILayout {
    static let EditMenuTopBarHeight : CGFloat = 40
//    static let EditMenuBarHeight : CGFloat = 55
    static let EditMenuBarHeight : CGFloat = 65 //60
    static let EditMenuIconSize : CGFloat = 60
    
    //vh : increase to accommodate for other view
    static let EditMaskBarHeight : CGFloat = 120
    static let EditMaskButtonHightLightHeight : CGFloat = 50
    static let EditMaskSubButtonHightLightHeight : CGFloat = 20
    static let EditMaskThumbnailSize : CGFloat = 100
//    static let EditMaskButtonSize : CGFloat = 40
    
    static let TextEditBarHeight : CGFloat = 180
    
    static let CardHeight : CGFloat = 65
    static let MenuOptionBarHeight : CGFloat = 100 //90
    static let LUTFavoriteIconSize : CGFloat = 25
    
    static let CustomIconImgSize : CGFloat = 20
    
    static let AdjustMaskOptionButtonWidth : CGFloat = 65
    static let AdjustMaskOptionButtonHeight : CGFloat = 45
    
    static let ColorEditButtonHorizontalPadding : CGFloat = 20.0
//    static let ColorEditButtonVerticalPadding : CGFloat = 5.0
    static let ColorEditButtonVerticalPadding : CGFloat = 10.0
    static let CommonGap : CGFloat = 8.0
    
    static let ColorButtonViewSize : CGFloat = EditMaskBarHeight - EditMenuBarHeight
    static let ColorButtonSize : CGFloat = 30
    
    static let OkXButtonImgSize : CGFloat = 25
    static let OkXButtonHeight : CGFloat = 60
    static let OkXButtonWidth : CGFloat = 55
    
    static let UndoResetToggleButtonImgSize : CGFloat = 20
    
    static let LoadingInfoDelay : CGFloat = 1.5
    static let DisplayImageDelay : CGFloat = 0.2
    static let Min_Control_Size : CGFloat = 20
    
    static let LUTOptionHeight: CGFloat = 40
    static let ShowFavBarHeight: CGFloat = 20
    
    
}

struct SegmentConfig {
    static let MIN_RECT_SIZE = 30.0 ///pixel
}

struct WorkingImageSize {
    static let minSize : CGFloat = 1024
    static let maxSize : CGFloat = 2048
}

struct PresetGradient {
    static let RAINBOW = LinearGradient(
        gradient: .init(colors: [.red, .orange, .yellow, .green, .blue, .purple, .pink]),
        startPoint: .init(x: 0, y: 0.5),
        endPoint: .init(x: 1, y: 0.5)
    )
    
    static let SLAB_SELECT = LinearGradient(
        gradient: .init(colors: [.white, .red]),
        startPoint: .init(x: 0, y: 0),
        endPoint: .init(x: 1, y: 1)
    )
    
    static let SLAB_MOVE = LinearGradient(
        gradient: .init(colors: [.white, .blue]),
        startPoint: .init(x: 0, y: 0),
        endPoint: .init(x: 1, y: 1)
    )
    
    static let SLAB_EDIT = LinearGradient(
        gradient: .init(colors: [.appDarkGray, .appDarkGray]),
        startPoint: .init(x: 0, y: 0),
        endPoint: .init(x: 1, y: 1)
    )
}

enum MaskAnimation : String, CaseIterable, Identifiable {
    
    var id: Self { return self }
    
    case ANT_WALKING
    case FOLLOW_PATH
}

enum SegmentModel : String, CaseIterable, Identifiable {
    
    var id: Self { return self }
    
    case DEEPLAB_V3
    case EDGE_SAM
}

enum MaskToolOption : String, CaseIterable, Identifiable {
    var id: Self { return self }
    
    case SELECT_MASK = "Select Mask"
    case MOVE_OBJECT = "Move Object"
    case REMOVE_OBJECT = "Remove Object"
    case EXPAND_MASK = "Grow/Shrink Mask"
}

enum MaskFillOption : String, CaseIterable, Identifiable {
    var id: Self { return self }
    
    case MASK_ONLY = "Mask Only"
    case INVERSE_MASK = "Inverse Mask"
    case FULL_IMAGE = "Full Image"
}

// MARK: helper structures
enum ImageState : Equatable {
    static func == (lhs: ImageState, rhs: ImageState) -> Bool {
        switch (lhs, rhs) {
        case (.empty, .empty):
            return true
        case (.loading(_), .loading(_)):
            return true
        case (.success, .success):
            return true
        default :
            return false
        }
    }
    
    case empty
    case loading(Progress)
    case success
    case failure(Error)
}


public extension UIDevice {
    
    static var modelCode : String {
        var systemInfo = utsname()
        //let _ = print("systemInfo = \(systemInfo)")
        uname(&systemInfo)
        let modelCode = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                //ptr in String.init(validatingUTF8: ptr)
                ptr in String(cString: ptr)
            }
        }
        return modelCode
    }
    
    static var canRunEdgeSamNeuralEngine : Bool {
        let modelCode = modelCode
        if modelCode.contains("iPhone") {
            if let index = modelCode.firstIndex(of: ",") {
                let startIndex = modelCode.index(modelCode.startIndex, offsetBy: 6)
                let distance = modelCode.distance(from: modelCode.startIndex, to: index)
                if distance > 6 {
                    let endIndex = modelCode.index(modelCode.startIndex, offsetBy: 6 + (distance - 6 - 1))
                    let versionStr = modelCode[startIndex...endIndex]
                    let version = Int(versionStr) ?? 0
                    if version >= 13 { return true }
                }
            }
        } else if modelCode.contains("arm64") {
            return true
        }
        return false
    }
    
    static func isiOSAppOnMac() -> Bool {
      if #available(iOS 14.0, *) {
        return ProcessInfo.processInfo.isiOSAppOnMac
      }
      return false
    }

}

enum ShareAction {
    case NONE
    case SAVE_TO_LIBRARY
    case PASTEBOARD
    case ACTIVITY
}

struct AppInfo {
    static let srInfo = "Apply SR ..."
    static let filterInfo = "Preparing filter ..."
    static let inPaintingFilterInfo = "AI painting ..."
    static let changeInfo = "Apply Change ..."
}

enum LoadingInfo : Equatable {
    static func == (lhs: LoadingInfo, rhs: LoadingInfo) -> Bool {
        switch (lhs, rhs) {
        case (.empty, .empty):
            return true
        case (.loading(_), .loading(_)):
            return true
        default :
            return false
        }
    }
    
    case empty
    case loading(String)
}

enum ViewState {
    case Native
    case Image
    case Camera
}

struct UndoInfo {
    static let suffix = "_CROP"
}
