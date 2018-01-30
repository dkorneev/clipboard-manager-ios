//
//  Protocols.swift
//  ClipboardManager
//
//  Created by Denis Korneev on 18/04/2017.
//
//

import Foundation

protocol RefreshableTVCell {
    func refresh()
}

protocol ClipboardViewModelProtocol {
    typealias CompletionBlock = (() -> Void)
    func numberOfRecords() -> Int
    func recordDataAtIndex(index: Int) -> (data: Any, date: Date)?
    func addNewRecord(withCompletion: CompletionBlock?)
    func selectRecord(atIndex index: Int, withCompletion: CompletionBlock?)
    func removeRecord(atIndex index: Int, withCompletion: CompletionBlock?)
    var reloadDataBlock: (() -> Void)? { get set }
    var refreshRowsBlock: (() -> Void)? { get set }
}
