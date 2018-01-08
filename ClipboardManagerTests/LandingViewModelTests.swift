//
//  ClipboardManagerTests.swift
//  ClipboardManagerTests
//
//  Created by Denis Korneev on 30/12/2017.
//

import XCTest
import RealmSwift

class LandingViewModelTests: XCTestCase {
    private var pbManager = TestPasteboardManager()
    private var recordsProvider = TestRecordsProvider()
    
    override func setUp() {
        super.setUp()
        self.pbManager = TestPasteboardManager()
        self.recordsProvider = TestRecordsProvider()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testNoRecords() {
        let viewModel = LandingViewModel(pasteboardManager: pbManager,
                                         recordsProvider: recordsProvider)
        XCTAssertEqual(viewModel.numberOfRecords(), 0)
    }
    
    func testOneRecord() {
        self.recordsProvider.createRecord(withText: "test record")
        let viewModel = LandingViewModel(pasteboardManager: pbManager,
                                         recordsProvider: recordsProvider)
        XCTAssertEqual(viewModel.numberOfRecords(), 1)
    }
}

private class TestPasteboardManager: PasteboardManagerProtocol {
    var pasteboardData: Any? = nil
    
    func currentData() -> Any? {
        return pasteboardData
    }
    
    func setData(data: Any) {
        pasteboardData = data
    }
}

private class TestRecord: RecordModel {
    static var counter = 0
    var recordId: Int
    var text: String?
    var image: Data?
    var created: Date = Date()
    var updated: Date = Date()
    
    init() {
        self.recordId = TestRecord.counter
        TestRecord.counter += 1
    }
}

private class TestRecordsProvider: RecordsProviderProtocol {
    private var records: Array<TestRecord> = []
    func getAllRecords() -> Array<RecordModel> {
        return records
    }
    
    func updateRecord(_ record: RecordModel, updatedDate: Date) {
        guard let record = record as? TestRecord else { return }
        if let existingRecord = self.records.first(where: { $0.recordId == record.recordId }) {
            existingRecord.updated = Date()
        }
    }
    
    func createRecord(withText text: String) {
        let newRecord = TestRecord()
        newRecord.text = text
        records.append(newRecord)
    }
    
    func createRecord(withImageData imageData: Data) {
        let newRecord = TestRecord()
        newRecord.image = imageData
        records.append(newRecord)
    }
    
    func deleteRecord(_ record: RecordModel) {
        guard let record = record as? TestRecord else { return }
        if let index = self.records.index(where: { $0.recordId == record.recordId }) {
            records.remove(at: index)
        }
    }
    
    func observeChanges(_ block: @escaping () -> Void) {
    }
}
