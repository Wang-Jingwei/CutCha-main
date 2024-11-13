//
//  ConcreteGradientView.swift
//  CutCha
//
//  Created by hansoong choong on 7/10/24.
//

import SwiftUI

struct ConcreteGradientView: View {
    var pattern : GradientPattern
    var size: CGSize
    var cgPath : CGPath?
    
    var body: some View {
        let gradient = self.pattern.gradiant(size: size)
        if let concrete = gradient as? LinearGradient {
            concrete
        } else if let concrete = gradient as? RadialGradient {
            concrete
        } else if let concrete = gradient as? AngularGradient {
            concrete
        }
    }
    
    init(pattern: GradientPattern, size: CGSize) {
        self.pattern = pattern
        self.size = size
    }
}
