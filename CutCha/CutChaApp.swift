//
//  SegmentAnywhereApp.swift
//  SegmentAnywhere
//
//  Created by hansoong choong on 26/10/23.
//

import SwiftUI
import CoreImage

@main
struct CutChaApp: App {
    @State var errorString : String = ""
    @State private var showingAlert = false
    var lutViewModel : LUTViewModel = LUTViewModel(photoManager: PhotoManager.shared)
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .preferredColorScheme(.dark)
                .environmentObject(PhotoManager.shared)
                .environmentObject(FillBackgroundViewModel(photoManager: PhotoManager.shared))
                .environmentObject(EffectFilterViewModel(photoManager: PhotoManager.shared))
                .environmentObject(PolynomialTransformer(photoManager: PhotoManager.shared))
                .environmentObject(MorphologyTransformer(photoManager: PhotoManager.shared))
                .environmentObject(HistogramSpecifier(photoManager: PhotoManager.shared))
                .environmentObject(lutViewModel)
                .onOpenURL { url in
                    let lutError = lutViewModel.importFromURL(url)
                    setLutError(lutError)
                }.alert(errorString, isPresented: $showingAlert) {
                    Button("OK", role: .cancel) { }
                }
        }
    }
    
    func setLutError(_ lutError: LUTError) {
        if lutError != .noError {
            errorString = lutError.rawValue
            showingAlert = true
        }
    }
}

public extension URL {
    var fileSize: Int? {
        let value = try? resourceValues(forKeys: [.fileSizeKey])
        return value?.fileSize
    }
    
    var isDirectory: Bool {
       (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
    }
}
