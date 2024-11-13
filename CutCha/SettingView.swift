//
//  SettingView.swift
//  SegmentAnywhere
//
//  Created by hansoong choong on 10/11/23.
//

import SwiftUI

struct SettingView: View {
    @EnvironmentObject var photoManager : PhotoManager
    @Binding var showSetting : Bool
    
    @State var showDebugView : Bool = false
    @State var debugMode : Bool = false
    @State var imageLength : CGFloat = 1024
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: HStack {
                    Text("Working Image Size")
                    Text(imageLength.format0())
                        .foregroundStyle(.red)
                        .bold()
                }
                ) {
                    SliderView(imageLength: $imageLength)
                        .disabled(photoManager.masking.maskToolOption == .SELECT_MASK ? false : true)
                }
                
                Section(header:
                            Text("Mask Option")
                ) {
                    VStack {
                        HStack {
                            Picker("Mask Feather(Segmentation)", selection: $photoManager.masking.gaussianSigma) {
                                ForEach(0 ... 10, id: \.self) { index in
                                    Text("\(index)")
                                }
                            }
                            Text("px")
                        }
                        HStack {
                            Picker("Mask Expand(For Move/Remove Object)", selection: $photoManager.masking.maskExpand) {
                                ForEach(Array(stride(from: 0, through: 30, by: 5)), id: \.self) { index in
                                    Text("\(index)")
                                }
                            }
                            Text("px")
                        }
                        
                        HStack {
                            Picker("Manual Mask Brush Size", selection: $photoManager.manualMaskState.brushSize) {
                                ForEach(Array(stride(from: 1, through: 100, by: 1)), id: \.self) { index in
                                    Text("\(index)")
                                }
                            }
                            Text("px")
                        }
                        ColorPicker("Brush Color", selection: $photoManager.manualMaskState.maskColor, supportsOpacity: false)
                    }.font(.caption)
                        .transaction { transaction in
                            transaction.animation = nil
                        }
                }
                
                Section(header:
                            HStack {
                    Image(systemName: "questionmark.circle")
                    Text("Info")
                }
                ) {
                    VStack(alignment: .leading) {
                        Text("Objects Selection").bold()
                        Text("")
                        Text("On 'Mask Edit', Draw RECTANGLE or Tap(+/-).")
                        Text("")
                        Text("If RECTANGLE exists, tap outside will have no effect.")
                        Text("")
                        Text("Save/Share Selection").bold()
                        Text("")
                        Text("Long Press on selection until ContextMenu popup")
                        Text("")
                        Text("Use 2 fingers to Zoom & Pan").bold()
                    }.font(.caption)
                }
            }
            //.navigationBarTitleDisplayMode(.inline)
            //.navigationBarTitle("Settings")
            .navigationBarItems(trailing: closeButton)
            .onAppear {
                self.imageLength = max(photoManager.maxWorkingLength, 1024)
            }.onDisappear {
                photoManager.setMaxWorkingLength(self.imageLength)
            }
        }
    }
    
    var closeButton : some View {
        Button("Close") {
            showSetting.toggle()
        }.foregroundColor(Color.appMain)
    }
}

extension CGFloat {
    func format0() -> String {
        return String(format: "%.0f", self)
    }
}
