//
//  ClipboardViewModelTests.swift
//  ClipboardManagerTests
//
//  Created by Denis Korneev on 30/12/2017.
//

import XCTest
import UIKit

class ClipboardViewModelTests: XCTestCase {
    private var pbManager = TestPasteboardManager()
    private let expectationTimeout: TimeInterval = 5
    
    override func setUp() {
        super.setUp()
        self.pbManager.clear()
    }
    
    private func createClipboardViewModel(withRecords values: [Any]) -> ClipboardViewModel {
        let testRecords: [TestRecord] = values.flatMap { value in
            if let text = value as? String {
                return TestRecord(text: text)
            
            } else if let image = value as? UIImage {
                return TestRecord(imageData: UIImagePNGRepresentation(image))
            
            } else {
                XCTFail()
                return nil
            }
        }
        let recordsProvider = TestRecordsProvider(withRecords:testRecords)
        return ClipboardViewModel(pasteboardManager: pbManager,
                                recordsProvider: recordsProvider)
    }
    
    private func assertViewModel(_ viewModel: ClipboardViewModel,
                                 hasRecords records: [Any])
    {
        XCTAssertEqual(viewModel.numberOfRecords(), records.count)
        for (index, record) in records.enumerated() {
            guard let currentData = viewModel.recordDataAtIndex(index: index)?.data else {
                XCTFail()
                return
            }
            if let text = currentData as? String, let record = record as? String {
                XCTAssertEqual(text, record)
            
            } else if let image = currentData as? UIImage,
                let record = record as? UIImage,
                let imageData = UIImagePNGRepresentation(image),
                let recordData = UIImagePNGRepresentation(record)
            {
                XCTAssertEqual(imageData, recordData)
            
            } else {
                XCTFail()
            }
        }
    }
    
    private func performAddingRecordTest(
        withInitialRecords initialRecords: [Any],
        newRecord: Any,
        finalRecords: [Any])
    {
        let expect = expectation(description: "Add record")
        let viewModel = self.createClipboardViewModel(withRecords:initialRecords)
        self.pbManager.setData(data: newRecord)
        viewModel.addNewRecord { [unowned self] in
            self.assertViewModel(viewModel, hasRecords: finalRecords)
            expect.fulfill()
        }
        waitForExpectations(timeout: expectationTimeout, handler: nil)
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
        let records = ["first", "second", "third"]
        let viewModel = self.createClipboardViewModel(withRecords: records)
        assertViewModel(viewModel, hasRecords: records)
    }
    
    func testAddTextRecord() {
        let newRecord = "new record"
        self.performAddingRecordTest(withInitialRecords: [],
                                     newRecord: newRecord,
                                     finalRecords: [newRecord])
    }
    
    func testAddExistingTextRecord() {
        self.performAddingRecordTest(
            withInitialRecords: ["first", "second", "third"],
            newRecord: "second",
            finalRecords: ["second", "first", "third"])
    }
    
    func testAddImageRecord() {
        let bundle = Bundle(for: type(of: self))
        guard let image = UIImage(
            named: "test-image-1.jpeg",
            in: bundle,
            compatibleWith: nil) else
        {
            XCTFail()
            return
        }
        self.performAddingRecordTest(
            withInitialRecords: [],
            newRecord: image,
            finalRecords: [image])
    }
    
    func testAddExistingImageRecord() {
        let bundle = Bundle(for: type(of: self))
        guard
            let image1 = UIImage(named: "test-image-1.jpeg", in: bundle, compatibleWith: nil),
            let image2 = UIImage(named: "test-image-2.jpeg", in: bundle, compatibleWith: nil)
            else
        {
            XCTFail()
            return
        }
        self.performAddingRecordTest(
            withInitialRecords: ["first", "second", image1, image2],
            newRecord: image2,
            finalRecords: [image2, "first", "second", image1])
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
