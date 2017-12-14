//
//  InformationCell.swift
//  Bladins
//
//  Created by Adam Alfredsson on 2017-09-20.
//  Copyright © 2017 Richard Smith. All rights reserved.
//

import UIKit

class InformationCell: UITableViewCell {
    @IBOutlet var titleLabel: DefaultLabel!
    @IBOutlet var summaryText: UITextView! {
        didSet {
            summaryText.textColor = Color.custom(hexString: "FAFAFA", alpha: 1).value
            summaryText.alpha = 0.5
            summaryText.textContainerInset = UIEdgeInsets.zero
            summaryText.textContainer.lineFragmentPadding = 0
        }
    }
    @IBOutlet var thumbImage: UIImageView! {
        didSet {
            thumbImage.layer.borderColor = Color.custom(hexString: "FAFAFA", alpha: 0.5).value.cgColor
            thumbImage.layer.borderWidth = 1
        }
    }
    @IBOutlet var expandLabel: DefaultLabel! {
        didSet {
            expandLabel.alpha = 0.7
        }
    }
    
    var entry: InformationEntry? {
        didSet {
            titleLabel.text = entry?.title
            summaryText.text = entry?.summary
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
            if entry?.desc == nil {
                expandLabel.text = ""
            } else {
                expandLabel.text = "Läs mer"
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        thumbImage.image = nil
    }
    
}
