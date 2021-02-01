//
//  RecentTableViewCell.swift
//  CM_UDEMY_APP
//
//  Created by Horr on 15/12/20.
//

import UIKit

class RecentTableViewCell: UITableViewCell {

    //MARK: IBOutlet
    
    @IBOutlet var avatarImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var lastMessageLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var unreadMessageCountLabel: UILabel!
    @IBOutlet var unreadMessageBackgroundView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        unreadMessageBackgroundView.layer.cornerRadius = unreadMessageBackgroundView.frame.width / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

    func generetaCell(recentChat: RecentChat) {
        
        nameLabel.text = recentChat.receiverName
        lastMessageLabel.text = recentChat.lastMessage
        lastMessageLabel.adjustsFontSizeToFitWidth = true
        
        if recentChat.unreadCounter != 0 {
            self.unreadMessageCountLabel.text = "\(recentChat.unreadCounter)"
            self.unreadMessageCountLabel.isHidden = false
            self.unreadMessageBackgroundView.isHidden = false
        } else {
            self.unreadMessageCountLabel.isHidden = true
            self.unreadMessageBackgroundView.isHidden = true
        }
        
        setAvatar(avatarLink: recentChat.avatarLink)
        dateLabel.text = timeElapsed(recentChat.date)
        dateLabel.adjustsFontSizeToFitWidth = true
        
    }
    
    private func setAvatar(avatarLink: String) {
        FileStorage.downloadImage(imageURL: avatarLink) { (avatarImage) in
            
            if avatarImage != nil {
                self.avatarImageView.image = avatarImage?.circleMasked
            }
        }
    }

    func timeElapsed(_ date: Date) -> String {
        
        let seconds = Date().timeIntervalSince(date)
        
        var dateText = ""
        
        if seconds < 60 {
            dateText = "Just now"
        } else if seconds < 60 * 60 {
            let minutes = Int(seconds / 60)
            let minText = minutes > 1 ? "mins" : "min"
            
            dateText = "\(minutes) \( minText)"
        } else if seconds < 24 * 60 * 60 {
            
            let hours = Int(seconds / (60 * 60))
            let hourText = hours > 1 ? "hours" : "hour"
        
            dateText = "\(hours) \( hourText)"
        } else {
            dateText = date.longDate()
        }
        
        return dateText
    }
    
    
}
