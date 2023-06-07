//
//  Transaction.swift
//  RestoFlash
//
//  Created by Alexis Contour on 03/05/2023.
//

import Foundation
import Money

public class Transaction : Codable {
    public var id: String
    public var totalAmount: Money<EUR>
    public var product: String
    public var productAmount: Money<EUR>
    public var topUpAmount: Money<EUR>
    public var loginPos: String
    public var scanTime: Date
    public var reference: String
    public var ben: String
    public var company: String
    public var bonusId: String?
    public var bonusName: String?
    public var vouchers: [Voucher]?

    init(id: String, totalAmount: Money<EUR>, product: String, productAmount: Money<EUR>, topUpAmount: Money<EUR>, loginPos: String, scanTime: Date, reference: String, ben: String, company: String, bonusId: String?=nil, bonusName: String?=nil, vouchers: [Voucher]?=nil) {
        self.id = id
        self.totalAmount = totalAmount
        self.product = product
        self.productAmount = productAmount
        self.topUpAmount = topUpAmount
        self.loginPos = loginPos
        self.scanTime = scanTime
        self.reference = reference
        self.ben = ben
        self.company = company
        self.bonusId = bonusId
        self.bonusName = bonusName
        self.vouchers = vouchers
    }
}
