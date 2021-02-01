//
//  ImageCollectionViewCell.swift
//  CM_UDEMY_APP
//
//  Created by Horr on 08/12/20.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
 
    //MARK: iboutlets
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var backgroundPlaceHolder: UIView!
    @IBOutlet var nameAgeLabel: UILabel!
    @IBOutlet var cityCoutryLabel: UILabel!

    let gradientLayer = CAGradientLayer()
    var indexPath: IndexPath!
    
    override func awakeFromNib() {
        imageView.layer.cornerRadius = 5
        imageView.clipsToBounds = true
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if indexPath.row == 0 {
            backgroundPlaceHolder.isHidden = false
            self.setGradientBackground()

        } else {
            backgroundPlaceHolder.isHidden = true
        }
    }
    
    func setupCell(image: UIImage, country: String, nameAge: String, indexPath: IndexPath) {
        self.indexPath = indexPath
        
        imageView.image = image
        
        cityCoutryLabel.text = indexPath.row == 0 ? country : ""
        nameAgeLabel.text = indexPath.row == 0 ? nameAge : ""

    }
    
    func setGradientBackground(){
        gradientLayer.removeFromSuperlayer()
        
        let colorTop = UIColor.clear.cgColor
        let colorBottom = UIColor.black.cgColor
        
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.cornerRadius = 5
        
        gradientLayer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        gradientLayer.frame = self.backgroundPlaceHolder.bounds
        
        self.backgroundPlaceHolder.layer.insertSublayer(gradientLayer, at: 0)
        
    }
    
    
}
