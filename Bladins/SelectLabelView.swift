//
//  SelectLabelView.swift
//  Bladins
//
//  Created by Adam Alfredsson on 2017-08-04.
//  Copyright © 2017 Richard Smith. All rights reserved.
//

import UIKit

// Designable
class SelectLabelView: UIView {
    
    @IBOutlet var textLabel: UILabel!
    
    @IBInspectable var labelText: String = "" {
        didSet {
            textLabel.text = self.labelText
        }
    }
    
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
        let nib = UINib(nibName: "SelectLabelView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.frame = bounds
        self.addSubview(view)
        
    }
}
