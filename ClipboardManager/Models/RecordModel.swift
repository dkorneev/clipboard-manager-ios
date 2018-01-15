//
//  RecordModel.swift
//  ClipboardManager
//
//  Created by Denis Korneev on 15/01/2018.
//

import Foundation

class RecordModel: RecordModelProtocol {
    var id: Int
    var text: String?
    var imageData: Data?
    var created: Date
    var updated: Date
    
    init(
        id: Int,
        text: String? = nil,
        imageData: Data? = nil,
        created: Date = Date(),
        updated: Date = Date())
    {
        self.id = id
        self.text = text
        self.imageData = imageData
        self.created = created
        self.updated = updated
    }
    
    func hasTheSameData(_ data: Any) -> Bool {
        if let newValue = data as? String,
            let currentValue = self.text
        {
            return newValue == currentValue
            
        } else if let newValue = data as? Data,
            let currentValue = self.imageData
        {
            return newValue == currentValue
            
        } else {
            return false
        }
    }
}
