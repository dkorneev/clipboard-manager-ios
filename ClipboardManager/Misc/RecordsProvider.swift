//
//  RecordsProvider.swift
//  ClipboardManager
//
//  Created by Denis Korneev on 30/12/2017.
//

import Foundation
import RealmSwift

class RecordsProvider: RecordsProviderProtocol {
    private let realm = try! Realm()
    private var notificationToken: NotificationToken? = nil
    private var observeBlock: (() -> Void)?
    private var allRecords: Results<Record>
    
    init() {
        self.allRecords = self.realm.objects(Record.self)
            .sorted(byKeyPath: "updated", ascending: false)
        self.notificationToken = realm.objects(Record.self)
            .observe { [weak self] changes in
                self?.observeBlock?()
        }
    }
    
    deinit {
        self.notificationToken?.invalidate()
    }
    
    // MARK: RecordsProviderProtocol
    
    func getAllRecords() -> Array<RecordModel> {
        return Array(allRecords)
    }
    
    func updateRecord(_ record: RecordModel, updatedDate: Date) {
        guard let record = record as? Record else { return }
        try! realm.write {
            record.updated = updatedDate
        }
    }
    
    func createRecord(withText text: String) {
        let record = Record()
        record.text = text
        try! realm.write {
            realm.add(record)
        }
    }
    
    func createRecord(withImageData imageData: Data) {
        let record = Record()
        record.image = imageData
        try! realm.write {
            realm.add(record)
        }
    }
    
    func deleteRecord(_ record: RecordModel) {
        guard let record = record as? Record else { return }
        try! realm.write {
            realm.delete(record)
        }
    }
    
    func observeChanges(_ block: @escaping () -> Void) {
        self.observeBlock = block
    }
}
