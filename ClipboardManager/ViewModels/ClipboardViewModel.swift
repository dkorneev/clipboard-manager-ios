//
//  ClipboardViewModel.swift
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

protocol RecordModelProtocol {
    var text: String? { get set }
    var imageData: Data? { get set }
    var created: Date { get set }
    var updated: Date { get set }
    
    func hasTheSameData(_ data: Any) -> Bool
}

protocol RecordsProviderProtocol {
    typealias CompletionBlock = (() -> Void)
    func getAllRecords() -> Array<RecordModelProtocol>
    func updateRecord(_ record: RecordModelProtocol, updatedDate: Date, withCompletion: CompletionBlock?)
    func createRecord(withText: String, withCompletion: CompletionBlock?)
    func createRecord(withImageData: Data, withCompletion: CompletionBlock?)
    func deleteRecord(_ record: RecordModelProtocol, withCompletion: CompletionBlock?)
    func observeChanges(_ block: @escaping () -> Void)
}

class ClipboardViewModel: ClipboardViewModelProtocol {
    private let searchRecordQueue = DispatchQueue(label: "add-record-queue")
    private var objects: Array<RecordModelProtocol> = []
    private let pasteboard: PasteboardManagerProtocol
    private let recordsProvider: RecordsProviderProtocol
    
    private lazy var timer: Timer = { () -> Timer in
        return Timer.init(timeInterval: 0.2, repeats: true, block: { [weak self] _ in
            self?.refreshRowsBlock?()
        })
    }()
    
    init(pasteboardManager: PasteboardManagerProtocol,
         recordsProvider: RecordsProviderProtocol)
    {
        self.pasteboard = pasteboardManager
        self.recordsProvider = recordsProvider
        self.recordsProvider.observeChanges { [weak self] in
            self?.resetObjects()
            self?.reloadDataBlock?()
        }
        self.resetObjects()
        RunLoop.current.add(self.timer, forMode: .defaultRunLoopMode)
    }
    
    deinit {
        self.timer.invalidate()
    }
    
    private func resetObjects() {
        self.objects = self.recordsProvider.getAllRecords()
            .sorted(by: { $0.updated > $1.updated })
    }
    
    private func addNewRecord(withText newText: String? = nil,
                              withImageData imageData: Data? = nil,
                              withCompletion completion: CompletionBlock?)
    {
        let newValue: Any? = newText == nil ? imageData : newText
        guard let data = newValue else {
            completion?()
            return
        }
        self.searchRecordQueue.async {
            let existingRecord = self.objects.first(where: { $0.hasTheSameData(data) })
            DispatchQueue.main.async {
                if let existingRecord = existingRecord {
                    self.recordsProvider.updateRecord(
                        existingRecord,
                        updatedDate: Date(),
                        withCompletion: completion)
                    
                } else if let newText = newText {
                    self.recordsProvider.createRecord(
                        withText: newText,
                        withCompletion: completion)
                    
                } else if let imageData = imageData {
                    self.recordsProvider.createRecord(
                        withImageData: imageData,
                        withCompletion: completion)
                    
                } else {
                    completion?()
                }
            }
        }
    }
    
    // MARK: - ClipboardViewModelProtocol
    
    var reloadDataBlock: (() -> Void)?
    var refreshRowsBlock: (() -> Void)?
    
    func numberOfRecords() -> Int {
        return self.objects.count
    }
    
    func recordDataAtIndex(index: Int) -> (data: Any, date: Date)? {
        guard index < self.objects.count else { return nil }
        let record = self.objects[index]
        if let imageData = record.imageData,
            let image = UIImage(data: imageData)
        {
            return (data: image as Any, date: record.updated)
        
        } else if let text = record.text {
            return (data: text as Any, date: record.updated)
        
        } else {
            return nil
        }
    }
    
    func addNewRecord(withCompletion completion: CompletionBlock?) {
        guard let data = self.pasteboard.currentData() else {
            completion?()
            return
        }
        if let text = data as? String {
            self.addNewRecord(withText: text) {
                completion?()
            }
            
        } else if let image = data as? UIImage {
            guard let newImageData = UIImagePNGRepresentation(image) else {
                print("ClipboardViewModel - can't get image data")
                completion?()
                return
            }
            self.addNewRecord(withImageData: newImageData) {
                completion?()
            }
            
        } else {
            print("ClipboardViewModel - not supported record type")
            completion?()
        }
    }
    
    func selectRecord(atIndex index: Int,
                      withCompletion completion: CompletionBlock?)
    {
        guard index < self.objects.count else { return }
        let record = self.objects[index]
        
        if let imageData = record.imageData,
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
