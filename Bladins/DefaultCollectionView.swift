//
//  DefaultCollectionView.swift
//  Bladins
//
//  Created by Adam Alfredsson on 2017-07-28.
//  Copyright © 2017 Richard Smith. All rights reserved.
//

import UIKit

class DefaultCollectionView: UICollectionView {

    var fontColor: UIColor = .darkGray
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupView()
    }
    
    func setupView() {
        backgroundColor = nil
        let collectionViewLayout = self.collectionViewLayout as? UICollectionViewFlowLayout
        collectionViewLayout?.sectionInset = UIEdgeInsetsMake(4, 4, 4, 4)
        collectionViewLayout?.invalidateLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

}
