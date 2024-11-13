//
//  ButtonViewList.swift
//  SegmentAnywhere
//
//  Created by hansoong choong on 2/5/24.
//

import SwiftUI
import CoreImage

struct EffectViewList: View {
    
    @EnvironmentObject var effectFilter : EffectFilterViewModel
    @EnvironmentObject var photoManager : PhotoManager
    
    @State var currentIndex : Int = 0
    
    @State var circleAnimate : Bool = false
    @State var effectList : [CIFilterItem] = []
    let effectItem : CIFilterItem
    @Binding var showList : Bool
    
    init(effectItem: CIFilterItem, showList : Binding<Bool>) {
        self.effectItem = effectItem
        self.effectList = effectItem.items
        self._showList = showList
    }
    
    var body: some View {
        if showList {
            HStack(spacing: 0) {
                ForEach(0 ..< effectList.count, id: \.self) { index in
                    EffectCardView(
                        effectList: $effectList,
                        index: index
                    )
                    .padding([.leading, .trailing], UILayout.CommonGap)
                    .onTapGesture {
                        effectFilter.currentEffectItem = effectList[index]
                    }
                } 
            }
            .frame(minWidth : -1, maxWidth: .infinity)
//            .border(Color.checkgreen.opacity(0.5))
        } else {
            EmptyView()
        }
    }
}
