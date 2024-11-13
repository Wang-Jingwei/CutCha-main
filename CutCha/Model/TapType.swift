//
//  TapType.swift
//  SegmentAnywhere
//
//  Created by hansoong choong on 18/4/24.
//

import Foundation

enum TapType {
    case Point
    case Rect(CGRect)
    case Image(Data)
    
    func getRect() -> CGRect {
        switch self {
            case .Rect(let rect): return rect
            default: return .zero
        }
    }
}

extension TapType {
    var isRectType: Bool {
        switch self {
        case .Rect(_): return true
        default: return false
        }
    }
    
    var isPointType: Bool {
        switch self {
        case .Point: return true
        default: return false
        }
    }
}
