//
//  BlockCollectionView.swift
//  Bladins
//
//  Created by Adam Alfredsson on 2017-08-09.
//  Copyright © 2017 Richard Smith. All rights reserved.
//

import UIKit

// Designable
class BlockTableView: UITableView {
    
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
//    var headerLabelText: String?
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    func setupView() {
        backgroundColor = nil
//        self.isOpaque = false
//        self.isScrollEnabled = false
//        backgroundColor = Color.custom(hexString: "161616", alpha: 0.4).value
//        layer.shadowColor = UIColor.blue.cgColor
//        layer.shadowRadius = 1
//        layer.shadowOffset = CGSize(width: 1, height: 1)
//        layer.shadowOpacity = 0.6
//        layer.shadowPath = UIBezierPath(rect: self.frame).cgPath
    }

}
