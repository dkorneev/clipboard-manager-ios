//
//  WidgetViewTests.swift
//  ClipboardManagerUITests
//
//  Created by Denis Korneev on 12/01/2018.
//

import XCTest
import FBSnapshotTestCase

class WidgetViewUITests: FBSnapshotTestCase {
    override func setUp() {
        super.setUp()
        self.recordMode = false
    }
    
    private func createWidgetView(
        withData data: [(data: Any, date: Date)],
        andResolution resolution: CGRect) -> UIView
    {
        let viewModel = TestClipboardViewModel(withRecords: data)
        let view = WidgetView.create(withViewModel: viewModel)
        view.frame = resolution
        return view
    }
    
    private func testData() -> [(data: Any, date: Date)]? {
        let bundle = Bundle(for: type(of: self))
        guard let image = UIImage(
            named: "test-image-2.jpeg",
            in: bundle,
            compatibleWith: nil) else
        {
            return nil
        }
        return [
            (data: "first record", Date()),
            (data: image, Date(timeInterval: -5, since: Date())),
            (data: "second record", Date(timeInterval: -10, since: Date()))
        ]
    }
    
    func testEmptyWidgetView() {
        let view = self.createWidgetView(
            withData: [],
            andResolution: Resolution.widgetFrame)
        FBSnapshotVerifyView_64(view)
    }
    
    func testFilledWidgetView() {
        guard let testData = self.testData() else {
            XCTFail()
            return
        }
        let view = self.createWidgetView(
            withData:testData,
            andResolution: Resolution.widgetFrame)
        FBSnapshotVerifyView_64(view)
    }
}
