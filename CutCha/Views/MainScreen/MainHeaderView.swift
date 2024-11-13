//
//  CardView.swift
//  Example
//
//  Created by Danil Kristalev on 30.12.2021.
//  Copyright © 2021 Exyte. All rights reserved.
//

import SwiftUI

struct MainHeaderView: View {

    var progress: CGFloat

    private var isCollapsed: Bool {
        progress > 0.7
    }
    
    @EnvironmentObject var photoManager : PhotoManager
    
    @State var filters = AIFilterConstants.staticAIFilters
    let inPaintingFilter = AIFilterItem("In Painting", imageName: "in_painting", filter: AIFilter.inpainting)
    
    var body: some View {
        ZStack {
            ScrollView(.horizontal, showsIndicators: false){
                HStack {
                    ForEach(filters, id: \.name) { filter in
                        MainButtonView(item: filter)
                            .frame(maxHeight: .infinity)
                    }.padding(5)
                }.transition(AnyTransition.scale)
            }
            .frame(height: 120)
            .offset(y: progress * 60)
        }
        //.padding(20)
        .shadow(color: Color.hex("#4327F3").opacity(0.6), radius: 16, y: 8)
    }
}

