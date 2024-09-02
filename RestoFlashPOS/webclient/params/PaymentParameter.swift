//
//  PaymentParameter.swift
//  RestoFlashPOS
//
//  Created by Alexis Contour on 18/05/2023.
//

import Foundation
import Money

public struct PaymentParameter: Codable, Equatable {
    let encodedToken: String
    let amount: Money<EUR>
    let acceptPartial: Bool
    let timestampInMsUTC: Int64
    let encodedSignature: String?
    let encodedImei: String
    let encodedReference: String
    let activityTime: Int64?
}
