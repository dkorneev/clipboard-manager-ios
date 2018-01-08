//
//  AppDelegate.swift
//  ClipboardManager
//
//  Created by Denis Korneev on 05/04/2017.
//
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        let viewModel = LandingViewModel(
            pasteboardManager: PasteboardManager(),
            recordsProvider: RecordsProvider())
        let controller = LandingViewController(viewModel: viewModel)
        self.window?.rootViewController = UINavigationController.init(rootViewController: controller)
        return true
    }
}
