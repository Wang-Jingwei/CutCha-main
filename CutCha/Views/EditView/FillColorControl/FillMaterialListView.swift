//
//  FillMaterialView.swift
//  CutCha
//
//  Created by hansoong choong on 11/10/24.
//

import SwiftUI
import PhotosUI

struct FillMaterialListView: View {
    @EnvironmentObject var fillVM: FillBackgroundViewModel
    @EnvironmentObject var histogramSpecifier : HistogramSpecifier
    @State var isOpen = false
    @State private var pickerItem: PhotosPickerItem?
    @State private var transferImage: TransferImage?
    
    var rows: [GridItem] = [
            GridItem(.adaptive(minimum: 30)) // Minimum item width of 50
        ]
    
    var body: some View {
        GeometryReader { geo in
            HStack {
                Image(systemName: "plus.circle")
                    .frame(width: 40)
                    .onTapGesture {
                        isOpen.toggle()
                    }.photosPicker(isPresented: $isOpen, selection: $pickerItem, matching: .images)
                ScrollView(.horizontal) {
                    LazyHGrid(rows: self.rows) {
                        ForEach(0 ..< fillVM.materials.count, id:\.self) { index in
                            if case let .image(str) = fillVM.materials[index].fillEffect {
                                ZStack {
                                    let filepath = fillVM.materialPath.appendingPathComponent(str).path
                                    Image(uiImage: UIImage(contentsOfFile: filepath) ?? UIImage())
                                        .resizable()
                                        .aspectRatio(1.0, contentMode: .fit)
                                        .frame(maxHeight: geo.size.height / 2 - 3)
                                    
                                }
                                .onTapGesture {
                                    fillVM.currentFillItem = fillVM.materials[index]
                                }
                            }
                        }
                    }
                }
            }
        }.onChange(of: pickerItem) {
            Task {
                transferImage = try await pickerItem?.loadTransferable(type: TransferImage.self)
                DispatchQueue.main.async {
                    if transferImage != nil {
                        if let uiImage = UIImage(data: transferImage!.imageData)?.maxLength(to: 800) {
                            let _ = CcMaterial.shared.saveImage(image: uiImage)
                            fillVM.constructMaterials()
                        }
                    }
                }
            }
        }
    }
}
