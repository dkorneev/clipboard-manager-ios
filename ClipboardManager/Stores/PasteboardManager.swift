//
//  PasteboardManager.swift
//  ClipboardManager
//
//  Created by Denis Korneev on 19/04/2017.
//
//

import Foundation
import UIKit

class PasteboardManager: PasteboardManagerProtocol {
    
    func currentData() -> Any? {
        if let image = UIPasteboard.general.image {
            return image
            
        } else if let text = UIPasteboard.general.string {
            return text
        
        } else {
            return nil
        }
    }
    
    func setData(data: Any) {
        if let text = data as? String {
            UIPasteboard.general.string = text
        
        } else if let image = data as? UIImage {
            UIPasteboard.general.image = image
        }
    }
}
