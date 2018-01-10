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
        let recordsProvider = RecordsProvider()
        let viewModel = LandingViewModel(pasteboardManager: pbManager,
                                         recordsProvider: recordsProvider)
        let view = WidgetView.create(withViewModel: viewModel)
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.widgetView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.widgetView)
        self.widgetView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.widgetView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.widgetView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.widgetView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        print(">>> view did load")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: NCWidgetProviding
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        print(">>> widgetPerformUpdate")
        let recordsCount = RecordsProvider().getAllRecords().count
        print(">>> records count: \(recordsCount)")
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
//    func widgetMarginInsets(forProposedMarginInsets defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
//        return UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50)
//    }
    
}
