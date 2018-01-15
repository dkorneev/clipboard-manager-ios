//
//  TestPasteboardManager.swift
//  ClipboardManagerTests
//
//  Created by Denis Korneev on 09/01/2018.
//

import Foundation
@testable import ClipboardManager

class TestPasteboardManager: PasteboardManagerProtocol {
    private var pasteboardData: Any? = nil
    
    func clear() {
        self.pasteboardData = nil
    }
    
    // MARK: PasteboardManagerProtocol
    
    func currentData() -> Any? {
        return pasteboardData
    }
    
    func setData(data: Any) {
        pasteboardData = data
    }
}
