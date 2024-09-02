//
//  formatting.swift
//  RestoFlash
//
//  Created by Alexis Contour on 05/05/2023.
//

import Foundation
import Money

extension Money<EUR>
{
    public var formattedString : String
    {
        get {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.locale = Locale(identifier: "fr-FR")
            formatter.currencyCode = self.currency.code
            return formatter.string(for: self.amount) ?? ""
        }
    }
}
