//
//  RootViewController.swift
//  UICollectionViewTechniques
//
//  Created by takanori on 2019/11/13.
//  Copyright © 2019 takanori. All rights reserved.
//

import UIKit

enum Contents: CaseIterable {
    case overshootableScroll
    case circular1
    case circular2
}

extension Contents {
    var viewController: UIViewController.Type {
        switch self {
        case .overshootableScroll:
            return OvershootableScrollViewController.self
        case .circular1:
            return Circular1ViewController.self
        case .circular2:
            return Circular2ViewController.self
        }
    }
    
    var title: String {
        let string = String(describing: self.viewController)
        return string.replacingOccurrences(of: "ViewController", with: "")
    }
}

private let cellIdentifier = "cell"

class RootViewController: UIViewController {
    
    private let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        title = "UICollectionViewTechniques"
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.flashScrollIndicators()
    }
}

extension RootViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Contents.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.textLabel?.text = Contents.allCases[indexPath.row].title
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    
}

extension RootViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let content = Contents.allCases[indexPath.row]
        let viewController = content.viewController.init()
        viewController.title = content.title
        navigationController?.pushViewController(viewController, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
