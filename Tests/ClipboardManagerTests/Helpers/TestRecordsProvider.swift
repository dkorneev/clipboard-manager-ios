//
//  TestRecordsProvider.swift
//  ClipboardManagerTests
//
//  Created by Denis Korneev on 09/01/2018.
//

import Foundation
@testable import ClipboardManager

class TestRecordsProvider: RecordsProviderProtocol {
    private var records: Array<TestRecord>
    private var recordsDidChangeBlock: (() -> Void)?
    
    init(withRecords records: Array<TestRecord> = []) {
        self.records = records
    }
    
    // MARK: RecordsProviderProtocol
    
    func getAllRecords() -> Array<RecordModelProtocol> {
        return records
    }
    
    func updateRecord(_ record: RecordModelProtocol,
                      updatedDate: Date,
                      withCompletion completion: CompletionBlock?)
    {
        guard let record = record as? TestRecord else { return }
        if let existingRecord = self.records.first(where: { $0.id == record.id }) {
            existingRecord.updated = Date()
        }
        self.recordsDidChangeBlock?()
        completion?()
    }
    
    func createRecord(withText text: String,
                      withCompletion completion: CompletionBlock?)
    {
        let newRecord = TestRecord()
        newRecord.text = text
        records.append(newRecord)
        self.recordsDidChangeBlock?()
        completion?()
    }
    
    func createRecord(withImageData imageData: Data,
                      withCompletion completion: CompletionBlock?)
    {
        let newRecord = TestRecord()
        newRecord.imageData = imageData
        records.append(newRecord)
        self.recordsDidChangeBlock?()
        completion?()
    }
    
    func deleteRecord(_ record: RecordModelProtocol,
                      withCompletion completion: CompletionBlock?)
    {
        guard let record = record as? TestRecord else { return }
        if let index = self.records.index(where: { $0.id == record.id }) {
            records.remove(at: index)
        }
        self.recordsDidChangeBlock?()
        completion?()
    }
    
    func observeChanges( _ block: @escaping () -> Void) {
        self.recordsDidChangeBlock = block
    }
}
