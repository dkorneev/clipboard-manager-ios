//
//  TextTVCell.swift
//  ClipboardManager
//
//  Created by Denis Korneev on 18/04/2017.
//
//

import UIKit
import DateToolsSwift

class TextTVCell: UITableViewCell, RefreshableTVCell {
    private var date: Date? {
        didSet {
            self.refresh()
        }
    }
    
    static func reuseId() -> String {
        return "TextTVCell"
    }
    
    static func nib() -> UINib {
        return UINib(nibName: "TextTVCell", bundle: Bundle(for: TextTVCell.self))
    }
    
    static func height() -> CGFloat {
        return 110
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.textLabel?.numberOfLines = 4
        self.clipsToBounds = true
    }
    
    func setText(_ text: String?, date: Date?) {
        self.textLabel?.text = text
        self.date = date
    }
    
    // MARK: - RefreshableTVCell
    
    func refresh() {
        let dateText = self.date?.timeAgo(since: Date(), numericDates: true, numericTimes: false)
        self.detailTextLabel?.text = dateText
    }
}
