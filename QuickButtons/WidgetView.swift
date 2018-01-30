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
    
    private let maxDisplayedRecords = 2;
    private var viewModel: ClipboardViewModelProtocol? {
        didSet {
            viewModel?.reloadDataBlock = { [weak self] in
                self?.tableView.reloadData()
            }
        }
    }
    
    static func create(withViewModel viewModel: ClipboardViewModelProtocol) -> WidgetView {
        let nib = UINib(nibName: "WidgetView", bundle: Bundle(for: WidgetView.self))
        let view = nib.instantiate(withOwner: nil, options: nil)[0] as! WidgetView
        view.viewModel = viewModel
        return view
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        let color = UIColor(red: 238.0/255.0, green: 238.0/255.0, blue: 238.0/255.0, alpha: 0.2)
        self.addButton.backgroundColor = color
    }
    
    // MARK: user interactions
    
    @IBAction func addButtonTap(_ sender: Any) {
        self.viewModel?.addNewRecord(withCompletion: nil)
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int
    {
        guard let viewModel = self.viewModel else {
            return 0
        }
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
            cell?.textLabel?.numberOfLines = 2
        }
        if let text = recordData.data as? String {
            cell?.textLabel?.textColor = UIColor.darkText
            cell?.textLabel?.text = text
            cell?.imageView?.image = nil
        
        } else if let image = recordData.data as? UIImage {
            cell?.textLabel?.text = "(image)"
            cell?.textLabel?.textColor = UIColor.gray
            cell?.imageView?.image = image
        
        } else {
            cell?.textLabel?.textColor = UIColor.darkText
            cell?.textLabel?.text = "unknown"
            cell?.imageView?.image = nil
        }
        return cell!
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 55
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath)
    {
        self.viewModel?.selectRecord(atIndex: indexPath.row, withCompletion: nil)
    }
}
