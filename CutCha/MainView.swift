//
//  MainView.swift
//  SegmentAnywhere
//
//  Created by hansoong choong on 6/2/24.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var photoManager:PhotoManager
    @EnvironmentObject var lutViewModel : LUTViewModel
    @EnvironmentObject var fillVM : FillBackgroundViewModel
    @AppStorage("firstRun") var firstRun: Bool = true
    ///merge all state in one, reduce code complexity
    @State var presentLibrary : Bool = false
    @State var opacity : Double = 0
    @State private var isActive = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                LandingPage2(isActive: $isActive, presentLibrary : $presentLibrary)
                
                Image(systemName: "photo.on.rectangle.angled")
                    .photosPicker(isPresented: $presentLibrary,
                                  selection: $photoManager.imageSelection,
                                  matching: .images,
                                  photoLibrary: .shared())
                    .opacity(0)
                    .font(.title3)
                    
            }
            .ignoresSafeArea(.container)
            .navigationDestination(isPresented: $photoManager.appState.isEditing) {
                MainEditView()
                    .frame(minWidth: 100, maxWidth: .infinity, minHeight:100, maxHeight : .infinity)
            }
        }
        .task {
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let lutURL = documentsURL.appendingPathComponent("LUT/Images")
            
            ///to migrate from text lut to image lut
            if !lutURL.isDirectory {
                let oldLutURL = documentsURL.appendingPathComponent("LUT")
                var oldLutFilesURL = [URL]()
                if let enumerator = FileManager.default
                    .enumerator(at: oldLutURL,
                                includingPropertiesForKeys: [.isRegularFileKey],
                                options: [.skipsHiddenFiles, .skipsPackageDescendants, .skipsSubdirectoryDescendants]) {
                    for case let fileURL as URL in enumerator {
                        do {
                            let fileAttributes = try fileURL.resourceValues(forKeys:[.isRegularFileKey])
                            if fileAttributes.isRegularFile! && fileURL.pathExtension.lowercased() == "cube" {
                                oldLutFilesURL.append(fileURL)
                            }
                        } catch { print(error, fileURL) }
                    }
                }
                for url in oldLutFilesURL {
                    try? FileManager.default.removeItem(at: url)
                }
                firstRun = true
            }
            
            if firstRun {
                firstRun = false
                let lutFolderURL = lutViewModel.createFolder(named: "LUT/Images")
                let lutsURL = (Bundle.main.urls(forResourcesWithExtension:nil, subdirectory: nil) ?? [])
                    .filter {
                        $0.pathExtension.lowercased() == "cube"
                    }
                for url in lutsURL {
                    let destPath = lutFolderURL.appendingPathComponent(url.lastPathComponent)
                    do {
                        try FileManager.default.copyItem(at: url, to: destPath)
                    } catch {
                        print("error = \(error)")
                    }
                }
            }
            await lutViewModel.refreshLutList()
            initStorage()
        }
    }
    
    private func initStorage() {
        //let _ = print("initStorage")
//        let gradients = CutchaFile.shared.initGradient().map {
//            FillItem(CutchaFileHelper.shared.generateID(), fillEffect: .gradient($0))
//        }
//        fillVM.setGradient(gradients)
        
        let _ = CutchaFile.shared.initMaterial().map {
            FillItem(CutchaFileHelper.shared.generateID(), fillEffect: .image($0))
        }
        //let _ = print("gradients = \(gradients)")
        //var url = CutchaFile.shared.initCutcha(in: "haha")
//        let _ = print("--> url = \(url)")
//        var canvas : CcCanvas = CcCanvas()
//        guard let data = UIImage(named: "H2")?.jpegData(compressionQuality: 1.0)! else { return }
//        canvas.elements.append(.image(data, options: ["haha": "haha2", "hoho" : "hoho2"]))
//        url = CutchaFile.shared.saveCutcha(canvas, fileName: "cutcha", in: "haha")
//        let _ = print("url = \(url)")
//        let cc = CutchaFile.shared.loadCutcha(fileName: "cutcha", in: "haha")
//        let _ = print("cc = \(cc?.elements.count)")
        
    }
}
