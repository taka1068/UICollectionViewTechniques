//
//  Circular2ViewController.swift
//  UICollectionViewTechniques
//
//  Created by takanori on 2019/11/24.
//  Copyright © 2019 takanori. All rights reserved.
//

import UIKit

// scrollable version of Circular1ViewController
final class Circular2ViewController: UIViewController {
    private var cellCount = 15
    private var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            view.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            view.safeAreaLayoutGuide.topAnchor.constraint(equalTo: stackView.topAnchor),
            view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: stackView.bottomAnchor)
        ])
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Scroll Vertically"
        stackView.addArrangedSubview(label)
        label.font = .boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        label.textColor = .black
        
        let layout = Circular2Layout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
        stackView.addArrangedSubview(collectionView)
        
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.dataSource = self
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleGestureRecognizer(_:)))
        collectionView.addGestureRecognizer(tapGestureRecognizer)
    }
}

private let cellSize = CGSize(width: 30, height: 30)

extension Circular2ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.layer.cornerRadius = cellSize.height / 2
        cell.backgroundColor = .lightGray
        cell.layer.borderColor = UIColor.darkGray.cgColor
        cell.layer.borderWidth = 1.0
        return cell
    }
}


extension Circular2ViewController {
    @objc private func handleGestureRecognizer(_ sender: UIGestureRecognizer) {
        guard let collectionView = sender.view as? UICollectionView else { return }
        let tapLocation = sender.location(in: sender.view)
        if let indexPath = collectionView.indexPathForItem(at: tapLocation) {
            cellCount -= 1
            collectionView.performBatchUpdates({
                collectionView.deleteItems(at: [indexPath])
            }, completion: nil)
        } else {
            cellCount += 1
            collectionView.performBatchUpdates({
                collectionView.insertItems(at: [IndexPath(row: 0, section: 0)])
            }, completion: nil)
        }
    }
}

final class Circular2Layout: UICollectionViewLayout {
    private var cellCount = 0
    private var center = CGPoint.zero
    private var radius = CGFloat.zero
    // rotation of layout
    private var rotation = CGFloat.zero
    
    private var insertIndexPath = [IndexPath?]()
    private var deleteIndexPath = [IndexPath?]()
    
    override func prepare() {
        super.prepare()
        
        guard let collectionView = self.collectionView else { return }
        
        cellCount = collectionView.numberOfItems(inSection: 0)
        center = CGPoint(x: collectionView.frame.width / 2, y: collectionView.frame.height / 2)
        radius = min(collectionView.frame.width, collectionView.frame.height) / 2.5
        
        rotation = collectionView.contentOffset.y / collectionViewContentSize.height * .pi
    }
    
    override var collectionViewContentSize: CGSize {
        let size = collectionView?.frame.size ?? super.collectionViewContentSize
        return size.applying(CGAffineTransform(scaleX: 1, y: 5))
    }
    
    override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        super.prepare(forCollectionViewUpdates: updateItems)
        
        insertIndexPath.removeAll()
        deleteIndexPath.removeAll()

        for update in updateItems {
            switch update.updateAction {
            case .delete:
                deleteIndexPath.append(update.indexPathBeforeUpdate)
            case .insert:
                insertIndexPath.append(update.indexPathAfterUpdate)
            default:
                break
            }
        }
    }
    
    override func finalizeCollectionViewUpdates() {
        super.finalizeCollectionViewUpdates()
        
        self.insertIndexPath.removeAll()
        self.deleteIndexPath.removeAll()
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        attributes.size = cellSize
        let angle = 2 * CGFloat(indexPath.row) * CGFloat.pi / CGFloat(cellCount) + rotation
        let centerX = center.x + radius * cos(angle)
        let centerY = center.y + radius * sin(angle)
        let offsetY = collectionView?.contentOffset.y ?? 0
        attributes.center = CGPoint(x: centerX, y: centerY + offsetY)
        return attributes
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return (0..<cellCount).compactMap { row in
            let indexPath = IndexPath(row: row, section: 0)
            return self.layoutAttributesForItem(at: indexPath)
        }
    }
    
    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath)
        
        // update only indexPaths that actually inserted
        if self.insertIndexPath.contains(itemIndexPath) {
            attributes?.alpha = 0.0
            attributes?.center = self.center.applying(CGAffineTransform(translationX: 0, y: collectionView!.contentOffset.y))
        }
        
        return attributes
    }

    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = super.finalLayoutAttributesForDisappearingItem(at: itemIndexPath)
        
        // update only indexPaths that actually deleted
        if deleteIndexPath.contains(itemIndexPath) {
            attributes?.alpha = 0.0
            attributes?.center = self.center.applying(CGAffineTransform(translationX: 0, y: collectionView!.contentOffset.y))
            attributes?.transform3D = CATransform3DMakeScale(0.1, 0.1, 1.0)
        }
        
        return attributes
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
