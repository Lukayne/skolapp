//
//  AlarmTopBar.swift
//  Bladins
//
//  Created by Adam Alfredsson on 2017-06-25.
//  Copyright © 2017 Richard Smith. All rights reserved.
//

import UIKit

protocol AlarmTopBarDelegate {
    var alarmTopBarView: AlarmTopBar! { get }
    func goBack()
}

// Designable
class AlarmTopBar: UIView {
    
    @IBOutlet weak var alarmLabel: UILabel!

    var defaultBackgroundColor: UIColor = Color.red.value
    var labelFontColor: UIColor = Color.redFont.value
    
    var delegate: AlarmTopBarDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    func setupView() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "AlarmTopBar", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.frame = bounds
        self.addSubview(view)
        
        view.backgroundColor = defaultBackgroundColor
        alarmLabel.textColor = labelFontColor
    }
    
    
    @IBAction func leftButtonPressed(_ sender: UIButton) {
        delegate?.goBack()
    }

}
