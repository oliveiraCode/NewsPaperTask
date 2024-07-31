//
//  Double.swift
//  NewsPaperTask
//
//  Created by Leandro Oliveira on 2024-07-31.
//

import Foundation

extension Double {
    /// Returns the `Double` value formatted as a currency string with the format "$0.00".
    var currencyString: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.currencySymbol = "$"
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2
        
        return numberFormatter.string(from: NSNumber(value: self)) ?? "$0.00"
    }
}
