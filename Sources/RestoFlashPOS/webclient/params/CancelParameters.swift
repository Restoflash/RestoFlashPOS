//
//  CancelParameters.swift
//  RestoFlash
//
//  Created by Alexis Contour on 11/04/2023.
//

import Foundation


struct CancelTransactionParameters: Codable {
    let id: String
    let amount: Decimal
    let timestampInMsUTC: Int64
    let amountToCancel: Decimal
    let encodedImei: String
    let localId: String
} 
