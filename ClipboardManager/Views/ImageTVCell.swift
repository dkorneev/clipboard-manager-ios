//
//  ImageTVCell.swift
//  ClipboardManager
//
//  Created by Denis Korneev on 18/04/2017.
//
//

import UIKit

class ImageTVCell: UITableViewCell, RefreshableTVCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var recordImageView: UIImageView!
    private var date: Date? {
        didSet {
            self.refresh()
        }
    }
    
    static func reuseId() -> String {
        return "ImageTVCell"
    }
    
    static func nib() -> UINib {
        return UINib(nibName: "ImageTVCell", bundle: Bundle(for: ImageTVCell.self))
    }
    
    static func height() -> CGFloat {
        return 110
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.dateLabel.clipsToBounds = true
        self.dateLabel.layer.cornerRadius = 5
    }
    
    func setImage(_ image: UIImage?, date: Date?) {
        self.recordImageView.image = image
        self.date = date
    }
    
    // MARK: - RefreshableTVCell
    
    func refresh() {
        let dateText = self.date?.timeAgo(since: Date(), numericDates: true, numericTimes: false) ?? ""
        self.dateLabel.text = " \(dateText) "
    }
}
