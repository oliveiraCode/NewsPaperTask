//
//  SubscriptionViewController.swift
//  NewsPaperTask
//
//  Created by Leandro Oliveira on 2024-07-31.
//

import UIKit

final class SubscriptionViewController: UIViewController {
    
    private var viewModel: SubscriptionViewModel
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let headerLogoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .blue
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .yellow
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let subscribeTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subscribeSubtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let benefitsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 1
        label.text = "What is new?"
        label.textColor = .blue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subscribeNowButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Subscribe Now", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let disclaimerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.numberOfLines = 0
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let offersStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 16
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let benefitsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isHidden = true
        return stackView
    }()
    
    private let errorView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()

    private let errorLabel: UILabel = {
        let label = UILabel()
        label.text = "An error occurred. Please try again."
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let retryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Retry", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.isUserInteractionEnabled = false
        indicator.startAnimating()
        return indicator
    }()

    private var benefits: [String] = [] {
        didSet {
            updateBenefitsStackView()
        }
    }

    init(viewModel: SubscriptionViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        showLoadingIndicator()

        viewModel.didUpdateState = { [weak self] state in
            switch state {
            case .idle:
                break // do nothing here, it's empty state
            case .loading:
                DispatchQueue.main.async {
                    self?.showLoadingIndicator()
                }
            case .success(let data):
                DispatchQueue.main.async {
                    self?.hideLoadingIndicator()
                    self?.updateUI(with: data)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.hideLoadingIndicator()
                  //  self?.showError(error)
                }
            }
        }
        
        viewModel.fetchSubscriptionData()
    }

    private func updateUI(with data: Record) {
        if let headerLogoURL = URL(string: data.headerLogoUrl) {
            downloadImage(from: headerLogoURL) { [weak self] image in
                self?.headerLogoImageView.image = image
            }
        }

        if let coverImageURL = URL(string: data.subscription.coverImageUrl) {
            downloadImage(from: coverImageURL) { [weak self] image in
                self?.coverImageView.image = image
            }
        }
        
        subscribeTitleLabel.text = data.subscription.subscribeTitle
        subscribeSubtitleLabel.text = data.subscription.subscribeSubtitle
        disclaimerLabel.text = data.subscription.disclaimer
        benefits = data.subscription.benefits
        
        // Remove existing offer buttons
        offersStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Create offer buttons based on the data from API
        data.subscription.offers.forEach { offer in
            let offerButton = createOfferButton(price: offer.price.currencyString, description: offer.information)
            offersStackView.addArrangedSubview(offerButton)
            offersStackView.addArrangedSubview(separatorView)
        }
        
        // Remove the last separator view
        if offersStackView.arrangedSubviews.last == separatorView {
            offersStackView.arrangedSubviews.last?.removeFromSuperview()
        }
    }
    
    private func showLoadingIndicator() {
        if !view.subviews.contains(loadingIndicator) {
            view.addSubview(loadingIndicator)
            NSLayoutConstraint.activate([
                loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                loadingIndicator.widthAnchor.constraint(equalToConstant: 50),
                loadingIndicator.heightAnchor.constraint(equalToConstant: 50)
            ])
        }
        loadingIndicator.startAnimating()
        errorView.isHidden = true
        scrollView.isHidden = true
    }

    private func hideLoadingIndicator() {
        loadingIndicator.stopAnimating()
        errorView.isHidden = true
        scrollView.isHidden = false
    }

    private func showError(_ error: Error) {
        errorView.isHidden = false
        scrollView.isHidden = true
    }

    @objc private func retryAction() {
        showLoadingIndicator()
        viewModel.fetchSubscriptionData()
    }

    private func setupViews() {
        view.backgroundColor = .white
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(headerLogoImageView)
        contentView.addSubview(coverImageView)
        contentView.addSubview(subscribeTitleLabel)
        contentView.addSubview(subscribeSubtitleLabel)
        contentView.addSubview(offersStackView)
        contentView.addSubview(benefitsLabel)
        contentView.addSubview(benefitsStackView)
        contentView.addSubview(subscribeNowButton)
        contentView.addSubview(disclaimerLabel)
        
        // Error View
        view.addSubview(errorView)
        errorView.addSubview(errorLabel)
        errorView.addSubview(retryButton)
        
        // Adding example buttons to stackView
        let offerButton1 = createOfferButton(price: 0.currencyString, description: "N/A")
        let offerButton2 = createOfferButton(price: 0.currencyString, description: "N/A")

        offersStackView.addArrangedSubview(offerButton1)
        offersStackView.addArrangedSubview(separatorView)
        offersStackView.addArrangedSubview(offerButton2)
        
        // Setup benefits label tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleBenefits))
        benefitsLabel.isUserInteractionEnabled = true
        benefitsLabel.addGestureRecognizer(tapGesture)
        
        // Set action on retry button error
        retryButton.addTarget(self, action: #selector(retryAction), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Scroll View Constraints
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // Content View Constraints
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Header Logo
            headerLogoImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            headerLogoImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            headerLogoImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            headerLogoImageView.heightAnchor.constraint(equalToConstant: 20),
            
            // Cover Image
            coverImageView.topAnchor.constraint(equalTo: headerLogoImageView.bottomAnchor, constant: 8),
            coverImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            coverImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            coverImageView.heightAnchor.constraint(equalToConstant: 100),
            
            // Subscribe Title
            subscribeTitleLabel.topAnchor.constraint(equalTo: coverImageView.bottomAnchor, constant: 8),
            subscribeTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            subscribeTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Subscribe Subtitle
            subscribeSubtitleLabel.topAnchor.constraint(equalTo: subscribeTitleLabel.bottomAnchor, constant: 4),
            subscribeSubtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            subscribeSubtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Offers Stack View
            offersStackView.topAnchor.constraint(equalTo: subscribeSubtitleLabel.bottomAnchor, constant: 16),
            offersStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            offersStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            offersStackView.heightAnchor.constraint(equalToConstant: 50),
            
            // Benefits Label
            benefitsLabel.topAnchor.constraint(equalTo: offersStackView.bottomAnchor, constant: 16),
            benefitsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            benefitsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Benefits Stack View
            benefitsStackView.topAnchor.constraint(equalTo: benefitsLabel.bottomAnchor, constant: 8),
            benefitsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            benefitsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Subscribe Now Button
            subscribeNowButton.topAnchor.constraint(equalTo: benefitsStackView.bottomAnchor, constant: 16),
            subscribeNowButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            subscribeNowButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            subscribeNowButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Disclaimer Label
            disclaimerLabel.topAnchor.constraint(equalTo: subscribeNowButton.bottomAnchor, constant: 16),
            disclaimerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            disclaimerLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            disclaimerLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            // Separator View for Offers buttons
            separatorView.widthAnchor.constraint(equalToConstant: 2),
            separatorView.heightAnchor.constraint(equalToConstant: 50),
            
            // Error View Constraints
            errorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            errorView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8), // 80% of view
            errorView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.3), // 30% of view
            
            // Error Label Constraints
            errorLabel.topAnchor.constraint(equalTo: errorView.topAnchor, constant: 16),
            errorLabel.leadingAnchor.constraint(equalTo: errorView.leadingAnchor, constant: 16),
            errorLabel.trailingAnchor.constraint(equalTo: errorView.trailingAnchor, constant: -16),
            
            // Retry Button Constraints
            retryButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 16),
            retryButton.centerXAnchor.constraint(equalTo: errorView.centerXAnchor),
            retryButton.bottomAnchor.constraint(equalTo: errorView.bottomAnchor, constant: -16),
        ])
    }
    
    private func createOfferButton(price: String, description: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("\(price)\n\(description)", for: .normal)
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.textAlignment = .center
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapOfferButton(_:)), for: .touchUpInside)
        return button
    }
    
    private func updateBenefitsStackView() {
        benefitsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        benefits.forEach { benefit in
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 16)
            label.text = benefit
            label.numberOfLines = 0
            benefitsStackView.addArrangedSubview(label)
        }
    }
    
    @objc private func toggleBenefits() {
        benefitsStackView.isHidden.toggle()
    }
    
    @objc private func didTapOfferButton(_ sender: UIButton) {
        sender.isSelected.toggle()
    }
    
    deinit {
        #if DEBUG
        print(">>> GONE \(Self.self)")
        #endif
    }
}
