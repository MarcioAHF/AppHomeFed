//
//  RequestListFlow.swift
//  AHF
//
//  Created by marcio on 2020-07-12.
//

import UIKit

class RequestListFlow: UICollectionViewFlowLayout {
    override func prepare() {
        super.prepare()
        
        guard let collectionView = collectionView else { return }
        
        let availableWidth = collectionView.bounds.inset(by: collectionView.layoutMargins).width
        let maxNumColumns = 2 
        let cellWidth = (availableWidth / CGFloat(maxNumColumns)).rounded(.down)
        
        self.itemSize = CGSize(width: cellWidth, height: cellWidth)
        self.sectionInset = UIEdgeInsets(top: self.minimumInteritemSpacing, left: 0.0, bottom: 0.0, right: 0.0)
        self.sectionInsetReference = .fromSafeArea
    }
}
