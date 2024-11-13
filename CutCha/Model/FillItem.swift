//
//  FillItem.swift
//  CutCha
//
//  Created by hansoong choong on 24/9/24.
//

import SwiftUI


struct ColorConstants {
    static let standardColorsFilter : [FillItem] = [.black, .blue, .brown, .cyan, .gray, .green, .indigo, .mint, .orange, .pink, .purple, .red, .teal, .white, .yellow].map {
        FillItem(CutchaFileHelper.shared.generateID(), fillEffect: .color($0))
    }
    
    static let gradientColorsFilter : [FillItem] = [
        FillItem(CutchaFileHelper.shared.generateID(), fillEffect: .gradient(
            .init(colors: [.black, .white])
        )),
        FillItem(CutchaFileHelper.shared.generateID(), fillEffect: .gradient(
            .init(colors: [.blue, .red, .yellow],
                  locations: stride(from: 0, through: 2, by: 1).map {
                      return $0/2
                  })
        )),
        FillItem(CutchaFileHelper.shared.generateID(), fillEffect: .gradient(
            .init(colors: [.red, .orange, .yellow, .green, .blue, .cyan, .purple],
                  locations: stride(from: 0, through: 6, by: 1).map {
                      return $0/6
                  })
        )),
        FillItem(CutchaFileHelper.shared.generateID(), fillEffect: .gradient(
            .init(colors: [Color(.purple), Color(.blue), Color(.green), Color(.white)],
                  locations: stride(from: 0, through: 3, by: 1).map {
                      return $0/3
                  })
        )),
        FillItem(CutchaFileHelper.shared.generateID(), fillEffect: .gradient(
            .init(colors: [Color(.gray), Color(.pink), Color(.orange), Color(.red)],
                  locations: stride(from: 0, through: 3, by: 1).map {
                      return $0/3
                  })
        )),
        FillItem(CutchaFileHelper.shared.generateID(), fillEffect: .gradient(
            .init(colors: [Color(.cyan),  Color(.magenta), Color(.yellow), Color(.black)],
                  locations: stride(from: 0, through: 3, by: 1).map {
                      return $0/3
                  })
        ))
    ]
    
    static let basicColorFilter : [FillItem] = [
        FillItem("Gradient", iconName: "rainbow",
                 items: gradientColorsFilter),
        FillItem("Fill", iconName: "rectangle",
                     items: standardColorsFilter)
    ]
}


enum FillEffect {
    case none
    case color(Color)
    case gradient(GradientPattern)
    case image(String)
}

struct FillItem : Hashable, Identifiable {
    var id: String
    
    static func == (lhs: FillItem, rhs: FillItem) -> Bool {
        lhs.name == rhs.name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    var name:String
    var iconName : String
    var fillEffect:FillEffect
    var items : [FillItem] = []


    static var noneFill = FillItem("", fillEffect: FillEffect.none)
    
    init(_ name:String,
         iconName:String = "",
         fillEffect:FillEffect = .none,
         items : [FillItem] = []
    ) {
        self.name = name
        self.iconName = iconName
        self.fillEffect = fillEffect
        self.items = items
        self.id = name
    }
}
