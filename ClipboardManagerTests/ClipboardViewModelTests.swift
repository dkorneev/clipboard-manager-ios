//
//  ClipboardViewModelTests.swift
//  ClipboardManagerTests
//
//  Created by Denis Korneev on 30/12/2017.
//

import XCTest

class ClipboardViewModelTests: XCTestCase {
    private var pbManager = TestPasteboardManager()
    private let expectationTimeout: TimeInterval = 5
    
    override func setUp() {
        super.setUp()
        self.pbManager.clear()
    }
    
    private func createClipboardViewModel(withRecords records: [String]) -> ClipboardViewModel {
        let recordsProvider = TestRecordsProvider(withRecords:
            records.map{ TestRecord(text: $0) }
        )
        return ClipboardViewModel(pasteboardManager: pbManager,
                                recordsProvider: recordsProvider)
    }
    
    private func assertViewModel(_ viewModel: ClipboardViewModel,
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
        let viewModel = self.createClipboardViewModel(withRecords: [])
        assertViewModel(viewModel, hasRecords: [])
    }
    
    func testOneRecord() {
        let recordText = "test record"
        let viewModel = self.createClipboardViewModel(withRecords: [recordText])
        assertViewModel(viewModel, hasRecords: [recordText])
    }
    
    func testMultipleRecords() {
        let records = [
            "first",
            "second",
            "third"
        ]
        let viewModel = self.createClipboardViewModel(withRecords: records)
        assertViewModel(viewModel, hasRecords: records)
    }
    
    func testAddRecord() {
        let expect = expectation(description: "Add record")
        let viewModel = self.createClipboardViewModel(withRecords: [])
        let recordText = "new record"
        self.pbManager.setData(data: recordText)
        viewModel.addNewRecord { [unowned self] in
            self.assertViewModel(viewModel, hasRecords: [recordText])
            expect.fulfill()
        }
        waitForExpectations(timeout: expectationTimeout, handler: nil)
    }
    
    func testAddExistingRecord() {
        let expect = expectation(description: "Add existing record")
        let records = [
            "first",
            "second",
            "third"
        ]
        let viewModel = self.createClipboardViewModel(withRecords: records)
        self.pbManager.setData(data: records[1])
        viewModel.addNewRecord { [unowned self] in
            self.assertViewModel(viewModel, hasRecords: ["second", "first", "third"])
            expect.fulfill()
        }
        waitForExpectations(timeout: expectationTimeout, handler: nil)
    }
    
    func testRemoveRecord() {
        let expect = expectation(description: "Remove record")
        let records = [
            "first",
            "second",
            "third"
        ]
        let viewModel = self.createClipboardViewModel(withRecords: records)
        viewModel.removeRecord(atIndex: 1) { [unowned self] in
            self.assertViewModel(viewModel, hasRecords: ["first", "third"])
            expect.fulfill()
        }
        waitForExpectations(timeout: expectationTimeout, handler: nil)
    }
    
    func testSelectRecord() {
        let expect = expectation(description: "Select record")
        let recordText = "test record"
        let viewModel = self.createClipboardViewModel(withRecords: [recordText])
        viewModel.selectRecord(atIndex: 0) {
            if let pasteboardData = self.pbManager.currentData() as? String {
                XCTAssertEqual(pasteboardData, recordText)
                
            } else {
                XCTFail()
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: expectationTimeout, handler: nil)
    }
}
