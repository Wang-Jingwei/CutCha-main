/*
 See LICENSE folder for this sample’s licensing information.
 
 Abstract:
 An observable state object that contains profile details.
 */

import SwiftUI
import PhotosUI
import CoreTransferable
import CutchaCropper
import Vision

//@MainActor
class PhotoManager: ObservableObject {
    
    static let shared = PhotoManager()
    
    
    // MARK: object in categories
    @Published var masking = Masking()
    @Published var inPainting = InPainting()
    @Published var appState = AppState()
    @Published var textManager = TextManager()
    @Published var manualMaskState = ManualMaskState()
    
    @Published var currentDisplayImage:UIImage?
    @Published var maskImage: UIImage?
    @Published var pngDataWithCrop : Data = Data()
    @Published var maskInvert : Bool = false {
        didSet {
            if maskImage != nil {
                maskImage = maskImage?.imageColorInvert()
                lastMaskImage = maskImage
                createNecessaryData()
            }
        }
    }
    @Published var expandValue : Double = 0
    var lastMaskImage : UIImage?
    /// display image and mask
    var imageSize : CGSize = .zero
    var originalImage : UIImage?
    var lastEditImage:UIImage?
    var lastFilteringImage:UIImage?
    var lines = [Line]()
    /* this mask is transparent and white, use in swift ui's view */
    var currentMaskImageBA:UIImage?
    var maskShape: MaskShape = MaskShape(maskPath: nil)
    var maskBoundary : CGRect = .zero
    var resetALL : Bool = true
    /// scale down to reduce effect preview calculation
    var iconCurrentDisplayImage : UIImage = UIImage()
    
    var pointCollection : [CGPoint] = [] {
        didSet {
            if self.pointCollection.count > 0 || self.rectSelection != .zero {
                //let _ = print("pointCollection = \(self.pointCollection)")
                self.getEdgeSAMMask()
            } else {
                self.maskImage = nil
                self.currentMaskImageBA = nil
                self.maskShape = MaskShape(maskPath: nil)
            }
        }
    }
    
    var rectSelection : CGRect = .zero {
        didSet {
            if self.pointCollection.count > 0 || self.rectSelection != .zero {
                self.getEdgeSAMMask()
            } else {
                self.maskImage = nil
                self.currentMaskImageBA = nil
                self.maskShape = MaskShape(maskPath: nil)
            }
        }
    }
    
    func handleEdgeSAMMask(
                           pts : [CGPoint],
                           imageSize : CGSize,
                           containRect : Bool = true) {
        maskImage = EdgeSAMImageSegmenter.shared.getMaskFromData(
                             usingPts: pts,
                             imageSize: imageSize,
                             containRect: containRect)
        if maskInvert {
            maskImage = maskImage?.imageColorInvert()
        }
        
//        try? write(maskImage!.cgImage, to: URL(fileURLWithPath: "/Users/hansoong/Downloads/mask.png"))
//        let noise = maskImage?.noiseReducted
//        try? write(noise!.cgImage, to: URL(fileURLWithPath: "/Users/hansoong/Downloads/mask1.png"))
        
        lastMaskImage = maskImage
        
        if maskImage != nil {
            createNecessaryData()
        } else {
            pngDataWithCrop = Data()
        }
    }
    
    func handleManualMask() {
        maskImage = getCurrentMask(opaque: true)
        lastMaskImage = maskImage
        if maskImage != nil {
            createNecessaryData()
        } else {
            pngDataWithCrop = Data()
        }
        lines = []
    }
    
    func addMaskUsingPt(_ pt: CGPoint) {
        inPainting.canInPaintingRetry = true
        if let oldMask = maskImage {
            let imageSize = oldMask.size
            let renderer = UIGraphicsImageRenderer(size: imageSize)
            let newMaskImage = ImageFilter.shared.redraw(renderer.image { context in
                context.cgContext.setFillColor(UIColor.white.cgColor)
                context.cgContext.addEllipse(in: .init(center: pt, size: .init(width: 100, height: 100)))
                context.cgContext.drawPath(using: .fill)
            })
            let colorBlendFilter = CIFilter.additionCompositing()
            colorBlendFilter.inputImage = CIImage(image: newMaskImage!)
            colorBlendFilter.backgroundImage = CIImage(image: oldMask)
            if let cgImage = colorBlendFilter.outputImage!.convertCIImageToCGImage() {
                maskImage = UIImage(cgImage: cgImage)
            }
            createNecessaryData()
            //try? write(maskImage?.cgImage, to: URL(filePath: "/Users/hansoong/Downloads/circle.png"))
        }
    }
    
    func prepareEdgeSAM() {
        self.prepareEncoder(currentDisplayImage!.pngData()!)
        DispatchQueue.main.async {
            self.resetSegment()
        }
    }
    
    func prepareEncoder(_ data: Data) {
        if let image = UIImage(data: data) {
            let _ = print("original image size = \(image.size)")
            let maxImageSize = max(image.size.width, image.size.height)
            workingLength = max(min(maxImageSize, maxWorkingLength), 1024)
            var newImage : UIImage
            if image.size.width > image.size.height {
                newImage = image.resized(to: .init(width: workingLength, height: workingLength * image.size.height / image.size.width))
            } else {
                newImage = image.resized(to: .init(width: workingLength * image.size.width / image.size.height, height: workingLength))
            }
            if let scaleData = newImage.pngData() {
                
                let imageSize = newImage.size
                Task {
                    EdgeSAMImageSegmenter.shared.setupEncoder(scaleData, imageSize)
                    DispatchQueue.main.async {
                        self.appState.imageState = .success
                        self.currentDisplayImage = UIImage(data: scaleData)!
                        self.resetEdit()
                    }
                }

                self.imageSize = newImage.size
                let _ = print("*self.imageSize = \(self.imageSize)")
            } else {
                DispatchQueue.main.async {
                    self.appState.imageState = .failure(EdgeSAMError.imageScaleFailed)
                }
            }
        } else {
            DispatchQueue.main.async {
                self.appState.imageState = .failure(EdgeSAMError.imageDataCorrupted)
            }
        }
    }
    
    /// combine points and rect
    func getEdgeSAMMask() {
        if appState.imageState == .success {
            if resetALL { return }
            if rectSelection == .zero {
                handleEdgeSAMMask(pts: pointCollection, imageSize: imageSize, containRect: false)
            } else if pointCollection.count == 0 {
                let pt1 = CGPoint.init(x : rectSelection.minX, y: rectSelection.minY)
                let pt2 = CGPoint.init(x : rectSelection.maxX, y: rectSelection.maxY)
                handleEdgeSAMMask(pts: [pt1, pt2], imageSize: imageSize)
            } else if ((pointCollection.count > 0) && (rectSelection != .zero)) {
                let pt1 = CGPoint.init(x : rectSelection.minX, y: rectSelection.minY)
                let pt2 = CGPoint.init(x : rectSelection.maxX, y: rectSelection.maxY)
                var combineCollection = pointCollection
                combineCollection.append(pt1)
                combineCollection.append(pt2)
                handleEdgeSAMMask(pts: combineCollection, imageSize: imageSize)
            }
        }
    }
    
    func getMaskBoundary(cgPath : CGPath) -> CGRect {
        var transform = CGAffineTransform.identity
            .scaledBy(x: imageSize.width, y: imageSize.height)
            .concatenating(CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: imageSize.height))
        
        if let maskPath = cgPath.copy(using: &transform) {
            let maskRect = maskPath.boundingBox
            return maskRect.intersection(.init(origin: .zero,
                                               size: .init(width: imageSize.width - 1, height: imageSize.height - 1)))
        } else {
            return .zero
        }
    }
    
    func getBAMask() -> UIImage? {
        
        if maskImage == nil  {
            return nil
        }
        return maskImage?.colorToAlpha()
    }
    
    func getAlphaMask() -> UIImage? {
        
        if maskImage == nil || (masking.maskFillOption == .FULL_IMAGE) {
            return nil
        }
        
        if masking.maskFillOption == .INVERSE_MASK {
            return maskImage?.imageColorInvert().colorToAlpha()
        }
        return maskImage?.colorToAlpha()
    }
    
    func getBWMask() -> UIImage? {
        
        if maskImage == nil || (masking.maskFillOption == .FULL_IMAGE) {
            return nil
        }
        
        if masking.maskFillOption == .INVERSE_MASK {
            return maskImage?.imageColorInvert()
        }
        return maskImage
    }
    
    func handleExpandMask() {
        if let lastMask = lastMaskImage {
            //let _ = print("lastMaks = \(lastMask.size)")
            if let cgMask = CIImage(cgImage: lastMask.cgImage!)
                .expandBoder(amount: expandValue, toSize: lastMask.size)
                .convertCIImageToCGImage() {
                let maskImage1 = UIImage(cgImage: cgMask)
                //            try? write(lastMaskImage?.cgImage, to: URL(fileURLWithPath: "/Users/hansoong/Downloads/maska.png"))
                //            try? write(maskImage1.cgImage, to: URL(fileURLWithPath: "/Users/hansoong/Downloads/maskb.png"))
                
                let renderer = UIGraphicsImageRenderer(size: lastMask.size)
                let backgroundImage = ImageFilter.shared.redraw(renderer.image { context in
                    let rectangle = CGRect(origin: .zero, size: lastMask.size)
                    context.cgContext.setFillColor(UIColor.black.cgColor)
                    context.cgContext.addRect(rectangle)
                    context.cgContext.drawPath(using: .fill)
                })
                //let _ = print("backgroundImage = \(backgroundImage!.size)")
                //try? write(backgroundImage?.cgImage, to: URL(fileURLWithPath: "/Users/hansoong/Downloads/maskc.png"))
                
                let colorBlendFilter = CIFilter.additionCompositing()
                colorBlendFilter.inputImage = CIImage(image: maskImage1)
                colorBlendFilter.backgroundImage = CIImage(image: backgroundImage!)
                if let cgImage = colorBlendFilter.outputImage!.convertCIImageToCGImage() {
                    maskImage = UIImage(cgImage: cgImage)
                    //try? write(maskImage!.cgImage, to: URL(fileURLWithPath: "/Users/hansoong/Downloads/maskd.png"))
                }
            }
            if maskImage != nil {
                createNecessaryData()
            } else {
                pngDataWithCrop = Data()
            }
        }
    }
    
    func createNecessaryData() {
        if let cgpath = getContourPath(from: maskImage) {
            maskBoundary = getMaskBoundary(cgPath: cgpath)
            if maskBoundary == .zero || maskBoundary.isInfinite || maskBoundary.isNull || maskBoundary.isEmpty {
                maskImage = nil
                maskShape = MaskShape(maskPath: nil)
                pngDataWithCrop = Data()
                currentMaskImageBA = nil
            } else {
                updateImageMask(currentMaskImage: maskImage)
                maskShape = MaskShape(maskPath: Path(cgpath))
                pngDataWithCrop = ImageUtilities.shared.uiImagePngData(of: currentDisplayImage!,
                                                                       fromMask: maskImage!,
                                                                       sigma: Double(masking.gaussianSigma),
                                                                       cropRect: maskBoundary)
            }
        } else {
            maskImage = nil
            maskShape = MaskShape(maskPath: nil)
            pngDataWithCrop = Data()
        }
    }
    
    // MARK: relation with other models
    var fillVM : FillBackgroundViewModel?
    var effectFilter : EffectFilterViewModel?
    var polynomialTransformer : PolynomialTransformer?
    var morphologyTransformer : MorphologyTransformer?
    var histogramSpecifier: HistogramSpecifier?
    var lutViewModel: LUTViewModel?

    // MARK: handle crop
    var isDirty : Bool {
        return (imageCahceKeys.count > 0)
    }
    
    func updateCropState(cropState: CropperState? = nil) {
        let sourceImage : UIImage = currentDisplayImage!
        var sourceMaskImage : UIImage? = getBAMask()
        
        ///todo : take care of crop mask
        if let cropState = cropState {
            let originRender = sourceImage.cropped(withCropperState: cropState)
            if sourceMaskImage != nil {
                
                let currentMaskImage = getCurrentMask(opaque: true)!
                
                var url = self.imageCache.generateRandomURLWithLength(length: 10, suffix: UndoInfo.suffix)
                self.imageCahceKeys.append(url)
                self.imageCache.insertImage(currentDisplayImage!, for: url)
                
                url = self.imageCache.generateRandomURLWithLength(length: 10, suffix: UndoInfo.suffix)
                self.imageCahceKeys.append(url)
                self.imageCache.insertImage(currentMaskImage, for: url)
                
                sourceMaskImage = sourceMaskImage?.cropped(withCropperState: cropState)
                maskImage = currentMaskImage.cropped(withCropperState: cropState)
                currentMaskImageBA = sourceMaskImage
            } else {
                let url = self.imageCache.generateRandomURLWithLength(length: 10)
                self.imageCahceKeys.append(url)
                self.imageCache.insertImage(currentDisplayImage!, for: url)
            }
            currentDisplayImage = originRender
            iconCurrentDisplayImage = currentDisplayImage!.maxLength(to: ViewModel.IconSize)
        }
    }
    
    // MARK: reset
    func resetEdit() {
        lines = []
        self.lastEditImage = self.currentDisplayImage
        self.lastFilteringImage = self.currentDisplayImage
        
        effectFilter?.reset()
        fillVM?.reset()
        
        self.imageCache.removeAllImages()
        self.imageCahceKeys = []
        self.inPainting = InPainting()
    }
    
    func resetCrop() {
        lines = []
        self.lastFilteringImage = self.currentDisplayImage
        effectFilter?.reset()
    }
    
    func resetText() {
        self.textManager.textOptions = [TextOption()]
        self.textManager.currentTextIndex = 0
    }
    
    func resetSegment() {
        /// segmentation
        self.resetALL = true
        self.rectSelection = .zero
        self.pointCollection = []
        self.pngDataWithCrop = Data()
        self.maskBoundary = .zero
        self.maskInvert = false
        self.masking.plusSelection = true
        self.undoEnabled = true
        self.appState.loadingInfo = .empty
        
        self.inPainting = InPainting()
    }
    
    // MARK: setting changed
    var scaleFactor : CGFloat {
        max(1, workingLength / 1024)
    }
    
    var maxWorkingLength : CGFloat = 1536
    var workingLength : CGFloat = 1024

    func setMaxWorkingLength(_ length: CGFloat) {
        if length != maxWorkingLength {
            maxWorkingLength = length
            handleImageSizeChanged()
        }
    }
    
    func handleImageSizeChanged() {
        if let originalImage = self.originalImage {
            if let data = originalImage.pngData() {
                self.appState.imageState = .loading(.init(totalUnitCount: 10))
                DispatchQueue.main.asyncAfter(deadline: .now() + UILayout.DisplayImageDelay) {
                    self.currentDisplayImage = UIImage(data: data)
                    self.prepareEdgeSAM()
                }
            }
        }
    }
    
    // MARK: - sharing
    func getShareImage(_ objectOnly:Bool = false) -> UIImage? {
        
        if objectOnly {
            if maskImage != nil {
                let data = ImageUtilities.shared.uiImagePngData(of: currentDisplayImage!,
                                                                fromMask: maskImage!,
                                                                sigma: Double(masking.gaussianSigma),
                                                                cropRect: maskBoundary)
                if data.count > 0 {
                    return UIImage(data: data)
                }
            }
        }
        if appState.currentMenuType != .text {
            return currentDisplayImage
        } else {
            return textManager.snapshotImage
        }
    }
    
    func shareAction(_ action : ShareAction, objectOnly : Bool = false) {
        var delay = UILayout.LoadingInfoDelay
        if appState.imageState == .success {
            if let shareImage = getShareImage(objectOnly) {
                if action == .SAVE_TO_LIBRARY {
                    PHPhotoLibrary.shared().performChanges {
                        _ = PHAssetChangeRequest.creationRequestForAsset(from: shareImage)
                    } completionHandler: { (success, error) in
                        DispatchQueue.main.async {
                            self.textManager.snapshotImage = nil
                            if success {
                                if objectOnly {
                                    self.appState.loadingInfo = .loading("Selection saved.")
                                } else {
                                    self.appState.loadingInfo = .loading("Image saved.")
                                }
                            } else {
                                delay = delay + 2
                                let str = "App requires your permission to save this image. \n\nYou may change it at Settings->Privacy & Security->Photos"
                                self.appState.loadingInfo = .loading(str)
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                                self.appState.loadingInfo = .empty
                            }
                        }
                    }
                } else {
                    UIPasteboard.general.image = shareImage
                    DispatchQueue.main.async {
                        if objectOnly {
                            self.appState.loadingInfo = .loading("Selection in Pasteboard.")
                        } else {
                            self.appState.loadingInfo = .loading("Image in Pasteboard.")
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                            self.appState.loadingInfo = .empty
                        }
                    }
                }
            } else {
                self.appState.loadingInfo = .loading("Mask generate failed, abort.")
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    self.appState.loadingInfo = .empty
                }
            }
        } else {
            self.appState.loadingInfo = .loading("No Image, aborted.")
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.appState.loadingInfo = .empty
            }
        }
    }
    
    // MARK: - Loading Image & info
    private func loadTransferable(from imageSelection: PhotosPickerItem) -> Progress {
        return imageSelection.loadTransferable(type: TransferImage.self) { result in
            guard imageSelection == self.imageSelection else {
                return
            }
            switch result {
            case .success(let transferImage?):
                self.originalImage = UIImage(data: transferImage.imageData)
                DispatchQueue.main.async {
                    self.appState.imageState = .loading(.discreteProgress(totalUnitCount: 10))
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + UILayout.DisplayImageDelay) { [self] in
                        self.appState.isEditing = true
                        self.currentDisplayImage = UIImage(data: transferImage.imageData)
                        self.iconCurrentDisplayImage = self.currentDisplayImage!.maxLength(to: ViewModel.IconSize)
                        self.prepareEdgeSAM()
                    }
                }
            case .success(nil):
                DispatchQueue.main.async {
                    self.appState.imageState = .empty
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    self.appState.imageState = .failure(error)
                }
            }
        }
    }
    
    @Published var imageSelection: PhotosPickerItem? = nil {
        didSet {
            if let imageSelection {
                self.appState.imageState = .loading(.discreteProgress(totalUnitCount: 10))
                DispatchQueue.main.asyncAfter(deadline: .now() + UILayout.DisplayImageDelay) { [self] in
                    let _ = loadTransferable(from: imageSelection)
                }
                lutViewModel?.resetToDefault()
            }
        }
    }
    
    /// Image cache / undo
    var imageCache = ImageCache.shared
    @Published var imageCahceKeys:[URL] = []
    @Published var undoEnabled : Bool = true
}

enum EdgeSAMError: Error {
    case imageScaleFailed
    case imageDataCorrupted
}

struct TransferImage: Transferable {
    let imageData: Data
    
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(importedContentType: .image) { data in
            guard let _ = UIImage(data: data) else {
                throw EdgeSAMError.imageDataCorrupted
            }
            return TransferImage(imageData: data)
        }
    }
}
