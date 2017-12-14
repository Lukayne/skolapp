//
//  InformationViewController.swift
//  Bladins
//
//  Created by Adam Alfredsson on 2017-09-20.
//  Copyright © 2017 Richard Smith. All rights reserved.
//

import UIKit

class InformationViewController: DefaultViewController {

    @IBOutlet var summaryText: UITextView! {
        didSet {
            summaryText.textColor = Color.custom(hexString: "FAFAFA", alpha: 1).value
            summaryText.alpha = 0.5
            summaryText.textContainerInset = UIEdgeInsets.zero
            summaryText.textContainer.lineFragmentPadding = 0
        }
    }
    @IBOutlet var descText: UITextView! {
        didSet {
            descText.textColor = Color.custom(hexString: "181818", alpha: 1).value
            descText.alpha = 0.7
            descText.textContainerInset = UIEdgeInsets.zero
            descText.textContainer.lineFragmentPadding = 0
        }
    }
    @IBOutlet var thumbImage: UIImageView! {
        didSet {
            thumbImage.layer.borderColor = Color.custom(hexString: "FAFAFA", alpha: 0.5).value.cgColor
            thumbImage.layer.borderWidth = 1
        }
    }
    @IBOutlet var headerHeightConstraint: NSLayoutConstraint!
    
    var entry: InformationEntry?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard entry != nil else {
            navigationController?.popViewController(animated: true)
            return
        }
        
        navigationItem.title = entry?.title
        summaryText.text = entry?.summary
        descText.text = entry?.desc
        if let urlString = entry?.imageURL {
            if let url = URL(string: urlString) {
                URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                    guard error == nil, let imageData = data else {
                        print(error ?? "Error! Failed getting image")
                        return
                    }
                    DispatchQueue.main.async {
                        self.thumbImage.image = UIImage(data: imageData)
                    }
                }).resume()
            }
        }
        
        setHeaderHeight()
        
    }
    
    func setHeaderHeight() {
        let textHeight = summaryText.sizeThatFits(CGSize(width: summaryText.frame.width, height: CGFloat.greatestFiniteMagnitude)).height
        let margins: CGFloat = 24
        if textHeight + margins > headerHeightConstraint.constant {
            print("Setting header height from:", self.headerHeightConstraint.constant, "to:", textHeight + margins)
            UIView.animate(withDuration: 0.3, animations: {
                self.headerHeightConstraint.constant = textHeight + margins
                self.view.layoutIfNeeded()
            })
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
    }

}
