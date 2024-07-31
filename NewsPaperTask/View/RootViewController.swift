//
//  RootViewController.swift
//  NewsPaperTask
//
//  Created by Leandro Oliveira on 2024-07-31.
//

import UIKit

final class RootViewController: UIViewController {
    
    private let openDetailsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Open Subscription Details", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupViews()
        setupConstraints()
        
        openDetailsButton.addTarget(self, action: #selector(openSubscriptionDetails), for: .touchUpInside)
    }
    
    private func setupViews() {
        view.addSubview(openDetailsButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            openDetailsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            openDetailsButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc private func openSubscriptionDetails() {
        let viewModel = SubscriptionViewModel(service: SubscriptionService())
        let subscriptionViewController = SubscriptionViewController(viewModel: viewModel)
        navigationController?.pushViewController(subscriptionViewController, animated: true)
    }
}
