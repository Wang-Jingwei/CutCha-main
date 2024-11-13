import SwiftUI
import PhotosUI
import CoreImage.CIFilterBuiltins
import Accelerate

struct MainMaskView: View {
    
    /// camera
    //@StateObject private var framManager = FrameManager.shared
    /// photo library, may conbine with mainviewmodel later
    @EnvironmentObject var photoManager : PhotoManager
    @EnvironmentObject var effectFilter: EffectFilterViewModel
    
    @Environment(\.openURL) var openURL
    
    /// show photo selection from photo library
    @State var presentLibrary : Bool = false
    
    ///edit mode
    @State var isEditing : Bool = false
    
    /// show ai panel
    @State var presentAIPanel : Bool = false
    
    @Binding var manualMaskState : ManualMaskState
    
    //animation
    @State var attempts: Int = 0
    
    @State var undoArray : [TapType] = []
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                ZStack {
                    UIKitMaskEditImageView(maskEditState: $manualMaskState, undoArray : $undoArray)
                        .opacity(photoManager.inPainting.inPaintingInfo == .empty ? 1 : 0.7)
                    Circle().foregroundColor(.black).opacity(0.7)
                        .frame(width: 80, height: 80)
                        .overlay {
                            Image(systemName: "sparkles")
                                .font(.largeTitle)
                                .foregroundColor(Color.appMain)
                                .symbolEffect(.pulse, isActive: photoManager.inPainting.inPaintingInfo != .empty)
                        }
                        .opacity(photoManager.inPainting.inPaintingInfo == .empty ? 0 : 1)
                    //                    Text(captureInfo)
                    //                        .infoView(isShow: captureInfo.isEmpty ? false : true)
                    
                    undoResetToolbar
                        .frame(width: geometry.size.width)
                        .position(x: geometry.size.width/2, y: geometry.size.height - UILayout.EditMaskBarHeight - UILayout.EditMenuIconSize/2)
//                        .border(Color.checkgreen.opacity(0.5))
                }
                
                maskToolbar(geometry : geometry)
                    .frame(width : geometry.size.width, height: UILayout.EditMaskBarHeight - 2) //magic number 2
                    .background(Color.black.opacity(0.8))
//                    .border(Color.checkgreen.opacity(0.5))
            }
        }
        .onChange(of: photoManager.inPainting.canApplyInPainting) {
            if photoManager.inPainting.canApplyInPainting {
                withAnimation(.default.repeatCount(2)) {
                    self.attempts += 1
                }
            }
        }.onChange(of: photoManager.expandValue) {
            photoManager.handleExpandMask()
        }
    }
    
    @ViewBuilder
    var undoResetToolbar : some View {
        HStack {
            Button {
                photoManager.masking.stepBack = true
            } label: {
                Color.black.opacity(0.01).overlay {
                    MKSymbolShape(systemName: "arrow.uturn.left")
                        .stroke(.black, lineWidth: 2)
                        .fill(.white)
                        .background(.black.opacity(0.01))
                        .frame(width: 20, height: 20)
//                        .border(Color.checkred.opacity(0.5))
                }
            }
            .frame(width:UILayout.EditMaskButtonHightLightHeight, height: UILayout.EditMaskButtonHightLightHeight)
            .opacity(manualMaskState.manualMaskEdit ? 0 : undoArray.count == 0 ? 0.7 : 1)
            .disabled(undoArray.count == 0)
//            .border(Color.checkblue.opacity(0.5))
            
            Spacer()
            
            Button {
                photoManager.resetSegment()
                undoArray = []
            } label: {
                Color.black.opacity(0.01).overlay {
                    MKSymbolShape(systemName: "arrow.triangle.2.circlepath")
                        .stroke(.black, lineWidth: 2)
                        .fill(.white)
                        .background(.black.opacity(0.01))
                        .frame(width: 24, height: 20)
//                        .border(Color.checkred.opacity(0.5))
                }.frame(width:UILayout.EditMaskButtonHightLightHeight, height: UILayout.EditMaskButtonHightLightHeight)
//                    .border(Color.checkblue.opacity(0.5))
            }
        }
    }
    
    /// toolbar related
    @ViewBuilder
    func maskToolbar(geometry: GeometryProxy) -> some View {
        GeometryReader { geometry in
            HStack(spacing:0) {
                switch photoManager.masking.maskToolOption {
                case .SELECT_MASK:
                    maskModeView.frame(width : (geometry.size.width)*0.45)//, height: UILayout.EditMaskBarHeight)
                    Divider().padding([.top, .bottom], UILayout.CommonGap)
                    maskToolView //.frame(height: UILayout.EditMaskBarHeight)
                case .MOVE_OBJECT:
                    moveObjectControlView.frame(width : (geometry.size.width)*0.45, height: UILayout.EditMaskBarHeight)
                    Divider().padding([.top, .bottom], UILayout.CommonGap)
                    moveObjectInfoView.frame(height: UILayout.EditMaskBarHeight)
//                    infoView(infoText: photoManager.inPainting.canApplyInPainting ?
//                             (photoManager.inPainting.inPaintingInfo == .empty ? "Tap 'Generate' to fill background" : "Generating, please wait...") :
//                                "Drag object to new location")
                    .frame(height: UILayout.EditMaskBarHeight)
                case .REMOVE_OBJECT:
                    removeObjectControlView.frame(width : (geometry.size.width)*0.45, height: UILayout.EditMaskBarHeight)
                    Divider().padding([.top, .bottom], UILayout.CommonGap)
                    removeObjectInfoView.frame(height: UILayout.EditMaskBarHeight)
//                    infoView(infoText: "Removing, please wait...").frame(height: UILayout.EditMaskBarHeight)
                case .EXPAND_MASK:
                    expandMaskView.frame(height: UILayout.EditMaskBarHeight)
                }
            }
        }
    }
    
    @ViewBuilder
    var expandMaskView : some View {
        VStack {
            FilterSlider(value:$photoManager.expandValue,
                         range: (-25, 25),
                         label: "Grow/Shrink",
                         defaultValue: 0,
                         rangeDisplay: (-25, 25),
                         spacing: 4,
                         sliderGap: 1)
            .padding([.leading, .trailing], 10)
            
            HStack {
                Button(action: {
                    photoManager.expandValue = 0
                    photoManager.handleExpandMask()
                    photoManager.masking.maskToolOption = .SELECT_MASK
                }){
                    Image("xmark-regular-small")
                        //.sizeToFitSquare(sideLength: 15) //hansoong-temp
                        .foregroundColor(Color.appMain)
                        .padding([.top, .bottom], UILayout.ColorEditButtonVerticalPadding)
                        .padding([.leading, .trailing], UILayout.ColorEditButtonHorizontalPadding)
                }
                Spacer()
                Button(action: {
                    photoManager.expandValue = 0
                    if let cgpath = photoManager.getContourPath(from: photoManager.maskImage) {
                        let maskBoundary = photoManager.getMaskBoundary(cgPath: cgpath)
                        //let _ = print("2.maskBOund = \(maskBoundary)")
                        if maskBoundary == .zero || maskBoundary.isInfinite || maskBoundary.isNull || maskBoundary.isEmpty {
                            photoManager.maskImage = nil
                            photoManager.createNecessaryData()
                        } else {
                            photoManager.lastMaskImage = photoManager.maskImage
                        }
                    }
                    photoManager.masking.maskToolOption = .SELECT_MASK
                }){
                    Image("checkmark-regular-small")
                        //.sizeToFitSquare(sideLength: 15) //hansoong-temp
                        .foregroundColor(Color.appMain)
                        .padding([.top, .bottom], UILayout.ColorEditButtonVerticalPadding)
                        .padding([.leading, .trailing], UILayout.ColorEditButtonHorizontalPadding)
                }
            }
        }
    }
    
    @ViewBuilder
    var removeObjectInfoView: some View {
        HStack{
            Spacer()
            if photoManager.inPainting.inPaintingBaseImage != nil {
                Text("Tap(s) on NG area to retry or Done")
                    .foregroundStyle( Color.appMain)
                    .font(.caption)
            } else {
                Text("Removing, please wait...")
                    .foregroundStyle(photoManager.inPainting.canApplyInPainting ? Color.appMain : Color.white)
                    .font(.caption)
                    .modifier(Shake(animatableData: CGFloat(attempts)))
                //                .border(Color.checkred.opacity(0.5))
                    .onAppear {
                        withAnimation(.default.repeatCount(1)) {
                            self.attempts += 1
                        }
                    }
            }
            Spacer()
        }
    }
    
    var finishInPaintingButton : some View {
        Button(action:{
            inPaintingFinishHandler()
        }) {
            VStack {
                Image(systemName: "checkmark.circle").foregroundStyle(.white)
                    .frame(width: UILayout.EditMaskButtonHightLightHeight, height:UILayout.EditMaskButtonHightLightHeight)
                    .appButtonStyle(active: photoManager.inPainting.inPaintingBaseImage != nil)
                    .font(.appButtonBigFont)
                    .cornerRadius(5)
                Text("Finish").appTextStyle(active: photoManager.inPainting.inPaintingBaseImage != nil)
            }
        }.disabled(photoManager.inPainting.inPaintingBaseImage == nil)
    }
    
    var retryInPaintingButton : some View {
        Button(action:{
            photoManager.inPainting.inPaintingBaseImage = nil
            photoManager.inPainting.canApplyInPainting = true
            photoManager.inPainting.canInPaintingRetry = false
            photoManager.applyInPainting()
        }) {
            VStack {
                Image(systemName: "repeat.circle").foregroundStyle(.white)
                    .frame(width: UILayout.EditMaskButtonHightLightHeight, height:UILayout.EditMaskButtonHightLightHeight)
                    .appButtonStyle(active: photoManager.inPainting.canInPaintingRetry)
                    .font(.appButtonBigFont)
                    .cornerRadius(5)
//                            .border(Color.checkred.opacity(0.5))
                Text("Retry").appTextStyle(active: photoManager.inPainting.canInPaintingRetry)
//                            .border(Color.checkred.opacity(0.5))
            }
//                    .border(Color.checkblue.opacity(0.5))
        }.disabled(!photoManager.inPainting.canInPaintingRetry)
    }
    
    @ViewBuilder
    var removeObjectControlView: some View {
        VStack{
            HStack(spacing:0) {
                //Spacer()
                if photoManager.inPainting.canInPaintingRetry {
                    retryInPaintingButton
                } else {
                    finishInPaintingButton
                }
                
                Spacer().frame(width: 10)
                
                Button(action:{
                    photoManager.inPainting = InPainting()
                    photoManager.masking.maskToolOption = .SELECT_MASK
                }) {
                    VStack {
                        Image(systemName: "xmark").foregroundStyle(.white)
                            .frame(width: UILayout.EditMaskButtonHightLightHeight, height:UILayout.EditMaskButtonHightLightHeight)
                            .appButtonStyle(active: photoManager.inPainting.inPaintingBaseImage != nil)
                            .font(.appButtonBigFont)
                            .cornerRadius(5)
                        Text("Cancel").appTextStyle(active: photoManager.inPainting.inPaintingBaseImage != nil)
                    }
                }.disabled(photoManager.inPainting.inPaintingBaseImage == nil)
            }
        }
    }
    
    @ViewBuilder
    var moveObjectControlView: some View {
        VStack {
            
            HStack(spacing:0) {
                Spacer()
                if photoManager.inPainting.inPaintingBaseImage != nil {
                    Button(action:{
                        inPaintingFinishHandler()
                    }) {
                        VStack {
                            Image(systemName: "checkmark.circle").foregroundStyle(.white)
                                .frame(width: UILayout.EditMaskButtonHightLightHeight, height:UILayout.EditMaskButtonHightLightHeight)
                                .appButtonStyle(active: true)
                                .font(.appButtonBigFont)
                                .cornerRadius(5)
//                                .border(Color.checkred.opacity(0.5))
                            Text("Finish").appTextStyle(active: true)
                        }
//                        .border(Color.checkblue.opacity(0.5))
                    }.disabled(!photoManager.inPainting.canApplyInPainting)
                    
                    Spacer().frame(width: 10)
                    
                    Button(action:{
                        photoManager.inPainting = InPainting()
                        photoManager.masking.maskToolOption = .SELECT_MASK
                    }) {
                        VStack {
                            Image(systemName: "xmark").foregroundStyle(.white)
                                .frame(width: UILayout.EditMaskButtonHightLightHeight, height:UILayout.EditMaskButtonHightLightHeight)
                                .appButtonStyle(active: true)
                                .font(.appButtonBigFont)
//                                .border(Color.checkred.opacity(0.5))
                                .cornerRadius(5)
                            Text("Cancel").appTextStyle(active: true)
                        }
//                        .border(Color.checkblue.opacity(0.5))
                    }.disabled(!photoManager.inPainting.canApplyInPainting)
                    
                } else {
                    Button(action:{
                        photoManager.applyInPainting()
                    }) {
                        VStack {
                            Image(systemName: "bolt.circle").foregroundStyle(.white)
                                .frame(width: UILayout.EditMaskButtonHightLightHeight, height:UILayout.EditMaskButtonHightLightHeight)
                                .appButtonStyle(active: (photoManager.inPainting.canApplyInPainting && photoManager.inPainting.inPaintingInfo == .empty))
                                .font(.appButtonBigFont)
                                .cornerRadius(5)
                                .modifier(Shake(animatableData: CGFloat(attempts)))
//                                .border(Color.checkred.opacity(0.5))
                            Text("Generate").appTextStyle(active: (photoManager.inPainting.canApplyInPainting && photoManager.inPainting.inPaintingInfo == .empty))
                        }
//                        .border(Color.checkblue.opacity(0.5))
                    }.disabled((!photoManager.inPainting.canApplyInPainting) || (photoManager.inPainting.inPaintingInfo != .empty))
                        .opacity((!photoManager.inPainting.canApplyInPainting) || (photoManager.inPainting.inPaintingInfo != .empty) ? 0.7 : 1)
                    
                    Spacer().frame(width: 10)
                    
                    Button(action:{
                        photoManager.inPainting = InPainting()
                        photoManager.masking.maskToolOption = .SELECT_MASK
                    }) {
                        VStack {
                            Image(systemName: "xmark").foregroundStyle(.white)
                                .frame(width: UILayout.EditMaskButtonHightLightHeight, height:UILayout.EditMaskButtonHightLightHeight)
                                .appButtonStyle(active: photoManager.inPainting.inPaintingInfo == .empty)
                                .font(.appButtonBigFont)
                                .cornerRadius(5)
                                .modifier(Shake(animatableData: CGFloat(attempts)))
//                                .border(Color.checkred.opacity(0.5))
                            Text("Cancel").appTextStyle(active: photoManager.inPainting.inPaintingInfo == .empty)
                        }
//                        .border(Color.checkblue.opacity(0.5))
                    }
                    .disabled(photoManager.inPainting.inPaintingInfo != .empty)
                    .opacity((photoManager.inPainting.inPaintingInfo != .empty) ? 0.7 : 1)
                }
                Spacer()
            }
        }
    }
    
    @ViewBuilder
    var moveObjectInfoView: some View {
        VStack {
            HStack {
                Spacer()
                if photoManager.inPainting.inPaintingBaseImage != nil {
                    Text("Tap 'Finish' to apply changes")
                        .foregroundStyle( Color.appMain)
                        .font(.caption)
//                        .border(Color.checkred.opacity(0.5))
                    
                } else {
                    Text(photoManager.inPainting.canApplyInPainting ?
                         (photoManager.inPainting.inPaintingInfo == .empty ? "Tap 'Generate' to fill background" : "Generating, please wait...") :
                            "Drag object to new location")
//                    .border(Color.checkred.opacity(0.5))
                    .foregroundStyle(photoManager.inPainting.canApplyInPainting ? Color.appMain : Color.white)
                    .font(.caption)
                    .modifier(Shake(animatableData: CGFloat(attempts)))
                    .onAppear {
                        withAnimation(.default.repeatCount(2)) {
                            self.attempts += 1
                        }
                    }
                }
                Spacer()
            }
//            .border(Color.checkblue.opacity(0.5))
        }
    }
    
    @ViewBuilder
    var maskModeView : some View {
        VStack {
            Text("Select Method")
                .appTextStyle()
//                .border(Color.checkred.opacity(0.5))
            Spacer().frame(height: 10)
            HStack(spacing:0) {
                Spacer()
                Button(action:{
                    manualMaskState.manualMaskEdit = false
                }){
                    VStack {
                        Image(systemName: "hand.tap")
//                            .border(Color.checkred.opacity(0.5))
                            .frame(width: UILayout.EditMaskButtonHightLightHeight, height:UILayout.EditMaskButtonHightLightHeight)
                            .appButtonStyle(active: !manualMaskState.manualMaskEdit)
                            .font(.appButtonBigFont)
                            .cornerRadius(5)
                        Text("Smart").appTextStyle(active: !manualMaskState.manualMaskEdit)
                    }
                }
//                .border(Color.checkblue.opacity(0.5))
                Spacer().frame(width: 10)
                Button(action:{
                    manualMaskState.manualMaskEdit = true
                }){
                    VStack {
                        //(maskEditState.manualMaskEdit ? AppAsset.mask_manual_active.0 : AppAsset.mask_manual_inactive.0)
                        Image(systemName: "paintbrush.pointed")
//                            .border(Color.checkred.opacity(0.5))
                            .frame(width: UILayout.EditMaskButtonHightLightHeight, height:UILayout.EditMaskButtonHightLightHeight)
                            .appButtonStyle(active: manualMaskState.manualMaskEdit)
                            .font(.appButtonBigFont)
                            .cornerRadius(5)
                        Text("Manual").appTextStyle(active : manualMaskState.manualMaskEdit)
                    }
                }
//                .border(Color.checkblue.opacity(0.5))
                Spacer()
            }
//            .border(Color.checkgreen.opacity(0.5))
        }
//        .border(Color.checkcyan.opacity(0.5))
    }
    
    @ViewBuilder
    var maskToolView : some View {
        VStack {
            Text("Adjust Selection")
                .appTextStyle()
            
            Spacer().frame(height: 10)
            
            HStack(spacing:0) {
                Spacer()
                VStack {
                    HStack(spacing : 0) {
                        Button(action: {
                            if manualMaskState.manualMaskEdit {
                                manualMaskState.paintTool = .brush
                            } else {
                                photoManager.masking.plusSelection = true
                            }
                        }) {
                            Image(systemName: "plus").foregroundStyle(.white)
//                                .border(Color.checkred.opacity(0.5))
                                .frame(width: UILayout.EditMaskSubButtonHightLightHeight, height:UILayout.EditMaskSubButtonHightLightHeight)
//                                .border(Color.checkblue.opacity(0.5))
                                .padding(5)
                                .appButtonStyle(active: isPlus)
                                .cornerRadius(5)
                        }
                        Button(action: {
                            if manualMaskState.manualMaskEdit {
                                manualMaskState.paintTool = .eraser
                            } else {
                                photoManager.masking.plusSelection = false
                            }
                        }) {
                            Image(systemName: "minus").foregroundStyle(.white)
//                                .border(Color.checkred.opacity(0.5))
                                .frame(width: UILayout.EditMaskSubButtonHightLightHeight, height:UILayout.EditMaskSubButtonHightLightHeight)
//                                .border(Color.checkblue.opacity(0.5))
                                .padding(5)
                                .appButtonStyle(active: !isPlus)
                                .cornerRadius(5)
                            
                        }
                    }
                    .frame(width: UILayout.EditMaskButtonHightLightHeight, height:UILayout.EditMaskButtonHightLightHeight)
//                    .border(Color.checkgreen.opacity(0.5))
                    Text(isPlus ? "Add" :"Remove").appTextStyle()
                }
//                .border(Color.checkcyan.opacity(0.5))
                
                Spacer()
                
                VStack {
                    Button {
                        photoManager.maskInvert.toggle()
                    } label: {
                        VStack {
                            Image(systemName: "arrow.left.arrow.right.circle")
//                                .border(Color.checkred.opacity(0.5))
                                .frame(width: UILayout.EditMaskButtonHightLightHeight, height:UILayout.EditMaskButtonHightLightHeight)
//                                .border(Color.checkblue.opacity(0.5))
                                .appButtonStyle2(active: photoManager.maskInvert)
                                .font(.appButtonNormalFont)
                                .opacity(photoManager.maskImage == nil ? 0.5 : 1)
                            Text("Inverse").appTextStyle(active: photoManager.maskInvert)
                        }
                    }
                    .disabled(photoManager.maskImage == nil ? true : false)
//                    .border(Color.checkgreen.opacity(0.5))
                }
//                .border(Color.checkcyan.opacity(0.5))
                Spacer()
            }
//            .border(Color.checkorange.opacity(0.5))
        }
//        .border(Color.checkred.opacity(0.5))
    }
    
    var isPlus : Bool {
        if manualMaskState.manualMaskEdit && manualMaskState.paintTool == .brush {
            return true
        }
        if !manualMaskState.manualMaskEdit && photoManager.masking.plusSelection {
            return true
        }
        return false
    }
    @ViewBuilder
    func manualMaskTools(geometry: GeometryProxy) -> some View {
        HStack {
            Rectangle()
                .frame(width: 20)
                .opacity(0)
            Button {
                manualMaskState.paintTool = .brush
            } label: {
                manualMaskState.paintTool == .brush ? AppAsset.paint_brush_active.0 : AppAsset.paint_brush_inactive.0
            }
            Button {
                manualMaskState.paintTool = .eraser
            } label: {
                manualMaskState.paintTool == .eraser ? AppAsset.eraser_active.0 : AppAsset.eraser_inactive.0
            }
            Rectangle()
                .frame(width: 20)
                .opacity(0)
            HStack {
                Text("Color").foregroundStyle(Color.gray)
                ColorPicker("", selection: $manualMaskState.maskColor, supportsOpacity: false)
                    .frame(width: 20)
            }
            Rectangle()
                .frame(width: 20)
                .opacity(0)
            Text("Size(px)").foregroundStyle(Color.gray)
            Picker("", selection: $manualMaskState.brushSize) {
                ForEach(1 ... 50, id: \.self) {
                    Text("\($0)")
                }.frame(width: 60)
            }.offset(x:-10)
                .tint(.white)
        }.frame(width: geometry.size.width)
    }
    
    @ViewBuilder
    var MidBottomToolbar : some View {
        HStack(spacing : 40) {
            Button {
                photoManager.masking.plusSelection.toggle()
            } label: {
                photoManager.masking.plusSelection ? AppAsset.plus.0 : AppAsset.minus.0
            }
            Button {
                photoManager.resetSegment()
            } label: {
                AppAsset.trash.0
            }
            invertButton
                .disabled(photoManager.maskImage == nil ? true : false)
                .opacity(photoManager.maskImage == nil ? 0.5 : 1)
        }
    }
    
    var invertButton : some View {
        Button {
            photoManager.maskInvert.toggle()
        } label: {
            photoManager.maskInvert ? AppAsset.invert_active.0 : AppAsset.invert_inactive.0
        }
    }
    
    private func inPaintingFinishHandler() {
        undoArray = []
        undoArray.append(.Image(photoManager.currentDisplayImage!.pngData()!))
        let undoTemp = undoArray
        photoManager.finishInPainting()
        DispatchQueue.main.asyncAfter(deadline: .now() + UILayout.DisplayImageDelay) {
            undoArray = undoTemp
        }
    }
    
    func getShareImage(_ data: Data) -> UIImage? {
        if photoManager.masking.maskToolOption == .SELECT_MASK {
            if photoManager.pngDataWithCrop.count > 0 {
                return UIImage(data: photoManager.pngDataWithCrop)
            } else {
                return UIImage(data: data)!
            }
        } else {
            return nil //photoManager.inPaintingResultImage
        }
    }
}

struct Shake: GeometryEffect {
    var amount: CGFloat = 5
    var shakesPerUnit = 3
    var animatableData: CGFloat
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX:
                                                amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
                                              y: 0))
    }
}

//struct maskpreview : PreviewProvider {
//    static var previews: some View {
//        let photoManager = PhotoManager()
//        @State var state = MaskEditState()
//        
//        MainMaskView(maskEditState: $state)
//            .environmentObject(photoManager)
//    }
//}
