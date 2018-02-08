//
//  RecordsProvider.swift
//  ClipboardManager
//
//  Created by Denis Korneev on 30/12/2017.
//

import Foundation
import RealmSwift

extension RecordModel {
    convenience init(withRealmRecord record: Record) {
        self.init(
            id: record.id,
            text: record.text,
            imageData: record.imageData,
            created: record.created,
            updated: record.updated)
    }
}

protocol RealmProviderProtocol {
    func realmInstance() -> Realm
}

class RecordsProvider: RecordsProviderProtocol {
    private let writeQueue = DispatchQueue(label: "realm-write-queue")
    private let realm: Realm
    private let realmProvider: RealmProviderProtocol
    private var notificationToken: NotificationToken? = nil
    private var observeBlock: (() -> Void)?
    private var allRecords: Results<Record>
    
    init(withRealmProvider realmProvider: RealmProviderProtocol) {
        self.realmProvider = realmProvider
        self.realm = self.realmProvider.realmInstance()
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
        self.writeQueue.async { [weak self] in
            autoreleasepool {
                if let localRealm = self?.realmProvider.realmInstance() {
                    performBlock(localRealm)
                }
            }
        }
    }
    
    private func getRealmRecord(fromRecordModel record: RecordModelProtocol) -> Record? {
        if let recordModel = record as? RecordModel,
            let realmRecord = self.realm.objects(Record.self)
                .first(where: { $0.id == recordModel.id }) {
            return realmRecord
            
        } else {
            return nil
        }
    }
    
    // MARK: RecordsProviderProtocol
    
    func getAllRecords() -> Array<RecordModelProtocol> {
        return allRecords.map { RecordModel(withRealmRecord: $0) }
    }
    
    func updateRecord(_ record: RecordModelProtocol,
                      updatedDate: Date,
                      withCompletion completion: CompletionBlock? = nil)
    {
        guard let realmRecord = self.getRealmRecord(fromRecordModel: record) else {
            completion?()
            return
        }
        let recordRef = ThreadSafeReference(to: realmRecord)
        self.performAsyncRealmOperation { realm in
            guard let record = realm.resolve(recordRef) else {
                return
            }
            try! realm.write {
                record.updated = updatedDate
            }
            DispatchQueue.main.async {
                completion?()
            }
        }
    }
    
    func createRecord(withText text: String,
                      withCompletion completion: CompletionBlock? = nil)
    {
        self.performAsyncRealmOperation { realm in
            let record = Record.create(inRealm: realm)
            record.text = text
            try! realm.write {
                realm.add(record)
            }
            DispatchQueue.main.async {
                completion?()
            }
        }
    }
    
    func createRecord(withImageData imageData: Data,
                      withCompletion completion: CompletionBlock? = nil)
    {
        self.performAsyncRealmOperation { realm in
            let record = Record.create(inRealm: realm)
            record.imageData = imageData
            try! realm.write {
                realm.add(record)
            }
            DispatchQueue.main.async {
                completion?()
            }
        }
    }
    
    func deleteRecord(_ record: RecordModelProtocol,
                      withCompletion completion: CompletionBlock? = nil)
    {
        guard let realmRecord = self.getRealmRecord(fromRecordModel: record) else {
            completion?()
            return
        }
        let recordRef = ThreadSafeReference(to: realmRecord)
        self.performAsyncRealmOperation { realm in
            guard let record = realm.resolve(recordRef) else {
                return
            }
            try! realm.write {
                realm.delete(record)
            }
            DispatchQueue.main.async {
                completion?()
            }
        }
    }
    
    func observeChanges(_ block: @escaping () -> Void) {
        self.observeBlock = block
    }
}
