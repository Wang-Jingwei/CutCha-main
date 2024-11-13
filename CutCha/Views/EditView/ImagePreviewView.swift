//
//  ImagePreviewView.swift
//  colorful-room
//
//  Created by macOS on 7/8/20.
//  Copyright © 2020 PingAK9. All rights reserved.
//

import SwiftUI

struct ImagePreviewView: View {
    var image:UIImage
    
    @State var  contentMode:ContentMode = .fit
    
    var body: some View {
        Image(uiImage: self.image)
            .resizable()
            .aspectRatio(contentMode: self.contentMode)
            //.frame(width: geo.size.width, height: geo.size.height, alignment: .center)
            .onTapGesture(count: 2) {
                withAnimation{
                    self.contentMode = self.contentMode == .fit ? .fill : .fit
                }
            }
    }
}
