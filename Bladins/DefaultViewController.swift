//
//  DefaultViewController.swift
//  Bladins
//
//  Created by Adam Alfredsson on 2017-06-25.
//  Copyright © 2017 Richard Smith. All rights reserved.
//

import UIKit

class DefaultViewController: UIViewController {

    var defaultBackgroundColor = Color.custom(hexString: "FAFAFA", alpha: 1).value
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let backgroundView = UIImageView()
//        backgroundView.frame = view.frame
//        backgroundView.image = #imageLiteral(resourceName: "background")
//        backgroundView.contentMode = .scaleAspectFill
//        view.insertSubview(backgroundView, at: 0)
        
        view.backgroundColor = defaultBackgroundColor
//        view.clipsToBounds = true
        
    }
    
}
