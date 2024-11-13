/*
 See LICENSE folder for this sample’s licensing information.
 
 Abstract:
 The profile image that reflects the selected item state.
 */

import SwiftUI
import PhotosUI

struct UIKitMaskEditImageView: View {
    
    @EnvironmentObject var photoManager: PhotoManager
    @EnvironmentObject var fillVM : FillBackgroundViewModel
    
    let plusSize : CGFloat = 50
    
    /// rectangle drawing info
    @State var isDrawingRectangle : Bool = false
    @State var panRect = CGRect.zero
    
    /// EdgeSam point and rect selection
    @State var tapLocation = CGPoint.zero
    @State var rectSelection = CGRect.zero
    
    @State var pointCollection : [CGPoint] = []
    
    /// animation
    @State var maskAnimationID : Int = 1
    
    /// animation : ant walking
    @State var antPhase : CGFloat = 0
    let antLineWidth : CGFloat = 3
    @State var antCounter : Int = 0
    
    /// animation :  follow path
    let strokeWidth: CGFloat = 2
    let tailLength = 0.35
    @State var strokeStart: CGFloat = 0
    @State var strokeEnd: CGFloat = 0
    @State var strokeStart2: CGFloat = 0
    @State var strokeEnd2: CGFloat = 0
    
    /// in painting related
    @State var dragOffset : CGSize = .zero
    @State var currentDragOffset : CGSize = .zero
    @Binding var maskEditState:ManualMaskState
    @State var objectAngle = Angle(degrees: 0.0)
    @State var previousObjectAngle = Angle(degrees: 0.0)
    
    ///mask edit
    @State var dragPoint: CGPoint = .zero
    @State var currentLine = Line()
    @State var brushLocation: CGPoint = .zero
    
    @State private var showShareSheet: Bool = false
    
    @State var showDragableObject : Bool = true
    
    @State var objectBoundary : CGRect = .zero
    @State var currentObjectBoundary : CGRect = .zero
    @State var elementTransform: (Direction?, CGOffset) = (nil, .zero)

    ///undo
    @Binding var undoArray : [TapType]
    @State var fromUndo : Bool = false
    
    func thumbnailCGImage(brushLocation: CGPoint) -> CGImage {
        canvasUIImage(brushLocation, drawBackground: true)
            .cgImage!
            .cropping(to: .init(center: brushLocation, size: .init(width: 120, height: 120)))!
    }
    
    var body: some View {
        ZStack(alignment:.topLeading) {
            switch photoManager.appState.imageState {
            case .success:
                    advanceScrollView
                        .onAppear {
                            objectBoundary = photoManager.maskBoundary
                            currentObjectBoundary = photoManager.maskBoundary
                        }
                    if brushLocation != .zero { //hansoong-temp
                        Image(uiImage: UIImage(cgImage:thumbnailCGImage(brushLocation: brushLocation)))
                                .border(Color.appMain)
                                .offset(.init(width: 0, height: 40))
                            
                }
            case .loading:
                Rectangle().foregroundStyle(Color.clear).overlay {
                    ProgressView() {
                        Text("Loading...").foregroundStyle(Color.white)
                    }.tint(.white)
                }
            case .empty:
                Rectangle()
                    .fill(PresetGradient.SLAB_SELECT)
                    .opacity(0.5)
            case .failure:
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
            }
        }
        .onChange(of: tapLocation) {
            if tapLocation != .zero {
                photoManager.resetALL = false
                if pointCollection.count < 14 {
                    pointCollection.append(photoManager.masking.plusSelection ? tapLocation : -tapLocation)
                    undoArray.append(.Point)
                    //let _ = print("tapLocation = \(tapLocation)")
                    photoManager.pointCollection.append(
                        photoManager.masking.plusSelection ? tapLocation / photoManager.scaleFactor : -tapLocation / photoManager.scaleFactor)
                } else {
                    //let _ = print("too many point")
                    photoManager.appState.loadingInfo = .loading("You can tap a total of 14 '+' and '-' points.")
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + UILayout.LoadingInfoDelay + 1) {
                        photoManager.appState.loadingInfo = .empty
                    }
                }
                
            }
        }
        .onChange(of: rectSelection) {
            if rectSelection != .zero {
                if !fromUndo {
                    undoArray.append(.Rect(rectSelection))
                }
                fromUndo = false
                photoManager.resetALL = false
                photoManager.rectSelection = rectSelection / photoManager.scaleFactor
            }
        }.onChange(of: photoManager.maskImage) {
            if photoManager.maskImage == nil {
                pointCollection = []
                photoManager.masking.maskToolOption = .SELECT_MASK
                
                objectBoundary = .zero
                currentObjectBoundary = .zero
                fromUndo = false
                antPhase = 0
                maskAnimationID = 0
            } else {
                objectBoundary = photoManager.maskBoundary
                currentObjectBoundary = photoManager.maskBoundary
                antPhase -= antLineWidth * 2
                maskAnimationID += 1
            }
            dragOffset = .zero
            currentDragOffset = .zero
            objectAngle = Angle(degrees: 0.0)
            previousObjectAngle = Angle(degrees: 0.0)
        }
        .onChange(of : photoManager.masking.maskToolOption) {
            dragOffset = .zero
            currentDragOffset = .zero
            objectAngle = Angle(degrees: 0.0)
            previousObjectAngle = Angle(degrees: 0.0)
            objectBoundary = photoManager.maskBoundary
            currentObjectBoundary = photoManager.maskBoundary
        }
        .onChange(of: photoManager.masking.stepBack) {
            if photoManager.masking.stepBack {
                if undoArray.count <= 1 {
                    if case let .Image(data) = undoArray.last {
                        photoManager.prepareEncoder(data)
                        
                    }
                    resetUndo()
                    return
                }
                
                if  case let .Image(data) = undoArray.last {
                    photoManager.prepareEncoder(data)
                    resetUndo()
                    return
                    
                }
                
                if let tapType = undoArray.last {
                    undoArray.removeLast()
                    if tapType.isRectType {
                        let rectArray : [TapType] = undoArray.filter { $0.isRectType }
                        
                        if rectArray.count > 0 {
                            let lastRect = rectArray.last!.getRect()
                            fromUndo = true
                            rectSelection = lastRect
                            
                        } else {
                            rectSelection = .zero
                            photoManager.rectSelection = .zero
                            photoManager.getEdgeSAMMask()
                        }
                    }
                    else if tapType.isPointType {
                        if pointCollection.count > 0 { //cannot reproduce crash here
                            pointCollection.removeLast()
                            photoManager.pointCollection.removeLast()
                        } else {
                            resetUndo()
                        }
                    }
                    photoManager.masking.stepBack = false
                }
            }
        }
    }
    
    func resetUndo() {
        rectSelection = .zero
        pointCollection = []
        undoArray = []
        photoManager.resetSegment()
        photoManager.masking.stepBack = false
    }
    
    @ViewBuilder
    var advanceScrollView : some View {
        ZStack {
            AdvancedScrollView { proxy in
                ZStack {
                    Image(uiImage: photoManager.currentDisplayImage!)
                        //.opacity(photoManager.maskImage != nil ? 0.7 : 1)
                    Image(uiImage: canvasUIImage(brushLocation))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .opacity(maskEditState.manualMaskEdit ?(showDragableObject ? 0 : 1) : 0)
                    if brushLocation != .zero {
                        Image(systemName: maskEditState.paintTool == .brush ? "circle" : "eraser")
                            .font(.system(size: CGFloat(maskEditState.brushSize)))
                            .foregroundColor(maskEditState.paintTool == .brush ? .green : .red)
                            .position(brushLocation)
                    }
                }.overlay {
                    scrollViewOverlay()
                        .opacity(showDragableObject ? 1 : 0)
                }.clipped()
            }
            .onTapContentGesture { location,proxy in
                if photoManager.masking.maskToolOption == .SELECT_MASK && isValid(proxy: proxy, location: location) {
                    if !maskEditState.manualMaskEdit {
                        tapLocation = location
                    }
                } else {
                    if photoManager.inPainting.inPaintingResultImage != nil {
                        photoManager.addMaskUsingPt(location)
                    }
                }
            }.onDragContentGesture { gesturePhase, location, translation, _ in
                if photoManager.masking.maskToolOption == .MOVE_OBJECT { return false }
                if maskEditState.manualMaskEdit {
                        if gesturePhase == ContinuousGesturePhase.began /* || gesturePhase == ContinuousGesturePhase.possible*/ {
                            showDragableObject = false
                            brushLocation = location
                            currentLine.isPlus = (maskEditState.paintTool == .brush ? true : false)
                            currentLine.brushSize = maskEditState.brushSize
                            currentLine.points.append(location)
                        } else if gesturePhase == ContinuousGesturePhase.changed {
                            brushLocation = location
                            currentLine.points.append(location)
                        } else if gesturePhase == ContinuousGesturePhase.ended {
                            showDragableObject = true
                            photoManager.lines.append(currentLine)
                            brushLocation = .zero
                            currentLine = Line()
                            photoManager.handleManualMask()
                        } 
                    return true
                } else {
                    if photoManager.masking.maskToolOption == .SELECT_MASK {
                        if gesturePhase == ContinuousGesturePhase.began || gesturePhase == ContinuousGesturePhase.possible {
                            isDrawingRectangle = true
                            rectSelection = .zero
                            panRect.origin = location
                            panRect.size = translation
                        } else if gesturePhase == ContinuousGesturePhase.changed {
                            panRect.size = translation
                        } else if gesturePhase == ContinuousGesturePhase.ended {
                            if min(panRect.width, panRect.height) < SegmentConfig.MIN_RECT_SIZE {
                                tapLocation = panRect.center
                            } else {
                                rectSelection = panRect
                            }
                            panRect = .zero
                            isDrawingRectangle = false
                        } else {
                            panRect = .zero
                            rectSelection = .zero
                            isDrawingRectangle = false
                        }
                        return true
                    }
                }
                return false
            }
        }.gesture(rotationGesture)
    }
    
    @ViewBuilder
    func scrollViewOverlay() -> some View {
        if photoManager.masking.maskToolOption == .SELECT_MASK {
            draggableMaskImageLayer()
            if !maskEditState.manualMaskEdit {
                segmentIndicatorView
            }
        } else if photoManager.masking.maskToolOption != .EXPAND_MASK {
            inPaintingView()
                
        }
        maskAnimateView
            .id(maskAnimationID)
    }
    
    @ViewBuilder 
    func inPaintingView(isSnapShot: Bool = false) -> some View {
        ZStack {
            magicView
            dragView(isSnapShot)
                .opacity(photoManager.masking.maskToolOption == .REMOVE_OBJECT ? 0 : 1)
        }
    }
    
    @ViewBuilder
    func dragView(_ isSnapShot:Bool) -> some View {
        let pngData = photoManager.pngDataWithCrop
        let uiImage = UIImage(data: pngData)
        let dragImage = Image(uiImage: uiImage ?? UIImage())
        let anchorPt : UnitPoint = .init(x: objectBoundary.center.x / photoManager.imageSize.width,
                                         y: objectBoundary.center.y / photoManager.imageSize.height)
        dragImage
            .resizable()
            .frame(width: objectBoundary.size.width, height: objectBoundary.size.height)
            .position(objectBoundary.center)
            .rotationEffect(objectAngle, anchor: anchorPt)
            .highPriorityGesture(dragGesture)
            //.gesture(dragGesture) //.simultaneously(with: rotationGesture))
            .overlay {
                if !isSnapShot {
                    controlBox()
                        .rotationEffect(objectAngle, anchor: anchorPt)
                }
            }
            
            
    }
    
    func controlBox() -> some View {
        ControlBox(boundary: objectBoundary)
            .foregroundStyle(Color.clear)
            .overlay {
                SelectionBorder(boundary: objectBoundary)
                    .stroke(
                        style: StrokeStyle(lineWidth: SelectionConfig.lineWidth, dash: [SelectionConfig.dashSize]))
                    .foregroundColor(Color.appMain)
                SelectionControls(boundary: objectBoundary)
                    .fill(Color.white)
                SelectionControls(boundary: objectBoundary)
                    .stroke(Color.appMain)
                
                let allCases = Direction.allCases
                ForEach(0 ..< allCases.count, id: \.self) { index in
                    Rectangle()
                        .frame(width:50, height: 50)
                        .position(objectBoundary.center)
                        .offset(getOffsetFromDirection(boundary: objectBoundary,index: index))
                        .opacity(0.01)
                        //.allowsHitTesting(true)
                        .highPriorityGesture(
                            transformGesture(index: index)
                        )
                }
            }
            
    }
    
    @ViewBuilder
    func draggableMaskImageLayer() -> some View {
        if photoManager.pngDataWithCrop.count > 0 {
            let objectImage = UIImage(data: photoManager.pngDataWithCrop)!
            let dragableImage = Image(uiImage: objectImage)
            let length = max(photoManager.maskBoundary.size.width, photoManager.maskBoundary.size.height)
            let maxLength : CGFloat = CoreLaMaCropSize - CGFloat(photoManager.masking.maskExpand)
            Image(uiImage: photoManager.currentDisplayImage!)
                //.mask(photoManager.maskShape)
                .contextMenu(menuItems: {
                    ShareView(
                              showShareSheet: $showShareSheet,
                              showFillBackground: (length < maxLength),
                              shareFullImage: false)

                }) ///no need preview, preview make context menu squeeze to bottom
                .draggable(dragableImage) {
                    dragableImage
                }
                .sheet(isPresented: $showShareSheet, onDismiss: {
                    //print("Dismiss")
                }, content: {
                    UIShareView(items: [objectImage], applicationActivities: [SaveMaterialActivity()]) {
                        fillVM.constructMaterials()
                    }
                })
        }
    }
    
    @ViewBuilder
    var segmentIndicatorView : some View {
        ForEach(0 ..< pointCollection.count, id: \.self) { index in
            ZStack {
                if pointCollection[index].x < 0 || pointCollection[index].y < 0 {
                    minusMarker
//                        .font(.system(size: plusSize))
//                        .foregroundStyle(.red, .white)
                        .position(-pointCollection[index])
//                        .onTapGesture {
//                            if pointCollection.count > index {
//                                pointCollection.remove(at: index)
//                                photoManager.pointCollection.remove(at: index)
//                            }
//                        }
                } else {
                    plusMarker
//                        .font(.system(size: plusSize))
//                        .foregroundStyle(.green, .white)
                        .position(pointCollection[index])
//                        .onTapGesture {
//                            if pointCollection.count > index {
//                                pointCollection.remove(at: index)
//                                photoManager.pointCollection.remove(at: index)
//                            }
//                        }
                }
            }
        }//.opacity(0)
        
        if isDrawingRectangle {
            Rectangle()
                .stroke(Color.white, lineWidth: 6)
                .stroke(Color.black, lineWidth: 3)
                .frame( width: (rectSelection.width + panRect.width),
                        height: (rectSelection.height + panRect.height))
                .position(x : (panRect.center.x + rectSelection.center.x),
                          y : (panRect.center.y + rectSelection.center.y))
        } else {
            Rectangle()
                .stroke(Color.white, lineWidth: 6)
                .stroke(Color.black, lineWidth: 3)
                .frame( width: (photoManager.rectSelection.width * photoManager.scaleFactor + panRect.width),
                        height: (photoManager.rectSelection.height * photoManager.scaleFactor + panRect.height))
                .position(x : (panRect.center.x + photoManager.rectSelection.center.x * photoManager.scaleFactor),
                          y : (panRect.center.y + photoManager.rectSelection.center.y * photoManager.scaleFactor))
        }
    }
    
    @ViewBuilder
    var minusMarker : some View {
        Circle()
            .stroke(.white, lineWidth: 2)
            .fill(.white)
            .fill(Color.red)
            .frame(width: 10, height: 10)
            .opacity(0.7)
    }
    
    @ViewBuilder
    var plusMarker : some View {
        Circle()
            .stroke(.white, lineWidth: 2)
            .fill(Color.green)
            .frame(width: 10, height: 10)
            .opacity(0.7)
    }
    
    @ViewBuilder
    var maskAnimateView : some View {
        if photoManager.maskImage != nil {
            antAnimationView
                .disabled(true)
                .onAppear {
                    antPhase -= antLineWidth * 2
                }
        }
    }
    
    func canvasUIImage(_ location : CGPoint, drawBackground: Bool = false) -> UIImage {
        let canvasSize = photoManager.currentDisplayImage!.size
        let middle = CGPoint(x: canvasSize.width/2, y: canvasSize.height/2)
        UIGraphicsBeginImageContext(canvasSize)
        // Get the current context
        let context = UIGraphicsGetCurrentContext()!
        if drawBackground {
            if  photoManager.currentDisplayImage != nil {
                photoManager.currentDisplayImage!.draw(in: .init(center: middle, size: canvasSize))
            }
        }
        let color = maskEditState.maskColor.opacity(0.7)
        context.setFillColor(UIColor(color).cgColor)
        context.setStrokeColor(UIColor(color).cgColor)
        context.setLineCap(.round)
        context.setLineJoin(.round)
        let maskImage = ImageRenderer(content:maskImage).uiImage!
        
        if photoManager.currentMaskImageBA != nil {
            maskImage.draw(in: .init(center: middle, size: canvasSize))
        }
        
        for line in photoManager.lines {
            context.beginPath()
            context.addLines(between: line.points)
            context.setLineWidth(CGFloat(line.brushSize))
            
            if line.isPlus {
                context.setBlendMode(.normal)
            } else {
                context.setBlendMode(.clear)
            }
            context.strokePath()
        }
        
        context.beginPath()
        context.addLines(between: currentLine.points)
        context.setLineWidth(CGFloat(currentLine.brushSize))
        if currentLine.isPlus {
            context.setBlendMode(.normal)
        } else {
            context.setBlendMode(.clear)
        }
        context.strokePath()
        
        // Save the context as a new UIImage
        let myImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return myImage ?? UIImage()
    }
    
    @ViewBuilder
    var maskImage : some View {
        let size = photoManager.currentDisplayImage!.size
        if photoManager.currentMaskImageBA != nil {
            Rectangle().fill(maskEditState.maskColor).opacity(0.5).mask {
                Image(uiImage: photoManager.currentMaskImageBA!)
            }.frame(width: size.width, height: size.height)
        } else {
            Rectangle().fill(maskEditState.maskColor).opacity(0.5)
                .frame(width: size.width, height: size.height)
        }
    }
    
    var antAnimationView : some View {
        photoManager.maskShape
            .stroke(style: StrokeStyle(lineWidth: antLineWidth, lineCap: .round, lineJoin: .round))
            .foregroundColor(.white.opacity(0.3))
            .shadow(color: photoManager.inPainting.inPaintingResultImage == nil ? Color.black : Color.clear, radius: antLineWidth)
            .overlay {
                photoManager.maskShape
                    .stroke(style: StrokeStyle(lineWidth: antLineWidth, dash: [antLineWidth], dashPhase: antPhase))
                    .foregroundColor(.white)
                    .shadow(color: photoManager.inPainting.inPaintingResultImage == nil ? Color.black : Color.clear, radius:  antLineWidth)
                    .animation(.linear.repeatForever(autoreverses: false), value: antPhase)
            }
    }
    
    /// utilities
    func isValid(proxy : AdvancedScrollViewProxy, location : CGPoint) -> Bool {
        if photoManager.masking.maskToolOption != .SELECT_MASK { return false }
        let contentSize = proxy.contentSize
        let contentOffset = proxy.contentOffset
        let magnification = proxy.magnification
        let rect = CGRect(origin: contentOffset / magnification, size: contentSize / magnification)
        if rect.contains(location) { return true }
        return false
    }
}
