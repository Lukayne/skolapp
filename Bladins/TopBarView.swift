//
//  TopBarView.swift
//  Bladins
//
//  Created by Adam Alfredsson on 2017-08-23.
//  Copyright © 2017 Richard Smith. All rights reserved.
//

import UIKit

class TopBarView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    func setupView() {
        
        self.backgroundColor = nil
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "TopBarView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.frame = bounds
        self.addSubview(view)
        
    }
    
}
