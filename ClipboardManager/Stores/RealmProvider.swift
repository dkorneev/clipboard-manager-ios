//
//  RealmProvider.swift
//  ClipboardManager
//
//  Created by Denis Korneev on 08/02/2018.
//

import Foundation
import RealmSwift

class RealmProvider: RealmProviderProtocol {
    func realmInstance() -> Realm {
        let directory: URL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: K_GROUP_ID)!
        let fileURL = directory.appendingPathComponent(K_DB_NAME)
        let realm = try! Realm(fileURL: fileURL)
        return realm
    }
}
