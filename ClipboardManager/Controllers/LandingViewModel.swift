//
//  LandingViewModel.swift
//  ClipboardManager
//
//  Created by Denis Korneev on 09/04/2017.
//
//

import RealmSwift
import DateToolsSwift

protocol PasteboardManagerProtocol {
    func currentData() -> Any?
    func setData(data: Any)
}

class LandingViewModel: LandingViewModelProtocol {
    private let realm = try! Realm()
    private var notificationToken: NotificationToken? = nil
    private var objects: Results<Record>? = nil
    private let pasteboard: PasteboardManagerProtocol
    
    init(pasteboardManager: PasteboardManagerProtocol) {
        self.pasteboard = pasteboardManager
        self.notificationToken = realm.objects(Record.self)
            .observe { [weak self] changes in
                self?.resetObjects()
                self?.updateBlock?(nil)
        }
        self.resetObjects()
    }
    
    deinit {
        self.notificationToken?.invalidate()
    }
    
    private func resetObjects() {
        self.objects = self.realm.objects(Record.self).sorted(byKeyPath: "updated", ascending: false)
    }
    
    private func addNewRecord(_ newRecord: Any) {
        switch newRecord {
        case is String:
            self.addNewRecord(text: newRecord as! String)
        case is UIImage:
            self.addNewRecord(image: newRecord as! UIImage)
        default:
            return
        }
    }
    
    private func addNewRecord(text newText: String) {
        if let record = objects?.first(where: { $0.text == newText }) {
            try! realm.write {
                record.updated = Date()
            }
            
        } else {
            self.createNewRecord(text: newText)
        }
    }
    
    private func addNewRecord(image: UIImage) {
        if let record = objects?.first(where: { record in
            guard let existingImage = record.image,
                let newImage = UIImagePNGRepresentation(image) else
            {
                return false
            }
            return existingImage == newImage
        }) {
            try! realm.write {
                record.updated = Date()
            }
            
        } else {
            self.createNewRecord(image: image)
        }
    }
    
    private func createNewRecord(text: String? = nil, image: UIImage? = nil) {
        let newRecord = Record()
        if let image = image {
            newRecord.image = UIImagePNGRepresentation(image)
        }
        if let text = text {
            newRecord.text = text
        }
        try! realm.write {
            realm.add(newRecord)
        }
    }
    
    // MARK: - LandingViewModelProtocol
    
    var updateBlock: ((_ rowIndex: Int?) -> Void)?
    
    func numberOfRecords() -> Int {
        return realm.objects(Record.self).count
    }
    
    func recordDataAtIndex(index: Int) -> (data: Any, date: Date)? {
        guard let record = self.objects?[index] else {
            return nil
        }
        
        if let imageData = record.image {
            return (data: UIImage(data: imageData) as Any, date: record.updated)
        
        } else if let text = record.text {
            return (data: text as Any, date: record.updated)
        
        } else {
            return nil
        }
    }
    
    func addNewRecord() {
        if let data = self.pasteboard.currentData() {
            self.addNewRecord(data)
        }
    }
    
    func selectRecord(atIndex index: Int) {
        guard let record = objects?[index] else {
            return
        }
        
        if let imageData = record.image,
            let image = UIImage(data: imageData)
        {
            self.pasteboard.setData(data: image)
            
        } else if let text = record.text {
            self.pasteboard.setData(data: text)
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
