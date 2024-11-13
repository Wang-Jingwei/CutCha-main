//
//  FileHelper.swift
//  CutCha
//
//  Created by hansoong choong on 23/9/24.
//

import Foundation

struct CutchaFileHelper {
    static let shared = CutchaFileHelper()
    
    func generateID() -> String {
        return String(UUID().uuidString.prefix(13))
    }
}
