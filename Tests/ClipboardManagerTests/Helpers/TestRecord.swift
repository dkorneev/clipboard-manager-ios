//
//  TestRecord.swift
//  ClipboardManagerTests
//
//  Created by Denis Korneev on 09/01/2018.
//

import Foundation
@testable import ClipboardManager

class TestRecord: RecordModel, CustomStringConvertible {
    private static var counter = 0
    private static var date = Date()
    
    convenience init(
        text: String? = nil,
        imageData: Data? = nil,
        created createdDate: Date = TestRecord.date,
        updated updatedDate: Date = TestRecord.date)
    {
        let recordId = TestRecord.counter
        TestRecord.counter += 1
        if createdDate == TestRecord.date || updatedDate == TestRecord.date {
            TestRecord.date = Date(timeInterval: -5, since: TestRecord.date)
        }
        self.init(id: recordId,
                   text: text,
                   imageData: imageData,
                   created: createdDate,
                   updated: updatedDate)
    }
    
    // MARK: CustomStringConvertible
    
    var description: String {
        get {
            return "text: \(text ?? "nil"), updated: \(updated)"
        }
    }
}
