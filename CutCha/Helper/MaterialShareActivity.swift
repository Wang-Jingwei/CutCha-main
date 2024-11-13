//
//  MaterialShareActivity.swift
//  CutCha
//
//  Created by hansoong choong on 14/10/24.
//
import SwiftUI

import UIKit

class SaveMaterialActivity: UIActivity {
    var activityItems: [Any]?
    
    var activityCategory: UIActivity.Category {
        return .action
    }
    
    override var activityType: UIActivity.ActivityType? {
        return UIActivity.ActivityType(ViewModel.CustomActivity)
    }
    
    override var activityTitle: String? {
        return "Save as Fill Material"
    }
    
    override var activityImage: UIImage? {
        return UIImage(systemName: "person.and.background.dotted") // Use an appropriate image
    }

    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        self.activityItems = activityItems
        return true // Adjust based on your logic
    }
    
    override func prepare(withActivityItems activityItems: [Any]) {
        // Prepare your activity
    }

    override func perform() {
        // Define what happens when the activity is selected
        //let _ = print("self.activityItems = \(self.activityItems)")
        if self.activityItems?.first is UIImage {
            let uiImage : UIImage = self.activityItems?.first as! UIImage
            let _ = CcMaterial.shared.saveImage(image: uiImage)
        }
        activityDidFinish(true)
    }
}
