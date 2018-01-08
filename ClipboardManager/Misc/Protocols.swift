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

protocol LandingViewModelProtocol {
    func numberOfRecords() -> Int
    func recordDataAtIndex(index: Int) -> (data: Any, date: Date)?
    func addNewRecord()
    func selectRecord(atIndex index: Int)
    func removeRecord(atIndex index: Int)
    var updateBlock: ((_ rowIndex: Int?) -> Void)? { get set }
}
