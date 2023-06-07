//
// Created by Alexis Contour on 12/04/2023.
//

import Foundation
import Money

public struct Checkout: Codable {
    let id: Int64
    let userName: String
    let date: Int64
    let amount: Money<EUR>
    let reference: String?
    let sponsorshipKey: String
    let issuer: Int
    let topUpAmount: Money<EUR>?
}
