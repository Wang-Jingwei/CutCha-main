//
//  OkCancelView.swift
//  CutCha
//
//  Created by hansoong choong on 4/10/24.
//

import SwiftUI

struct OkCancelView: View {
    var title: String = ""
    var actions: [(String, () -> Void)]
    var buttonSize : Int = 0
    
    var body: some View {
        ZStack {
            HStack {
                ForEach(actions.indices, id: \.self) { index in
                    Button(action: {
                        actions[index].1()
                    }){
                        IconButton(.systemImage, actions[index].0,
                                   size: buttonSize == 0 ? UILayout.OkXButtonWidth : CGFloat(buttonSize),
                                   colorStyle: Color.appMain)
                    }
                    if index != actions.count - 1 {
                        Spacer()
                    }
                }
            }
            
            Text(title)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.white)
        }
    }
}
