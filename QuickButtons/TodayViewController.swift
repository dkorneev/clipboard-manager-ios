//
//  TodayViewController.swift
//  QuickButtons
//
//  Created by Denis Korneev on 26/08/2017.
//
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    private lazy var widgetView: WidgetView = {
        let pbManager = PasteboardManager()
        let recordsProvider = RecordsProvider(withRealmProvider: RealmProvider())
        let viewModel = ClipboardViewModel(pasteboardManager: pbManager,
                                         recordsProvider: recordsProvider)
        let view = WidgetView.create(withViewModel: viewModel)
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clear
        self.widgetView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.widgetView)
        self.widgetView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.widgetView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.widgetView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.widgetView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
    }
    
    // MARK: NCWidgetProviding
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        self.widgetView.tableView.reloadData()
        completionHandler(NCUpdateResult.newData)
    }
}
