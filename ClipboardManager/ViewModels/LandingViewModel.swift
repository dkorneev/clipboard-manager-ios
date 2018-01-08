//
//  LandingViewModel.swift
//  ClipboardManager
//
//  Created by Denis Korneev on 09/04/2017.
//
//

import DateToolsSwift

protocol PasteboardManagerProtocol {
    func currentData() -> Any?
    func setData(data: Any)
}

protocol RecordModel {
    var text: String? { get set }
    var image: Data? { get set }
    var created: Date { get set }
    var updated: Date { get set }
}

protocol RecordsProviderProtocol {
    func getAllRecords() -> Array<RecordModel>
    func updateRecord(_ record: RecordModel, updatedDate: Date)
    func createRecord(withText: String)
    func createRecord(withImageData: Data)
    func deleteRecord(_ record: RecordModel)
    func observeChanges(_ block: @escaping () -> Void)
}

class LandingViewModel: LandingViewModelProtocol {
    private var objects: Array<RecordModel> = []
    private let pasteboard: PasteboardManagerProtocol
    private let recordsProvider: RecordsProviderProtocol
    
    init(pasteboardManager: PasteboardManagerProtocol,
         recordsProvider: RecordsProviderProtocol)
    {
        self.pasteboard = pasteboardManager
        self.recordsProvider = recordsProvider
        self.recordsProvider.observeChanges { [weak self] in
            self?.resetObjects()
            self?.updateBlock?(nil)
        }
        self.resetObjects()
    }
    
    private func resetObjects() {
        self.objects = self.recordsProvider.getAllRecords()
    }
    
    private func addNewRecord(_ newRecord: Any) {
        if let newRecord = newRecord as? String {
            self.addNewRecord(text: newRecord)
            
        } else if let newRecord = newRecord as? UIImage {
            self.addNewRecord(image: newRecord)
        }
    }
    
    private func addNewRecord(text newText: String) {
        if let record = objects.first(where: { $0.text == newText }) {
            self.recordsProvider.updateRecord(record, updatedDate: Date())

        } else {
            self.recordsProvider.createRecord(withText: newText)
        }
    }
    
    private func addNewRecord(image: UIImage) {
        let existingRecord = objects.first(where: { record in
            guard let existingImage = record.image,
                let newImage = UIImagePNGRepresentation(image) else
            {
                return false
            }
            return existingImage == newImage
        })
        if let existingRecord = existingRecord {
            self.recordsProvider.updateRecord(existingRecord, updatedDate: Date())
        
        } else if let imageData = UIImagePNGRepresentation(image) {
            self.recordsProvider.createRecord(withImageData: imageData)
        }
    }
    
    // MARK: - LandingViewModelProtocol
    
    var updateBlock: ((_ rowIndex: Int?) -> Void)?
    
    func numberOfRecords() -> Int {
        return self.objects.count
    }
    
    func recordDataAtIndex(index: Int) -> (data: Any, date: Date)? {
        guard index < self.objects.count else { return nil }
        let record = self.objects[index]
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
        guard index < self.objects.count else { return }
        let record = self.objects[index]
        
        if let imageData = record.image,
            let image = UIImage(data: imageData)
        {
            self.pasteboard.setData(data: image)
            
        } else if let text = record.text {
            self.pasteboard.setData(data: text)
        }
        self.recordsProvider.updateRecord(record, updatedDate: Date())
    }
    
    func removeRecord(atIndex index: Int) {
        guard index < self.objects.count else { return }
        let record = self.objects[index]
        self.recordsProvider.deleteRecord(record)
    }
}
