//
//  MatchViewController.swift
//  CM_UDEMY_APP
//
//  Created by Horr on 15/12/20.
//

import UIKit

protocol MatchViewControllerDelegate {
    
    func didClickSendMessage(to user: FUser)
    func didClickKeepSwiping()
}


class MatchViewController: UIViewController {

    //MARK: IBOutlets
    
    @IBOutlet var cardBackgroundView: UIView!
    @IBOutlet var heartView: UIImageView!
    @IBOutlet var avatarImage: UIImageView!
    @IBOutlet var nameAgeLabel: UILabel!
    @IBOutlet var contryCityLabel: UILabel!
    
    //MARK: Vars
    var user: FUser?
    var delegate: MatchViewControllerDelegate?
    
    //MARK: ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        
        if user != nil {
            presentUserData()
        }
    }
    

    //MARK: Actions
    
    @IBAction func sendMessageButtomPressed(_ sender: Any) {
        delegate?.didClickSendMessage(to: user!)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func keepSwipingButtonPressed(_ sender: Any) {
        delegate?.didClickKeepSwiping()
        self.dismiss(animated: true, completion: nil)
    }

    //MARK: setup
    private func setupUI() {
        
        cardBackgroundView.layer.cornerRadius = 10
        heartView.layer.cornerRadius = 10
        heartView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMinYCorner]
        
        cardBackgroundView.applyShadow(radius: 8, opacity: 0.2, offset: CGSize(width: 0, height: 2))
    }

    private func presentUserData() {
        
        avatarImage.image = user!.avatar?.circleMasked
        let cityCountry = user!.city + ", " + user!.country
        let nameAge = user!.username + ", \(abs(user!.dateOfBirth.interval(ofComponent: .year, fromDate: Date())))"
        
        nameAgeLabel.text = nameAge
        contryCityLabel.text = cityCountry
    }

    

}
