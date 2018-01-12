//
//  FBSnapshotTestCase+Extensions.swift
//  ClipboardManagerUITests
//
//  Created by Denis Korneev on 12/01/2018.
//

import Foundation
import FBSnapshotTestCase

extension FBSnapshotTestCase {
    func FBSnapshotVerifyView_64(_ view: UIView) {
        FBSnapshotVerifyView(view, suffixes: NSOrderedSet(array: ["_64"]))
    }
}
