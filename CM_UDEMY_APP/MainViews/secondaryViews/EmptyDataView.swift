//
//  EmptyDataView.swift
//  CM_UDEMY_APP
//
//  Created by Horr on 21/01/21.
//

import UIKit

protocol EmptyDataViewDelegate {
    func didClickReloadButton ()
}

class EmptyDataView: UIView {

    //MARK: iboutlet
    @IBOutlet var contentView: UIView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var reloadButton: UIButton!

    //MARK: vars
    var delegate: EmptyDataViewDelegate?
        
    //MARK: initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        
        Bundle.main.loadNibNamed("EmptyDataView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    @IBAction func reloadButtonPressed(_ sender: Any) {
        
        delegate?.didClickReloadButton()
    }
    
}
