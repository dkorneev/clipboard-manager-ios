//
//  TestRecord.swift
//  ClipboardManagerTests
//
//  Created by Denis Korneev on 09/01/2018.
//

import Foundation

class TestRecord: RecordModel, CustomStringConvertible {
    private static var counter = 0
    private static var date = Date()
    
    var recordId: Int
    var text: String?
    var image: Data?
    var created: Date = Date()
    var updated: Date = Date()
    
    init(
        text: String? = nil,
        imageData: Data? = nil,
        createdDate: Date = TestRecord.date,
        updatedDate: Date = TestRecord.date)
    {
        self.recordId = TestRecord.counter
        TestRecord.counter += 1
        if createdDate == TestRecord.date || updatedDate == TestRecord.date {
            TestRecord.date = Date(timeInterval: -5, since: TestRecord.date)
        }
        self.text = text
        self.image = imageData
        self.created = createdDate
        self.updated = updatedDate
    }
    
    // MARK: CustomStringConvertible
    
    var description: String {
        get {
            return "text: \(text ?? "nil"), updated: \(updated)"
        }
    }
}
