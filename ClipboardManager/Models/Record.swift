//
//  Record.swift
//  ClipboardManager
//
//  Created by Denis Korneev on 07/04/2017.
//
//

import RealmSwift

class Record: Object {
    dynamic var text: String? = nil
    dynamic var image: Data? = nil
    dynamic var created: Date = Date()
    dynamic var updated: Date = Date()
}
