//
//  LikeTableViewCell.swift
//  CM_UDEMY_APP
//
//  Created by Horr on 15/12/20.
//

import UIKit

class LikeTableViewCell: UITableViewCell {

    //MARK: IBOutlets
    
    @IBOutlet var avatarImageview: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func setupCell(user: FUser) {
        nameLabel.text = user.username
        setAvatar(avatarLink: user.avatarLink)
    }

    private func setAvatar(avatarLink: String){
        FileStorage.downloadImage(imageURL: avatarLink) { (avatarImage) in
            
            self.avatarImageview.image = avatarImage?.circleMasked
        }
    }
}
