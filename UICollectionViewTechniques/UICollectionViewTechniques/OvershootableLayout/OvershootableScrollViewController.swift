//
//  OvershootableScrollViewController.swift
//  UICollectionViewTechniques
//
//  Created by takanori on 2019/11/17.
//  Copyright © 2019 takanori. All rights reserved.
//

import UIKit

class OvershootableScrollViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        let flowLayout = OvershootableScrollFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor),
            view.safeAreaLayoutGuide.topAnchor.constraint(equalTo: collectionView.topAnchor),
            view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor)
        ])
        collectionView.backgroundColor = .white
        collectionView.register(SimpleCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.dataSource = self
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = CGSize(width: 50, height: 200)
    }
}


extension OvershootableScrollViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 50
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        let myCell = cell as! SimpleCell
        myCell.setText("\(indexPath.row)")
        return myCell
    }

}

final class OvershootableScrollFlowLayout: UICollectionViewFlowLayout {
    override func prepare() {
        super.prepare()
        guard let collectionView = self.collectionView else { return }
        let verticalInset = 0.5 * (collectionView.frame.height - collectionView.safeAreaInsets.top - collectionView.safeAreaInsets.bottom - itemSize.height)
        sectionInset = UIEdgeInsets(top: verticalInset, left: 0, bottom: verticalInset, right: 0)
        collectionView.horizontalScrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: verticalInset - 10, right: 0)
    }
    
    private func fixAttirute(_ attribute: UICollectionViewLayoutAttributes, overshoot: Bool) -> UICollectionViewLayoutAttributes {
        guard let collectionView = self.collectionView else { preconditionFailure() }
        if overshoot {
            let copied = attribute.copy(with: nil) as! UICollectionViewLayoutAttributes
            let count = copied.indexPath.row
            copied.frame.origin.x = collectionViewContentSize.width + CGFloat(count) * (itemSize.width) +  CGFloat(count + 1) * (minimumLineSpacing)
            return copied
        } else {
            let copied = attribute.copy(with: nil) as! UICollectionViewLayoutAttributes
            let num = collectionView.numberOfItems(inSection: 0)
            let count = num - copied.indexPath.row
            copied.frame.origin.x = -CGFloat(count) * (itemSize.width + minimumLineSpacing)
            return copied
        }
        
        
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var baseElements = super.layoutAttributesForElements(in: rect)
        if rect.origin.x < 0 {
            let additionalRect = CGRect(x: collectionViewContentSize.width + rect.origin.x, y: rect.origin.y, width: abs(rect.origin.x), height: rect.height)
            let additionalIndexPaths = super.layoutAttributesForElements(in: additionalRect)?.map { $0.indexPath }
            let additionalAttributes = additionalIndexPaths?.compactMap { layoutAttributesForItem(at: $0) }
            let fixed = additionalAttributes?.map { fixAttirute($0, overshoot: false) }
            baseElements?.append(contentsOf: fixed ?? [])
        } else if rect.maxX > collectionViewContentSize.width - (collectionView?.frame.width ?? 0) {
            guard let collectionView = self.collectionView else { preconditionFailure() }
            let additionalRect = CGRect(x: 0, y: rect.origin.y, width: collectionView.frame.width, height: rect.height)
            let additionalIndexPaths = super.layoutAttributesForElements(in: additionalRect)?.map { $0.indexPath }
            let additionalAttributes = additionalIndexPaths?.compactMap { layoutAttributesForItem(at: $0) }
            let fixed = additionalAttributes?.map { fixAttirute($0, overshoot: true) }
            baseElements?.append(contentsOf: fixed ?? [])
        }
        return baseElements
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
