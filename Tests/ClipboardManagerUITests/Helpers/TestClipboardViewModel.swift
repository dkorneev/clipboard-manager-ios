//
//  TestClipboardViewModel.swift
//  ClipboardManagerUITests
//
//  Created by Denis Korneev on 12/01/2018.
//

import Foundation

class TestClipboardViewModel: ClipboardViewModelProtocol {
    private let records: [(data: Any, date: Date)]
    
    init(withRecords initialRecords: [(data: Any, date: Date)]) {
        records = initialRecords
    }
    
    // MARK: ClipboardViewModelProtocol

    var updateBlock: ((_ rowIndex: Int?) -> Void)?
    
    func numberOfRecords() -> Int {
        return self.records.count
    }
    
    func recordDataAtIndex(index: Int) -> (data: Any, date: Date)? {
        return self.records[index]
    }
    
    func addNewRecord(withCompletion completion: CompletionBlock?) {
        completion?()
    }
    
    func selectRecord(atIndex index: Int,
                      withCompletion completion: CompletionBlock?)
    {
        completion?()
    }
    
    func removeRecord(atIndex index: Int,
                      withCompletion completion: CompletionBlock?)
    {
        completion?()
    }
}
