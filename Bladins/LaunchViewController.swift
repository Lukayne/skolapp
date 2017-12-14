//
//  LaunchViewController.swift
//  Bladins
//
//  Created by Adam Alfredsson on 2017-08-27.
//  Copyright © 2017 Richard Smith. All rights reserved.
//

import UIKit

class LaunchViewController: DefaultViewController, LoadsIndicator {
    
    var overlay: UIView?
    var loadingIndicator: LoadingIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startLoading()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopLoading()
    }
    
}
