//
//  DefaultTableView.swift
//  Bladins
//
//  Created by Adam Alfredsson on 2017-08-25.
//  Copyright © 2017 Richard Smith. All rights reserved.
//

import UIKit

class DefaultTableView: UITableView {
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupView()
    }
    
    func setupView() {
        backgroundColor = .clear
        self.separatorStyle = .none
        self.isOpaque = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
}
