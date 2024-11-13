//
//  ShareView.swift
//  CutCha
//
//  Created by hansoong choong on 7/10/24.
//

import SwiftUI

struct UIShareView: UIViewControllerRepresentable {
    let items: [Any]
    var applicationActivities: [UIActivity]? = nil
    var onCustomCompleted: (() -> Void)?

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: applicationActivities)
        
        activityVC.completionWithItemsHandler = { type, _, _, _ in
        
            if type?.rawValue == ViewModel.CustomActivity {
                onCustomCompleted?()
            }
        }
        
        return activityVC
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // Update logic if needed
    }
}
