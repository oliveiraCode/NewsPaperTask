//
//  UIView.swift
//  NewsPaperTask
//
//  Created by Leandro Oliveira on 2024-07-31.
//

import UIKit

extension UIView {
    enum BorderSide {
        case left
        case right
        case top
        case bottom
    }
    
    func addBorders(sides: [BorderSide], color: UIColor, width: CGFloat) {
        // Remove existing border views
        self.subviews.filter { $0.tag == 999 }.forEach { $0.removeFromSuperview() }
        
        // Add border views for specified sides
        for side in sides {
            let borderView = UIView()
            borderView.backgroundColor = color
            borderView.tag = 999 // Tag to identify border views
            borderView.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(borderView)
            
            NSLayoutConstraint.activate([
                // Set constraints based on the side
                borderView.widthAnchor.constraint(equalToConstant: width),
                borderView.heightAnchor.constraint(equalToConstant: width)
            ])
            
            switch side {
            case .left:
                NSLayoutConstraint.activate([
                    borderView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                    borderView.topAnchor.constraint(equalTo: self.topAnchor),
                    borderView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
                ])
                
            case .right:
                NSLayoutConstraint.activate([
                    borderView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                    borderView.topAnchor.constraint(equalTo: self.topAnchor),
                    borderView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
                ])
                
            case .top:
                NSLayoutConstraint.activate([
                    borderView.topAnchor.constraint(equalTo: self.topAnchor),
                    borderView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                    borderView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
                ])
                
            case .bottom:
                NSLayoutConstraint.activate([
                    borderView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                    borderView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                    borderView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
                ])
            }
        }
    }
}
