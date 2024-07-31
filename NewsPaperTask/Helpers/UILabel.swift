//
//  UILabel.swift
//  NewsPaperTask
//
//  Created by Leandro Oliveira on 2024-07-31.
//

import UIKit

extension UILabel {
    func setHTMLFromString(htmlText: String) {
        guard let data = htmlText.data(using: .utf8) else { return }
        
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        
        do {
            let attributedString = try NSMutableAttributedString(data: data, options: options, documentAttributes: nil)
            self.attributedText = attributedString
        } catch {
            print("Error setting HTML: \(error)")
        }
    }
}
