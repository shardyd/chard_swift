//
//  NewMatchCollectionViewCell.swift
//  CM_UDEMY_APP
//
//  Created by Horr on 15/12/20.
//

import UIKit

class NewMatchCollectionViewCell: UICollectionViewCell {
    
    //MARK: IBOutlets
    @IBOutlet var avatarImageView: UIImageView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    override func awakeFromNib() {
        
        hideActivityIndicator()
    }
    
    func setupCell(avatarLink: String) {
        
        showActivityIndicator()

        self.avatarImageView.image = UIImage(named: "avatar")
        
        FileStorage.downloadImage(imageURL: avatarLink) { (avatarImage) in
            
            self.hideActivityIndicator()
            self.avatarImageView.image = avatarImage?.circleMasked
        }
    }
    
    private func showActivityIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }

    private func hideActivityIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }

}
