//
//  AppAsset.swift
//  SegmentAnywhere
//
//  Created by hansoong on 20/12/23.
//

import SwiftUI

struct AppAsset {
    
    static let appAssetList = [plus, minus, trash, sr, magicEditor, edgeSAM, invert_active, edit, filter_active, ai_active, settings]
    
    static let openPhotoLibrary = (
        AnyView(
            imageIcon("photo.on.rectangle.angled", .blue)
                .font(.title3)
        ),
        "Open Photo Library"
    )
    
    static let plus = (
        AnyView(
            imageIcon("plus", .green)
        ),
        "Add Segmentation"
    )
    
    static let minus = (
        AnyView(
            imageIcon("minus", .red)
        ),
        "Reduce Segmentation"
    )
    
    static let trash = (
        AnyView(
            imageIcon("trash", .red)
        ),
        "Remove ALL Segmentation"
    )
    
//    static let resetPosition = (
//        AnyView(
//            imageIcon("arrow.clockwise", .red)
//        ),
//        "Restore to Original"
//    )
    
    static let reverse = (
        AnyView(
            imageIcon("arrow.clockwise", .green)
        ),
        "Initial condition"
    )
    
    static let show = (
        AnyView(
            imageIcon("eye", .blue)
        ),
        "Show/Hide Mask Layer"
    )
    
    static let hide = (
        AnyView(
            imageIcon("eye.slash", .red)
        ),
        "Show/Hide Mask Layer"
    )
    
    static let sr = (
        AnyView(
            imageIcon("arrow.up.left.and.arrow.down.right.circle", .yellow)
        ),
        "Apply Super Resolution"
    )
    
    static let openCamera = (
        AnyView(
            imageIcon("camera.fill", .blue)
        ),
        "Open Camera"
    )
    
    static let back = (
        AnyView(
            imageIcon("arrow.left", .blue)
        ),
        "Exit Camera Mode"
    )
    
    static let captureImage = (
        AnyView(
            imageIcon("camera.aperture", .blue)
        ),
        "Capture Image"
    )
    
    static let apple = (
        AnyView(
            imageIcon("apple.logo", .red)
        ),
        "Apple Lift Object Mode"
    )
    
    static let slab = (
        AnyView(
            imageIcon("s.square.fill", .white, .red).bold()
        ),
        "EdgeSAM Mode"
    )
    
    static let edgeSAM = (
        AnyView(
            imageIcon("rectangle.and.hand.point.up.left", .yellow, .blue)
        ),
        "Back to EdgeSAM"
    )
    
    static let edgeSAM_Help = (
        AnyView(
            imageIcon("questionmark.circle", .blue)
        ),
        "EdgeSAM tutorial"
    )
    
    static let magicEditor = (
        AnyView(
            imageIcon("hands.sparkles", .yellow, .blue)
        ),
        "Go to Magic Editor"
    )

    static let checkMark = (
        AnyView(
            imageIcon("checkmark", .green)
        ),
        "OK"
    )
    
    static let xMark = (
        AnyView(
            imageIcon("xmark", .blue)
        ),
        "Cancel"
    )
    
    static let edit = (
        AnyView(
            imageIcon("slider.horizontal.3", .blue, .green)
        ),
        "Edit Mode"
    )
    
    static let applyFilter = (
        AnyView(
            HStack(spacing : 0) {
                //imageIcon("lessthan", .blue).font(.caption)
                Text("Apply")
            }
        ),
        "Apply Filter"
    )
    
    static let share = (
        AnyView(
            imageIcon("square.and.arrow.up", .blue, .green)
        ),
        "Sharing ..."
    )
    
    static let saveToLibrary = (
        AnyView(
            imageIcon("square.and.arrow.down", .blue, .green)
        ),
        "Save to Photos"
    )
    
    static let copyPasteboard = (
        AnyView(
            imageIcon("doc.on.doc", .blue, .green)
        ),
        "Copy to Pasteboard"
    )
    
    static let settings = (
        AnyView(
            imageIcon("gear", .blue)
        ),
        "Settings"
    )
    
    static let filter_active = (
        AnyView(
            imageIcon("camera.filters", .red)
        ),
        "Color Filter"
    )
    
    static let filter_inactive = (
        AnyView(
            imageIcon("camera.filters", .gray)
        ),
        "Color Filter"
    )
    
    static let mask_auto_active = (
        AnyView(
            imageIcon("hand.tap", .green)
        ),
        "Auto Mask Edit"
    )
    
    static let mask_auto_inactive = (
        AnyView(
            imageIcon("hand.tap", .gray)
        ),
        "Auto Mask Edit"
    )
    
    static let mask_manual_active = (
        AnyView(
            imageIcon("paintbrush.pointed", .green)
        ),
        "Manual Mask Edit"
    )
    
    static let mask_manual_inactive = (
        AnyView(
            imageIcon("paintbrush.pointed", .gray)
        ),
        "Manual Mask Edit"
    )
    
    static let mask_active = (
        AnyView(
            imageIcon("app.dashed", .green)
        ),
        "Color Filter"
    )
    
    static let mask_inactive = (
        AnyView(
            imageIcon("app.dashed", .gray)
        ),
        "Color Filter"
    )
    
    static let ai_active = (
        AnyView(
            imageIcon("sparkles", .white)
        ),
        "AI Filter"
    )
    
    static let ai_inactive = (
        AnyView(
            imageIcon("sparkles", .gray)
        ),
        "AI Filter"
    )
    
    static let crop_active = (
        AnyView(
            imageIcon("crop.rotate", .orange)
        ),
        "Crop / Rotate"
    )
    
    static let crop_inactive = (
        AnyView(
            imageIcon("crop.rotate", .gray)
        ),
        "Crop / Rotate"
    )
    
    static let invert_active = (
        AnyView(
            imageIcon("arrow.left.arrow.right.circle", .blue, .green, .title2)
        ),
        "Invert selection"
    )
    
    static let invert_inactive = (
        AnyView(
            imageIcon("arrow.left.arrow.right.circle", .gray, .title2)
        ),
        "Invert selection"
    )
    
    static let paint_brush_active = (
        AnyView(
            imageIcon("paintbrush.pointed", .green, .title2)
        ),
        "Brush"
    )
    
    static let paint_brush_inactive = (
        AnyView(
            imageIcon("paintbrush.pointed", .gray, .title2)
        ),
        "Brush"
    )
    
    static let eraser_active = (
        AnyView(
            imageIcon("eraser", .red, .title2)
        ),
        "eraser"
    )
    
    static let eraser_inactive = (
        AnyView(
            imageIcon("eraser", .gray, .title2)
        ),
        "eraser"
    )
    
    static func imageIcon(_ systemName : String, _ color : Color, _ font : Font = .title3) -> some View {
        Image(systemName: systemName)
            .symbolRenderingMode(.monochrome)
            .foregroundStyle(color)
            .font(font)
    }
    
    static func imageIcon(_ systemName : String, _ color : Color, _ color1 : Color,  _ font : Font = .title3) -> some View {
        Image(systemName: systemName)
            .symbolRenderingMode(.palette)
            .foregroundStyle(color, color1)
            .font(font)
    }
}
