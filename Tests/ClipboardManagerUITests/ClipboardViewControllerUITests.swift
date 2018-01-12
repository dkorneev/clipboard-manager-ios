//
//  ClipboardViewControllerUITests.swift
//  ClipboardManagerUITests
//
//  Created by Denis Korneev on 12/01/2018.
//

import XCTest
import FBSnapshotTestCase

class ClipboardViewControllerUITests: FBSnapshotTestCase {
    private var keyWindow: UIWindow?
    
    override func setUp() {
        super.setUp()
        self.recordMode = false
    }
    
    override func tearDown() {
        super.tearDown()
        self.keyWindow = nil
    }
    
    private func createClipboardView(
        withData data: [(data: Any, date: Date)],
        andResolution resolution: CGRect) -> UIView
    {
        let viewModel = TestClipboardViewModel(withRecords: data)
        let controller = ClipboardViewController(viewModel: viewModel)
        controller.edgesForExtendedLayout = UIRectEdge(rawValue: 0)
        let navController = UINavigationController(rootViewController: controller)
        
        self.keyWindow = UIWindow(frame: resolution)
        self.keyWindow?.makeKeyAndVisible()
        self.keyWindow?.rootViewController = navController
        
        self.usesDrawViewHierarchyInRect = true
        return navController.view
    }
    
    private func testData() -> [(data: Any, date: Date)]? {
        let bundle = Bundle(for: type(of: self))
        guard let image = UIImage(
            named: "test-image-1.jpeg",
            in: bundle,
            compatibleWith: nil) else
        {
            return nil
        }
        return [
            (data: "first record", Date()),
            (data: "second record", Date(timeInterval: -5, since: Date())),
            (data: image, Date(timeInterval: -10, since: Date()))
        ]
    }
    
    // MARK: empty clipboard
    
    func testEmptyClipboardIphone7() {
        let view = self.createClipboardView(
            withData: [],
            andResolution: Resolution.iphone7)
        FBSnapshotVerifyView_64(view)
    }
    
    func testEmptyClipboardIphoneSE() {
        let view = self.createClipboardView(
            withData: [],
            andResolution: Resolution.iphoneSE)
        FBSnapshotVerifyView_64(view)
    }
    
    // MARK: filled clipboard
    
    func testClipboardIphone7() {
        guard let testData = self.testData() else {
            XCTFail()
            return
        }
        let view = self.createClipboardView(
            withData:testData,
            andResolution: Resolution.iphone7)
        FBSnapshotVerifyView_64(view)
    }
    
    func testClipboardIphoneSE() {
        guard let testData = self.testData() else {
            XCTFail()
            return
        }
        let view = self.createClipboardView(
            withData:testData,
            andResolution: Resolution.iphoneSE)
        FBSnapshotVerifyView_64(view)
    }
}
