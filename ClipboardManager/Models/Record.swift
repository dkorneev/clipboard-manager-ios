//
//  Record.swift
//  ClipboardManager
//
//  Created by Denis Korneev on 07/04/2017.
//
//

import RealmSwift

class Record: Object, RecordModel {
    @objc dynamic var text: String? = nil
    @objc dynamic var image: Data? = nil
    @objc dynamic var created: Date = Date()
    @objc dynamic var updated: Date = Date()
}
