//
//  FillBackgroundViewModel.swift
//  CutCha
//
//  Created by hansoong choong on 24/9/24.
//

import Foundation
import SwiftUI
import CoreImage

class FillBackgroundViewModel: ObservableObject, FilterModel  {
    
    @Published var panelType : PanelType = .morePanel
    @Published var currentFillItem:FillItem = FillItem.noneFill
    @Published var keepBackground : Bool = true
    @Published var strokeOnly : Bool = false
    @Published var lineWidth : Int = 25

    //store solid color and gradient
    @Published var basicFillFilters : [FillItem] = []
    
    @Published var blendMode : CGBlendMode = .normal
    @Published var materials: [FillItem] = []
    @Published var boundary: CGRect = .zero
    
    var opacity : Double = 1.0
    var photoManager : PhotoManager
    var materialPath : URL = CcMaterial.shared.getMaterialFolder!
    var originalPatternImage : UIImage = UIImage()
    
    @Published var patternImage : UIImage = UIImage() {
        didSet {
            updateDisplayImage()
        }
    }
    
    // pattern offset
    var currentBoundary : CGRect = .zero
    
    init(photoManager : PhotoManager) {
        self.photoManager = photoManager
        self.photoManager.fillVM = self
        if basicFillFilters.isEmpty {
            let gradients = CcGradient.shared.initGradient().map {
                FillItem(CutchaFileHelper.shared.generateID(), fillEffect: .gradient($0))
            }
            constructBasicFill(using: gradients)
        }
        if materials.isEmpty {
            constructMaterials()
        }
    }
    
    func constructMaterials() {
        //let _ = print("construct materials")
        let materials = CcMaterial.shared.initMaterial().map {
            FillItem(CutchaFileHelper.shared.generateID(), fillEffect: .image($0))
        }
        self.materials = materials
    }
    
    func constructBasicFill(using gradients : [FillItem]) {
        self.basicFillFilters =  [
            FillItem("Gradient", iconName: "rainbow",
                     items: []),
            FillItem("Fill", iconName: "rectangle",
                         items:[])
        ]
        self.basicFillFilters[0].items = gradients
        self.basicFillFilters[1].items = ColorConstants.standardColorsFilter
    }
    
    func reset() {
        currentFillItem = .noneFill
        boundary = .zero
        
    }
    
    func updateDisplayImage() {
        self.photoManager.updateDisplayImage(usingModel: self)
    }
    
    func setFill(effect : FillEffect) {
        self.currentFillItem.fillEffect = effect
        
        if case let .image(filename) = effect {
            self.originalPatternImage = CcMaterial.shared.getImage(filename)
            self.patternImage = self.originalPatternImage
        }
        if boundary == .zero {
            boundary = self.photoManager.getFillRect()
            currentBoundary = boundary
        }
        updateDisplayImage()
    }
    
    func setGradient(_ gradients : [FillItem]) {
        if self.basicFillFilters.count > 0 {
            self.basicFillFilters[0].items = gradients
        }
    }
    
    func updateOrCreateGradient(_ fillItem: FillItem) {
        if self.basicFillFilters.count > 0 {
            ///update existing item
            if let index = self.basicFillFilters[0].items.firstIndex(where: { $0.id == fillItem.id }) {
                var newItem = fillItem
                //self.basicFillFilters[0].items[index] = fillItem
                //let _ = print("update success = \(self.basicFillFilters[0].items[index])")
                if case let .gradient(pattern) = fillItem.fillEffect {
                    var p = pattern
                    p.colors = p.colors.map {
                        $0.toOpacity(1.0)
                    }
                    newItem.fillEffect = .gradient(p)
                    self.basicFillFilters[0].items[index] = newItem
                }
                
                let gradients: [GradientPattern] = self.basicFillFilters[0].items.map {
                    if case let .gradient(pattern) = $0.fillEffect {
                        var p = pattern
                        p.colors = p.colors.map {
                            $0.toOpacity(1.0)
                        }
                        return p
                    }
                    return .init()
                }
                let _ = CcGradient.shared.saveGradient(CcGradient(elements:gradients),
                                               fileName: CcGradient.GRADIENT_FILE,
                                               in: CcGradient.GRADIENT_FOLDER)
//                
            } else {
                /// create new item
                
            }
        }
    }
}

enum FillType {
    case colorFill
    case gradientFill
}
