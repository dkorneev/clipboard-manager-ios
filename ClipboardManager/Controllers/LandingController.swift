//
//  LandingController.swift
//  ClipboardManager
//
//  Created by Denis Korneev on 05/04/2017.
//
//

import UIKit
import RealmSwift

protocol LandingViewModelProtocol {
    func numberOfRecords() -> Int
    func recordDataAtIndex(index: Int) -> (data: Any, date: String)?
    func addNewRecord(text: String)
    func updateRecord(atIndex index: Int)
    func removeRecord(atIndex index: Int)
    var updateBlock: ((_ rowIndex: Int?) -> Void)? { get set }
}

class LandingController: UITableViewController {
    private var viewModel: LandingViewModelProtocol
    
    init(viewModel: LandingViewModelProtocol) {
        self.viewModel = viewModel
        super.init(style: .plain)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Clipboard manager"
        let addButton = UIBarButtonItem(barButtonSystemItem: .add,
                                        target: self,
                                        action: #selector(didTapAddButton))
        self.navigationItem.rightBarButtonItem = addButton
        self.viewModel.updateBlock = { [weak self] rowIndex in
            self?.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
    }

    func didTapAddButton() {
        if let newRecord = UIPasteboard.general.string {
            self.viewModel.addNewRecord(text: newRecord)
        }
    }

    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            self.viewModel.removeRecord(atIndex: indexPath.row)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selectedRowIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedRowIndexPath, animated: true)
        }
        self.viewModel.updateRecord(atIndex: indexPath.row)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.numberOfRecords()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseId = "reuseId"
        var cell = tableView.dequeueReusableCell(withIdentifier: reuseId)
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: reuseId)
            cell?.textLabel?.numberOfLines = 4
            cell?.clipsToBounds = true
        }
        if let recordData = self.viewModel.recordDataAtIndex(index: indexPath.row) {
            switch recordData.data {
            case is String:
                cell?.textLabel?.text = recordData.data as? String
            case is UIImage:
                cell?.textLabel?.text = "<Image>"
            default:
                cell?.textLabel?.text = nil
            }
            cell?.detailTextLabel?.text = recordData.date
        }
        return cell!
    }
}
