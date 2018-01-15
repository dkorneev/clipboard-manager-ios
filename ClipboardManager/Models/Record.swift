//
//  Record.swift
//  ClipboardManager
//
//  Created by Denis Korneev on 07/04/2017.
//
//

import RealmSwift

class Record: Object {
    @objc dynamic var id = 0
    @objc dynamic var text: String? = nil
    @objc dynamic var imageData: Data? = nil
    @objc dynamic var created: Date = Date()
    @objc dynamic var updated: Date = Date()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    static func create(inRealm realm: Realm) -> Record {
        let record = Record()
        guard let primaryKey = Record.primaryKey() else {
            return record
        }
        if let lastId: Int = realm.objects(Record.self).max(ofProperty:primaryKey) {
            record.id = lastId + 1
            
        } else {
            record.id = 1
        }
        return record
    }
}
