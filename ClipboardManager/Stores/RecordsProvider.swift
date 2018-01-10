//
//  RecordsProvider.swift
//  ClipboardManager
//
//  Created by Denis Korneev on 30/12/2017.
//

import Foundation
import RealmSwift

extension Realm {
    static func sharedRealm() -> Realm {
        let directory: URL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: K_GROUP_ID)!
        let fileURL = directory.appendingPathComponent(K_DB_NAME)
        let realm = try! Realm(fileURL: fileURL)
        print(">>> file url \(realm.configuration.fileURL?.absoluteString ?? "")")
        return realm
    }
}

class RecordsProvider: RecordsProviderProtocol {
    private let writeQueue = DispatchQueue(label: "realm-write-queue")
    private let realm = Realm.sharedRealm()
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
    
    private func performAsyncRealmOperation(_ performBlock: @escaping (_ realm: Realm) -> Void) {
        self.writeQueue.async {
            autoreleasepool {
                let localRealm = Realm.sharedRealm()
                performBlock(localRealm)
            }
        }
    }
    
    // MARK: RecordsProviderProtocol
    
    func getAllRecords() -> Array<RecordModel> {
        return Array(allRecords)
    }
    
    func updateRecord(_ record: RecordModel, updatedDate: Date) {
        guard let record = record as? Record else { return }
        let recordRef = ThreadSafeReference(to: record)
        self.performAsyncRealmOperation { realm in
            guard let record = realm.resolve(recordRef) else {
                return
            }
            try! realm.write {
                record.updated = updatedDate
            }
        }
    }
    
    func createRecord(withText text: String) {
        self.performAsyncRealmOperation { realm in
            let record = Record()
            record.text = text
            try! realm.write {
                realm.add(record)
            }
        }
    }
    
    func createRecord(withImageData imageData: Data) {
        self.performAsyncRealmOperation { realm in
            let record = Record()
            record.image = imageData
            try! realm.write {
                realm.add(record)
            }
        }
    }
    
    func deleteRecord(_ record: RecordModel) {
        guard let record = record as? Record else { return }
        let recordRef = ThreadSafeReference(to: record)
        self.performAsyncRealmOperation { realm in
            guard let record = realm.resolve(recordRef) else {
                return
            }
            try! realm.write {
                realm.delete(record)
            }
        }
    }
    
    func observeChanges(_ block: @escaping () -> Void) {
        self.observeBlock = block
    }
}
