//
//  RecordsFabricator.swift
//  ClipboardManagerTests
//
//  Created by Denis Korneev on 15/01/2018.
//

import Foundation
import RealmSwift
@testable import ClipboardManager

class RecordsFabricator {
    private var date = Date()
    private let realm: Realm
    
    init(withRealm realm: Realm) {
        self.realm = realm
    }
    
    private func createRecord(
        withUpdateBlock updateBlock: ((_ record: Record) -> Void)?) -> Record
    {
        let record = Record.create(inRealm: realm)
        let newDate = Date(timeInterval: -5, since: self.date)
        record.created = newDate
        record.updated = newDate
        self.date = newDate
        updateBlock?(record)
        try! realm.write {
            realm.add(record)
        }
        return record
    }
    
    func createRecord(withText text: String) -> Record {
        return self.createRecord { (record) in
            record.text = text
        }
    }
    
    func createRecord(withImageData imageData: Data) -> Record {
        return self.createRecord { (record) in
            record.imageData = imageData
        }
    }
}
