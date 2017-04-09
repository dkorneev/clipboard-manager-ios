//
//  LandingViewModel.swift
//  ClipboardManager
//
//  Created by Denis Korneev on 09/04/2017.
//
//

import RealmSwift
import DateToolsSwift

class LandingViewModel: LandingViewModelProtocol {
    private let realm = try! Realm()
    private var notificationToken: NotificationToken? = nil
    private var objects: Results<Record>? = nil
    
    init() {
        self.notificationToken = realm.objects(Record.self)
            .addNotificationBlock { [weak self] changes in
                self?.resetObjects()
                self?.updateBlock?(nil)
        }
        self.resetObjects()
    }
    
    deinit {
        self.notificationToken?.stop()
    }
    
    private func resetObjects() {
        self.objects = self.realm.objects(Record.self).sorted(byKeyPath: "updated", ascending: false)
    }
    
    // MARK: - LandingViewModelProtocol
    
    var updateBlock: ((_ rowIndex: Int?) -> Void)?
    
    func numberOfRecords() -> Int {
        return realm.objects(Record.self).count
    }
    
    func recordDataAtIndex(index: Int) -> (data: Any, date: String)? {
        guard let record = self.objects?[index] else {
            return nil
        }
        let timeAgo = record.updated.timeAgo(since: Date(), numericDates: true, numericTimes: false)
        return (data: record.text as Any, date: timeAgo)
    }
    
    func addNewRecord(text newText: String) {
        if let record = objects?.first(where: { $0.text == newText }) {
            try! realm.write {
                record.updated = Date()
            }
            
        } else {
            let newRecord = Record()
            newRecord.text = newText
            try! realm.write {
                realm.add(newRecord)
            }
        }
    }
    
    func updateRecord(atIndex index: Int) {
        guard let record = objects?[index] else {
            return
        }
        try! realm.write {
            record.updated = Date()
        }
    }
    
    func removeRecord(atIndex index: Int) {
        if let record = objects?[index] {
            try! realm.write {
                realm.delete(record)
            }
        }
    }
}
