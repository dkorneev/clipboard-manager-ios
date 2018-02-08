//
//  RecordsProviderTests.swift
//  ClipboardManagerTests
//
//  Created by Denis Korneev on 15/01/2018.
//

import XCTest
import RealmSwift
@testable import ClipboardManager

private extension Record {
    func isTextRecord() -> Bool {
        return self.text != nil && self.imageData == nil
    }

    func isImageRecord() -> Bool {
        return self.imageData != nil && self.text == nil
    }
}

private class TestRealmProvider: RealmProviderProtocol {
    func realmInstance() -> Realm {
        return try! Realm()
    }
}

class RecordsProviderTests: XCTestCase {
    private let expectationTimeout: TimeInterval = 5
    private var realm = TestRealmProvider().realmInstance()

    override func setUp() {
        super.setUp()
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
        self.realm = TestRealmProvider().realmInstance()
    }
    
    func testGetAllRecords() {
        let fabricator = RecordsFabricator(withRealm: realm)
        let firstRecord = fabricator.createRecord(withText: "first")
        let secondRecord = fabricator.createRecord(withText: "second")
        let thirdRecord = fabricator.createRecord(withText: "third")
        let recordsProvider = RecordsProvider(withRealmProvider: TestRealmProvider())
        XCTAssertEqual(recordsProvider.getAllRecords().count, 3)
        XCTAssertEqual(recordsProvider.getAllRecords()[0].text, firstRecord.text)
        XCTAssertEqual(recordsProvider.getAllRecords()[1].text, secondRecord.text)
        XCTAssertEqual(recordsProvider.getAllRecords()[2].text, thirdRecord.text)
    }

    func testAddTextRecord() {
        let expect = expectation(description: "Add text record")
        let text = "test record"
        let recordsProvider = RecordsProvider(withRealmProvider: TestRealmProvider())
        recordsProvider.createRecord(withText: text) { [unowned self] in
            self.realm.refresh()
            let records = self.realm.objects(Record.self)
            XCTAssertEqual(records.count, 1)
            XCTAssertTrue(records.first?.isTextRecord() ?? false)
            expect.fulfill()
        }
        waitForExpectations(timeout: expectationTimeout, handler: nil)
    }

    func testAddImageRecord() {
        let bundle = Bundle(for: type(of: self))
        guard
            let image = UIImage(named: "test-image-1.jpeg", in: bundle, compatibleWith: nil),
            let imageData = UIImagePNGRepresentation(image) else
        {
                XCTFail()
                return
        }
        let expect = expectation(description: "Add image record")
        let recordsProvider = RecordsProvider(withRealmProvider: TestRealmProvider())
        recordsProvider.createRecord(withImageData: imageData) {
            self.realm.refresh()
            let records = self.realm.objects(Record.self)
            XCTAssertEqual(records.count, 1)
            XCTAssertTrue(records.first?.isImageRecord() ?? false)
            expect.fulfill()
        }
        waitForExpectations(timeout: expectationTimeout, handler: nil)
    }

    func testUpdateRecord() {
        let fabricator = RecordsFabricator(withRealm: realm)
        let firstRecord = fabricator.createRecord(withText: "first")
        let _ = fabricator.createRecord(withText: "second")
        let recordModel = RecordModel(withRealmRecord: firstRecord)
        let newDate = Date()

        let expect = expectation(description: "Update record")
        let recordsProvider = RecordsProvider(withRealmProvider: TestRealmProvider())
        recordsProvider.updateRecord(recordModel, updatedDate: newDate) {
            self.realm.refresh()
            let records = self.realm.objects(Record.self)
            XCTAssertEqual(records.count, 2)
            if let updatedRecordText = records
                .first(where: { $0.updated == newDate })?.text
            {
                XCTAssertEqual(updatedRecordText, "first")
            } else {
                XCTFail()
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: expectationTimeout, handler: nil)
    }

    func testRemoveRecord() {
        let fabricator = RecordsFabricator(withRealm: realm)
        let record = fabricator.createRecord(withText: "first")
        let recordModel = RecordModel(withRealmRecord: record)

        let expect = expectation(description: "Update record")
        let recordsProvider = RecordsProvider(withRealmProvider: TestRealmProvider())
        recordsProvider.deleteRecord(recordModel) {
            self.realm.refresh()
            let records = self.realm.objects(Record.self)
            XCTAssertEqual(records.count, 0)
            expect.fulfill()
        }
        waitForExpectations(timeout: expectationTimeout, handler: nil)
    }
}

