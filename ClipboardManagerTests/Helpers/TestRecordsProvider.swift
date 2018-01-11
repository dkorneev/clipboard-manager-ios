//
//  TestRecordsProvider.swift
//  ClipboardManagerTests
//
//  Created by Denis Korneev on 09/01/2018.
//

import Foundation

class TestRecordsProvider: RecordsProviderProtocol {
    private var records: Array<TestRecord>
    private var recordsDidChangeBlock: (() -> Void)?
    
    init(withRecords records: Array<TestRecord> = []) {
        self.records = records
    }
    
    // MARK: RecordsProviderProtocol
    
    func getAllRecords() -> Array<RecordModel> {
        return records
    }
    
    func updateRecord(_ record: RecordModel,
                      updatedDate: Date,
                      withCompletion completion: CompletionBlock?)
    {
        guard let record = record as? TestRecord else { return }
        if let existingRecord = self.records.first(where: { $0.recordId == record.recordId }) {
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
        newRecord.image = imageData
        records.append(newRecord)
        self.recordsDidChangeBlock?()
        completion?()
    }
    
    func deleteRecord(_ record: RecordModel,
                      withCompletion completion: CompletionBlock?)
    {
        guard let record = record as? TestRecord else { return }
        if let index = self.records.index(where: { $0.recordId == record.recordId }) {
            records.remove(at: index)
        }
        self.recordsDidChangeBlock?()
        completion?()
    }
    
    func observeChanges( _ block: @escaping () -> Void) {
        self.recordsDidChangeBlock = block
    }
}
