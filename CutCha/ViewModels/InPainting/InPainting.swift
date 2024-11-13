//
//  InPainting.swift
//  SegmentAnywhere
//
//  Created by hansoong choong on 28/3/24.
//

import SwiftUI

struct InPainting {
    ///in painting related
    var canApplyInPainting : Bool = false
    var inPaintingBaseImage : UIImage? = nil
    var inPaintingResultImage : UIImage? = nil
    var inPaintingInfo: LoadingInfo = .empty
    var canInPaintingRetry : Bool = false
}
