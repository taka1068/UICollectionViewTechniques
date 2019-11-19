//
//  SimpleCell.swift
//  UICollectionViewTechniques
//
//  Created by takanori on 2019/11/19.
//  Copyright © 2019 takanori. All rights reserved.
//

import UIKit

final class SimpleCell: UICollectionViewCell {
    private let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)
        label.font = .boldSystemFont(ofSize: 20)
        label.textColor = .black
        contentView.centerXAnchor.constraint(equalTo: label.centerXAnchor).isActive = true
        contentView.centerYAnchor.constraint(equalTo: label.centerYAnchor).isActive = true
        contentView.backgroundColor = .gray
    }
    
    func setText(_ text: String) {
        self.label.text = text
    }
}
