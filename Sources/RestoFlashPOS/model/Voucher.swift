//
//  Voucher.swift
//  RestoFlash
//
//  Created by Alexis Contour on 04/05/2023.
//

import Foundation


public struct Voucher : Codable {
    var id: String // Id du bon
    var totalAmount: Decimal // Montant total des bons
    var qty: Int // Nb de bon
    var account: String // compte d’imputation dans la caisse
}
