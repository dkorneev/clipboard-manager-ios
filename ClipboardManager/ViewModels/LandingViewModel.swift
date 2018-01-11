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
    typealias CompletionBlock = (() -> Void)
    func getAllRecords() -> Array<RecordModel>
    func updateRecord(_ record: RecordModel, updatedDate: Date, withCompletion: CompletionBlock?)
    func createRecord(withText: String, withCompletion: CompletionBlock?)
    func createRecord(withImageData: Data, withCompletion: CompletionBlock?)
    func deleteRecord(_ record: RecordModel, withCompletion: CompletionBlock?)
    func observeChanges(_ block: @escaping () -> Void)
}

class LandingViewModel: LandingViewModelProtocol {
    private let searchRecordQueue = DispatchQueue(label: "add-record-queue")
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
            .sorted(by: { $0.updated > $1.updated })
    }
    
    private func addNewRecord(_ newRecord: Any, withCompletion completion: CompletionBlock?) {
        if let newRecord = newRecord as? String {
            self.addNewRecord(text: newRecord) {
                completion?()
            }
            
        } else if let newRecord = newRecord as? UIImage {
            self.addNewRecord(image: newRecord) {
                completion?()
            }
        }
    }
    
    private func addNewRecord(text newText: String,
                              withCompletion completion: CompletionBlock?)
    {
        self.findExistingRecord(byData: newText) { existingRecord in
            if let existingRecord = existingRecord {
                self.recordsProvider.updateRecord(existingRecord,
                                                  updatedDate: Date(),
                                                  withCompletion: completion)
                
            } else {
                self.recordsProvider.createRecord(withText: newText,
                                                  withCompletion: completion)
            }
        }
    }
    
    private func addNewRecord(image: UIImage,
                              withCompletion completion: CompletionBlock?)
    {
        guard let newImageData = UIImagePNGRepresentation(image) else {
            return
        }
        self.findExistingRecord(byData: newImageData) { existingRecord in
            if let existingRecord = existingRecord {
                self.recordsProvider.updateRecord(existingRecord,
                                                  updatedDate: Date(),
                                                  withCompletion: completion)
                
            } else {
                self.recordsProvider.createRecord(withImageData: newImageData,
                                                  withCompletion: completion)
            }
        }
    }
    
    private func findExistingRecord(byData data: Any,
                                    completion:@escaping ((_ existingRecord: RecordModel?) -> Void))
    {
        let values: [Any?] = self.objects.map { record in
            if data is String {
                return record.text
                
            } else if data is Data {
                return record.image
                
            } else {
                return nil
            }
        }
        self.searchRecordQueue.async {
            let index = values.index { currentValue in
                if let newValue = data as? String,
                    let currentValue = currentValue as? String
                {
                    return newValue == currentValue
                    
                } else if let newValue = data as? Data,
                    let currentValue = currentValue as? Data
                {
                    return newValue == currentValue
                    
                } else {
                    return false
                }
            }
            DispatchQueue.main.async { [weak self] in
                var currentRecord: RecordModel?
                if let index = index {
                    currentRecord = self?.objects[index]
                }
                completion(currentRecord)
            }
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
    
    func addNewRecord(withCompletion completion: CompletionBlock?) {
        if let data = self.pasteboard.currentData() {
            self.addNewRecord(data) {
                completion?()
            }
        }
    }
    
    func selectRecord(atIndex index: Int,
                      withCompletion completion: CompletionBlock?)
    {
        guard index < self.objects.count else { return }
        let record = self.objects[index]
        
        if let imageData = record.image,
            let image = UIImage(data: imageData)
        {
            self.pasteboard.setData(data: image)
            
        } else if let text = record.text {
            self.pasteboard.setData(data: text)
        }
        self.recordsProvider.updateRecord(record, updatedDate: Date()) {
            completion?()
        }
    }
    
    func removeRecord(atIndex index: Int,
                      withCompletion completion: CompletionBlock?)
    {
        guard index < self.objects.count else { return }
        let record = self.objects[index]
        self.recordsProvider.deleteRecord(record) {
            completion?()
        }
    }
}
