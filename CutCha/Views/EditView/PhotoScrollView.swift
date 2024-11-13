//
//  PhotoScrollView.swift
//  CutCha
//
//  Created by hansoong choong on 4/10/24.
//

import SwiftUI

struct PhotoScrollView: View {
    @EnvironmentObject var photoManager: PhotoManager
    @EnvironmentObject var fillVM: FillBackgroundViewModel
    @Binding var showLastEditImage: Bool
    @Binding var showShareSheet: Bool
    let geometry: GeometryProxy
    
    @State var dragOffset : CGSize = .zero
    @State var currentDragOffset : CGSize = .zero
    @State var elementTransform: (Direction?, CGOffset) = (nil, .zero)
    
    @State var objectAngle = Angle(degrees: 0.0)
    @State var previousObjectAngle = Angle(degrees: 0.0)
    
    var body: some View {
        ZStack {
            AdvancedScrollView {proxy in
                ZStack {
                    Image(uiImage: showLastEditImage ? photoManager.lastEditImage! : photoManager.currentDisplayImage!)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
//                                        .border(Color.checkred.opacity(0.5))
                        .contextMenu(menuItems : {
                            ShareView(
                                showShareSheet: $showShareSheet,
                                showFillBackground: false,
                                shareFullImage: photoManager.maskImage == nil)
                        }, preview: {
                            if photoManager.maskImage == nil {
                                Image(uiImage: photoManager.currentDisplayImage!)
                            } else {
                                Image(uiImage: UIImage(data: photoManager.pngDataWithCrop)!)
                            }
                        })
                        .sheet(isPresented: $showShareSheet) {
                            let image = photoManager.getShareImage(true)!
                            UIShareView(items: [image])
                        }
                }.overlay {
                    if fillVM.boundary != .zero {
                        if case .image(_) = fillVM.currentFillItem.fillEffect {
                            let anchorPt : UnitPoint = .init(x: fillVM.boundary.center.x / photoManager.imageSize.width,
                                                             y: fillVM.boundary.center.y / photoManager.imageSize.height)
                            ZStack {
                                patternImageView
                                    .opacity(0.1)
                                controlBox()
                                    .rotationEffect(objectAngle, anchor: anchorPt)
                            }
                        }
                    }
                }
            }
            
            undoToggleToolbar
                .opacity(canDisplayOption ? 1 : 0)
                .position(
                    x: geometry.size.width/2,
                    y: geometry.size.height - UILayout.MenuOptionBarHeight - UILayout.EditMenuBarHeight - UILayout.EditMaskButtonHightLightHeight/2)
        }
        .gesture(rotationGesture)
        .onAppear {
            if photoManager.maskImage == nil {
                photoManager.masking.maskFillOption = .FULL_IMAGE
            } else {
                photoManager.masking.maskFillOption = .MASK_ONLY
            }
        }
    }
    
    @ViewBuilder
    var patternImageView : some View {
        ZStack {
            Image(uiImage: UIColor(Color.clear).image(photoManager.imageSize))
            let anchorPt : UnitPoint = .init(x: fillVM.boundary.center.x / photoManager.imageSize.width,
                                             y: fillVM.boundary.center.y / photoManager.imageSize.height)
            let maskShape = Image(uiImage: photoManager.getAlphaMask() ?? UIColor(Color.white).image(photoManager.imageSize))
            Image(uiImage: fillVM.originalPatternImage)
                .resizable()
                .frame(width: fillVM.boundary.size.width, height: fillVM.boundary.size.height)
                .position(fillVM.boundary.center)
                .rotationEffect(objectAngle, anchor: anchorPt)
                .highPriorityGesture(dragGesture)
                .mask(maskShape)
        }
    }
    
    var dragGesture : some Gesture {
        DragGesture()
            .onChanged { value in
                self.currentDragOffset = value.translation
                
                fillVM.patternImage = ImageRenderer(content: self.patternImageView).uiImage!
                
                fillVM.boundary = CGRect(x: fillVM.currentBoundary.origin.x + self.currentDragOffset.width,
                                         y: fillVM.currentBoundary.origin.y + self.currentDragOffset.height,
                                         width: fillVM.currentBoundary.size.width,
                                         height: fillVM.currentBoundary.size.height)
            }
            .onEnded {_ in
                self.dragOffset += currentDragOffset
                self.currentDragOffset = .zero

                fillVM.currentBoundary = fillVM.boundary
                fillVM.patternImage = ImageRenderer(content: self.patternImageView).uiImage!
            }
    }
    
    var rotationGesture: some Gesture {
        RotateGesture()
            .onChanged { value in
                objectAngle = previousObjectAngle + value.rotation.normalized()
                fillVM.patternImage = ImageRenderer(content: self.patternImageView).uiImage!
            }
            .onEnded { _ in
                previousObjectAngle = objectAngle
                fillVM.patternImage = ImageRenderer(content: self.patternImageView).uiImage!
            }
    }
    
    func controlBox() -> some View {
        ControlBox(boundary: fillVM.boundary)
            .foregroundStyle(Color.clear)
            .overlay {
                SelectionBorder(boundary: fillVM.boundary)
                    .stroke(
                        style: StrokeStyle(lineWidth: SelectionConfig.lineWidth, dash: [SelectionConfig.dashSize]))
                    .foregroundColor(Color.appMain)
                SelectionControls(boundary: fillVM.boundary)
                    .fill(Color.white)
                SelectionControls(boundary: fillVM.boundary)
                    .stroke(Color.appMain)
                
                let allCases = Direction.allCases
                ForEach(0 ..< allCases.count, id: \.self) { index in
                    Rectangle()
                        .frame(width:50, height: 50)
                        .position(fillVM.boundary.center)
                        .offset(getOffsetFromDirection(boundary: fillVM.boundary,index: index))
                        .opacity(0.01)
                        //.allowsHitTesting(true)
                        .highPriorityGesture(
                            transformGesture(index: index)
                        )
                }
            }
    }
    
    func getOffsetFromDirection(boundary: CGRect, index : Int) -> CGSize {
        let direction = Direction(rawValue: index)!
        let size = boundary.size
        
        switch direction {
            case .top:
            return CGSize(width: 0, height: -size.height / 2)
            case .topLeft:
            return CGSize(width: -size.width / 2, height: -size.height / 2)
            case .left:
            return CGSize(width:  -size.width / 2, height: 0)
            case .bottomLeft:
            return CGSize(width: -size.width / 2, height: size.height / 2)
            case .bottom:
            return CGSize(width: 0, height: size.height / 2)
            case .bottomRight:
            return CGSize(width: size.width / 2, height: size.height / 2)
            case .right:
            return CGSize(width: size.width / 2, height: 0)
            case .topRight:
            return CGSize(width: size.width / 2, height: -size.height / 2)
        }
    }
    
    func getActualTransform(of offset:CGSize, direction: Direction) -> (CGSize, CGSize) {
        switch direction {
            
        case .top:
            return (.init(width: 0, height: offset.height), .init(width: 0, height: -offset.height))
        case .topLeft:
            return (.init(width: offset.width, height: offset.height), .init(width: -offset.width, height: -offset.height))
        case .left:
            return (.init(width: offset.width, height: 0), .init(width: -offset.width, height: 0))
        case .bottomLeft:
            return (.init(width: offset.width, height: 0), .init(width: -offset.width, height: offset.height))
        case .bottom:
            return (.init(width: 0, height: 0), .init(width: 0, height: offset.height))
        case .bottomRight:
            return (.init(width: 0, height: 0), .init(width: offset.width, height: offset.height))
        case .right:
            return (.init(width: 0, height: 0), .init(width: offset.width, height: 0))
        case .topRight:
            return (.init(width: 0, height: offset.height), .init(width: offset.width, height: -offset.height))
        }
    }
    
    func transformGesture(index : Int) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged({ (touch) in
                elementTransform = (.init(rawValue: index), touch.translation)
                let direction = elementTransform.0!
                let min_size = UILayout.Min_Control_Size
                let (s1, s2) = getActualTransform(of: elementTransform.1, direction: direction)
                
                var x = fillVM.currentBoundary.origin.x + s1.width
                var y = fillVM.currentBoundary.origin.y + s1.height
                
                let width = fillVM.currentBoundary.size.width + s2.width
                let height = fillVM.currentBoundary.size.height + s2.height
                
                if width < min_size {
                    if direction == .bottomRight || direction == .right || direction == .topRight {
                        x = fillVM.currentBoundary.origin.x
                    } else if direction == .bottomLeft || direction == .left || direction == .topLeft {
                        x = fillVM.currentBoundary.origin.x + fillVM.currentBoundary.size.width - min_size
                    }
                }
                
                if height < min_size {
                    if direction == .bottomRight || direction == .bottomLeft || direction == .bottom {
                        y = fillVM.currentBoundary.origin.y
                    } else if direction == .topLeft || direction == .topRight || direction == .top {
                        y = fillVM.currentBoundary.origin.y + fillVM.currentBoundary.size.height - min_size
                    }
                }
                
                fillVM.boundary = CGRect(x: x,
                                        y: y,
                                        width: width < min_size ? min_size : width,
                                        height: height < min_size ? min_size : height)
                fillVM.patternImage = ImageRenderer(content: self.patternImageView).uiImage!
                
            })
            .onEnded({ (touch) in
                fillVM.currentBoundary = fillVM.boundary
                elementTransform = (nil, .zero)
                fillVM.patternImage = ImageRenderer(content: self.patternImageView).uiImage!
            })
    }
    
    var canDisplayOption: Bool {
        if photoManager.currentDisplayImage != photoManager.lastEditImage {
            return true
        }
        return false
    }
    
    @ViewBuilder
    var undoToggleToolbar : some View {
        HStack {
            Button {
                photoManager.undoImage()
            } label: {
                    Color.black.opacity(0.01).overlay {
                        MKSymbolShape(systemName: "arrow.uturn.left")
                            .stroke(.black, lineWidth: 2)
                            .fill(.white)
                            .background(.black.opacity(0.01))
                            .frame(width: UILayout.UndoResetToggleButtonImgSize, height: UILayout.UndoResetToggleButtonImgSize)
//                            .border(Color.checkred.opacity(0.5))
                    }
            }
            .frame(width:UILayout.EditMaskButtonHightLightHeight, height: UILayout.EditMaskButtonHightLightHeight)
//            .border(Color.checkblue.opacity(0.5))
            .opacity(photoManager.imageCahceKeys.count > 0 ? 1 : 0)
            .disabled(!photoManager.undoEnabled)
            
            Spacer()
            
            Button {
//                showLastEditImage.toggle()
            } label: {
                Color.black.opacity(0.01).overlay {
                    MKSymbolShape(systemName: showLastEditImage ? "rectangle.lefthalf.filled" : "rectangle.righthalf.filled")
                        .stroke(.black, lineWidth: 2)
                        .fill(.white)
                        .background(.black.opacity(0.01))
                        .frame(width: 20, height: 20)
//                        .border(Color.checkred.opacity(0.5))
                }
            }
            .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
                if (pressing) {
                    showLastEditImage.toggle()
                } else {showLastEditImage.toggle()}
            }) {}
            .frame(width:UILayout.EditMaskButtonHightLightHeight, height: UILayout.EditMaskButtonHightLightHeight)
//            .border(Color.checkblue.opacity(0.5))
        }
    }
}
