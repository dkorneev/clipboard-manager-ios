//
//  ClipboardViewController.swift
//  ClipboardManager
//
//  Created by Denis Korneev on 05/04/2017.
//
//

import UIKit

class ClipboardViewController: UITableViewController {
    private var viewModel: ClipboardViewModelProtocol
    
    init(viewModel: ClipboardViewModelProtocol) {
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
        self.viewModel.reloadDataBlock = { [weak self] in
            self?.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        }
        self.viewModel.refreshRowsBlock = { [weak self] in
            self?.refreshCells()
        }
        
        self.tableView.alwaysBounceVertical = false
        self.tableView.tableFooterView = UIView()
        self.tableView.register(TextTVCell.nib(), forCellReuseIdentifier: TextTVCell.reuseId())
        self.tableView.register(ImageTVCell.nib(), forCellReuseIdentifier: ImageTVCell.reuseId())
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
    }
    
    private func refreshCells() {
        guard let visibleCells = self.tableView?.visibleCells else {
            return
        }
        for cell in visibleCells {
            if cell is RefreshableTVCell {
                (cell as? RefreshableTVCell)?.refresh()
            }
        }
    }
    
    // MARK: - user interactions
    
    @objc private func didTapAddButton() {
        self.viewModel.addNewRecord(withCompletion: nil)
    }

    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView,
                            canEditRowAt indexPath: IndexPath) -> Bool
    {
        return true
    }
    
    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCellEditingStyle,
                            forRowAt indexPath: IndexPath)
    {
        if (editingStyle == .delete) {
            self.viewModel.removeRecord(atIndex: indexPath.row, withCompletion: {
                tableView.reloadRows(at: [indexPath], with: .fade)
                tableView.isEditing = false
            })
        }
    }
    
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath)
    {
        if let selectedRowIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedRowIndexPath, animated: true)
        }
        self.viewModel.selectRecord(atIndex: indexPath.row, withCompletion: nil)
    }
    
    override func tableView(_ tableView: UITableView,
                            heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        guard let recordData = self.viewModel.recordDataAtIndex(index: indexPath.row) else {
            return 0
        }
        switch recordData.data {
        case is String:
            return TextTVCell.height()
        case is UIImage:
            return ImageTVCell.height()
        default: break
        }
        return 0
    }
    
    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int
    {
        return self.viewModel.numberOfRecords()
    }
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        guard let recordData = self.viewModel.recordDataAtIndex(index: indexPath.row) else {
            return UITableViewCell()
        }
        
        switch recordData.data {
        case is String:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: TextTVCell.reuseId()) as? TextTVCell else {
                break
            }
            cell.setText(recordData.data as? String, date: recordData.date)
            return cell
            
        case is UIImage:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: ImageTVCell.reuseId()) as? ImageTVCell else {
                break
            }
            cell.setImage(recordData.data as? UIImage, date: recordData.date)
            return cell
        default: break
        }
        return UITableViewCell()
    }
}
