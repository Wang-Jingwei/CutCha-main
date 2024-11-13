//
//  HistogramView.swift
//  SegmentAnywhere
//
//  Created by hansoong choong on 11/6/24.
//

import SwiftUI
import PhotosUI

struct HistogramTransferView: View {
    
    @EnvironmentObject var histogramSpecifier: HistogramSpecifier
    @State var isOpen = false
    @State private var pickerItem: PhotosPickerItem?
    @State private var transferImage: TransferImage?
    @State var selectedIndex: Int = 0
    
    var body: some View {
        HStack {
            Image(systemName: "plus.circle")
                .frame(width: 40)
                .onTapGesture {
                    isOpen.toggle()
                }.photosPicker(isPresented: $isOpen, selection: $pickerItem, matching: .images)
            ScrollView(.horizontal) {
                HStack {
                    ForEach(0 ..< histogramSpecifier.histogramSamples.count, id:\.self) { index in
                        ZStack {
                            Image(uiImage: histogramSpecifier.histogramSamples[index])
                                .resizable()
                        }
                        .border(index == selectedIndex ? Color.appMain : .clear, width : 3)
                        .frame(width:100, height: 100)
                        .onTapGesture {
                            selectedIndex = index
                            histogramSpecifier
                                .proceed(histogramSourceImage: histogramSpecifier.histogramSamples[index].cgImage!,
                                         imageSourceImage: histogramSpecifier.photoManager.lastFilteringImage!.cgImage!)
                        }
                    }
                }
            }
        }.onChange(of: pickerItem) {
            Task {
                transferImage = try await pickerItem?.loadTransferable(type: TransferImage.self)
                DispatchQueue.main.async {
                    if transferImage != nil {
                        let uiImage = UIImage(data: transferImage!.imageData)?.maxLength(to: 200)
                        histogramSpecifier.histogramSamples.insert(uiImage!, at: 0)
                        selectedIndex = 0
                        histogramSpecifier
                            .proceed(histogramSourceImage: histogramSpecifier.histogramSamples.first!.cgImage!,
                                     imageSourceImage: histogramSpecifier.photoManager.lastFilteringImage!.cgImage!)
                    }
                }
            }
        }.onAppear {
            histogramSpecifier
                .proceed(histogramSourceImage: histogramSpecifier.histogramSamples.first!.cgImage!,
                         imageSourceImage: histogramSpecifier.photoManager.lastFilteringImage!.cgImage!)
        }
    }
}
