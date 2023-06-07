//
//  token.swift
//  RestoFlash
//
//  Created by Alexis Contour on 05/04/2023.
//

import Foundation
import Money

public enum TokenType: String, Codable {
    case qrCode = "QRCODE"
    case checkout = "CHECKOUT"
}


public enum Token  {
    case qrCode(qrCode : QrCode)
    case checkout(checkout : Checkout)
    
    public var id: Int64 {
        switch self {
        case .qrCode(let qrCode):
            return Int64(qrCode.sessionId) ?? 0
        case .checkout(let checkout):
            return checkout.id
        }
    }
    
    public var tokenType: TokenType {
        switch self {
        case .qrCode:
            return .qrCode
        case .checkout:
            return .checkout
        }
    }
    
    public var amount: Money<EUR> {
        switch self {
        case .qrCode(let qrCode):
            return qrCode.maxTotalValue
        case .checkout(let checkout):
            return checkout.amount
        }
    }
    
    public var topupAmount: Money<EUR> {
        switch self {
        case .qrCode(let qrCode):
            return qrCode.maxTopUpValue
        case .checkout(let checkout):
            return checkout.topUpAmount ?? 0
        }
    }
    
    public var tokenReference: String? {
        switch self {
        case .qrCode(_):
            return nil
        case .checkout(let checkout):
            return checkout.reference
        }
    }
    
    public var userName: String {
        switch self {
        case .qrCode(let qrCode):
            return "\(qrCode.firstName) \(qrCode.lastName)"
        case .checkout(let checkout):
            return checkout.userName
        }
    }
    
    public var date: Date {
        switch self {
        case .qrCode(let qrCode):
            return qrCode.sessionStart
        case .checkout(let checkout):
            return Date(timeIntervalSince1970: TimeInterval(checkout.date/1000))
        }
    }
    
    public var paymentKeyEncoded : String {
        switch self
        {
        case .qrCode(qrCode: let qrCode):
            return try! qrCode.fullToken.urlBase64()
        case .checkout(checkout: let checkout):
            return try! checkout.sponsorshipKey.urlBase64()
        }
    }
    public var displayKey : String {
        switch self
        {
        case .qrCode(_):
            return ""
        case .checkout(checkout: let checkout):
            return checkout.sponsorshipKey
        }
    }
}
 

extension Token : Hashable
{
    public static func == (lhs: Token, rhs: Token) -> Bool {
        return lhs.id == rhs.id && lhs.tokenType == rhs.tokenType
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(tokenType)
    }
}


