//
//  Untitled.swift
//  NewsPaperTask
//
//  Created by Leandro Oliveira on 2024-07-31.
//

import UIKit

final class OffersView: UIView {
    private let offerView1: OfferView
    private let offerView2: OfferView
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private var selectedOfferView: OfferView? {
        didSet {
            updateSelection()
        }
    }
    
    init(offer1: OfferView, offer2: OfferView) {
        self.offerView1 = offer1
        self.offerView2 = offer2
        super.init(frame: .zero)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        offerView1.translatesAutoresizingMaskIntoConstraints = false
        offerView2.translatesAutoresizingMaskIntoConstraints = false
        
        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(didTapOfferView1))
        offerView1.addGestureRecognizer(tapGesture1)
        offerView1.isUserInteractionEnabled = true
        
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(didTapOfferView2))
        offerView2.addGestureRecognizer(tapGesture2)
        offerView2.isUserInteractionEnabled = true
        
        addSubview(stackView)
        stackView.addArrangedSubview(offerView1)
        stackView.addArrangedSubview(offerView2)
        
        offerView1.addBorders(sides: [.right], color: .gray, width: 2)
        offerView2.addBorders(sides: [.left], color: .gray, width: 2)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            offerView1.widthAnchor.constraint(equalTo: offerView2.widthAnchor),
            offerView1.heightAnchor.constraint(equalTo: heightAnchor),
            offerView2.widthAnchor.constraint(equalTo: offerView1.widthAnchor),
            offerView2.heightAnchor.constraint(equalTo: heightAnchor)
        ])
    }
    
    @objc private func didTapOfferView1() {
        selectedOfferView = offerView1
    }
    
    @objc private func didTapOfferView2() {
        selectedOfferView = offerView2
    }
    
    private func updateSelection() {
        offerView1.isSelected = (selectedOfferView == offerView1)
        offerView2.isSelected = (selectedOfferView == offerView2)
    }
}

final class OfferView: UIView {
    
    let priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 30)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label.numberOfLines = 2
        label.textAlignment = .center
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var isSelected: Bool = false {
        didSet {
            updateAppearance()
        }
    }
    
    init(price: String, description: String, isChecked: Bool) {
        super.init(frame: .zero)
        setupViews()
        setupConstraints()
        update(price: price, description: description, isChecked: isChecked)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        backgroundColor = .white
        addSubview(priceLabel)
        addSubview(descriptionLabel)
        addSubview(iconImageView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Icon Image View
            iconImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            // Price Label
            priceLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            priceLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            
            // Description Label
            descriptionLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 8),
            descriptionLabel.bottomAnchor.constraint(equalTo: iconImageView.topAnchor, constant: -4),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    func update(price: String, description: String, isChecked: Bool) {
        priceLabel.text = price
        descriptionLabel.text = description
        iconImageView.image = UIImage(systemName: isChecked ? "checkmark.circle.fill" : "circle")
    }

    private func updateAppearance() {
        iconImageView.image = UIImage(systemName: isSelected ? "checkmark.circle.fill" : "circle")
    }
}
