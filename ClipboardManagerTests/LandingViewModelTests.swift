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
    
    override func setUp() {
        super.setUp()
        self.pbManager.clear()
    }
    
    private func createLandingViewModel(withRecords records: [String]) -> LandingViewModel {
        let recordsProvider = TestRecordsProvider(withRecords:
            records.map{ TestRecord(text: $0) }
        )
        return LandingViewModel(pasteboardManager: pbManager,
                                recordsProvider: recordsProvider)
    }
    
    private func assertViewModel(_ viewModel: LandingViewModel,
                                 hasRecords records: [String])
    {
        XCTAssertEqual(viewModel.numberOfRecords(), records.count)
        for (index, record) in records.enumerated() {
            guard let data = viewModel.recordDataAtIndex(index: index)?.data as? String else {
                XCTFail()
                return
            }
            XCTAssertEqual(data, record)
        }
    }
    
    func testNoRecords() {
        let viewModel = self.createLandingViewModel(withRecords: [])
        assertViewModel(viewModel, hasRecords: [])
    }
    
    func testOneRecord() {
        let recordText = "test record"
        let viewModel = self.createLandingViewModel(withRecords: [recordText])
        assertViewModel(viewModel, hasRecords: [recordText])
    }
    
    func testMultipleRecords() {
        let records = [
            "first",
            "second",
            "third"
        ]
        let viewModel = self.createLandingViewModel(withRecords: records)
        assertViewModel(viewModel, hasRecords: records)
    }
    
    func testAddRecord() {
        let viewModel = self.createLandingViewModel(withRecords: [])
        let recordText = "new record"
        self.pbManager.setData(data: recordText)
        viewModel.addNewRecord()
        assertViewModel(viewModel, hasRecords: [recordText])
    }
    
    func testAddExistingRecord() {
        let records = [
            "first",
            "second",
            "third"
        ]
        let viewModel = self.createLandingViewModel(withRecords: records)
        self.pbManager.setData(data: records[1])
        viewModel.addNewRecord()
        self.assertViewModel(viewModel, hasRecords: ["second", "first", "third"])
    }
    
    func testRemoveRecord() {
        let records = [
            "first",
            "second",
            "third"
        ]
        let viewModel = self.createLandingViewModel(withRecords: records)
        viewModel.removeRecord(atIndex: 1)
        assertViewModel(viewModel, hasRecords: ["first", "third"])
    }
    
    func testSelectRecord() {
        let recordText = "test record"
        let viewModel = self.createLandingViewModel(withRecords: [recordText])
        viewModel.selectRecord(atIndex: 0)
        if let pasteboardData = self.pbManager.currentData() as? String {
            XCTAssertEqual(pasteboardData, recordText)
            
        } else {
            XCTFail()
        }
    }
}
