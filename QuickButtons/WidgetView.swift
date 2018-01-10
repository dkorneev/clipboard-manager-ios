//
//  WidgetView.swift
//  QuickButtons
//
//  Created by Denis Korneev on 10/01/2018.
//

import UIKit

class WidgetView: UIView, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    private let maxDisplayedRecords = 3;
    private var viewModel: LandingViewModelProtocol? {
        didSet {
            viewModel?.updateBlock = { [weak self] _ in
                self?.tableView.reloadData()
            }
        }
    }
    
    static func create(withViewModel viewModel: LandingViewModelProtocol) -> WidgetView {
        let nib = UINib(nibName: "WidgetView", bundle: nil)
        let view = nib.instantiate(withOwner: nil, options: nil)[0] as! WidgetView
        view.viewModel = viewModel
        return view
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        let value = UserDefaults.standard.value(forKey: "testKey") as? String ?? "nil"
        print(">>> value for key: \(value)")
    }
    
    // MARK: user interactions
    
    @IBAction func addButtonTap(_ sender: Any) {
        self.viewModel?.addNewRecord()
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int
    {
        guard let viewModel = self.viewModel else {
            return 0
        }
        print(">>> number of records: \(viewModel.numberOfRecords())")
        return min(viewModel.numberOfRecords(), self.maxDisplayedRecords)
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        guard let recordData = viewModel?.recordDataAtIndex(index: indexPath.row) else {
            return UITableViewCell()
        }
        
        let reuseId = "widgetCell"
        var cell = tableView.dequeueReusableCell(withIdentifier: reuseId)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: reuseId)
        }
        if let text = recordData.data as? String {
            cell?.textLabel?.text = text
        
        } else if let _ = recordData.data as? UIImage {
            cell?.textLabel?.text = "image"
        
        } else {
            cell?.textLabel?.text = "unknown"
        }
        return cell!
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 24
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath)
    {
        self.viewModel?.selectRecord(atIndex: indexPath.row)
    }
}
