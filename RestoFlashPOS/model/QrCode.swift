//
//  QrCode.swift
//  RestoFlash
//
//  Created by Alexis Contour on 26/04/2023.
//

import Foundation
import Money

public struct QrCode: Codable {
    var issuerId: String
    var sessionId: String
    var productId: String
    var firstName: String
    var lastName: String
    var companyName: String
    var year: Int
    var maxTotalValue: Money<EUR>
    var currencyId: String
    var sessionStart: Date
    var sessionEnd: Date
    var maxTopUpValue: Money<EUR>
    var authorizationId: String
    var signature: String
    var totalValueUsed: Money<EUR>
    var topUpUsed: Money<EUR>
    var bonusId: String
    var signedPart: String
    var serverPart: String
    let fullToken: String

    fileprivate init(issuerId: String, sessionId: String, productId: String, firstName: String, lastName: String, companyName: String, year: Int, maxTotalValue: Money<EUR>, currencyId: String, sessionStart: Date, sessionEnd: Date, maxTopUpValue: Money<EUR>, authorizationId: String, signature: String, totalValueUsed: Money<EUR>, topUpUsed: Money<EUR>, bonusId: String, signedPart: String, serverPart: String, fullToken: String) {
        self.issuerId = issuerId
        self.sessionId = sessionId
        self.productId = productId
        self.firstName = firstName
        self.lastName = lastName
        self.companyName = companyName
        self.year = year
        self.maxTotalValue = maxTotalValue
        self.currencyId = currencyId
        self.sessionStart = sessionStart
        self.sessionEnd = sessionEnd
        self.maxTopUpValue = maxTopUpValue
        self.authorizationId = authorizationId
        self.signature = signature
        self.totalValueUsed = totalValueUsed
        self.topUpUsed = topUpUsed
        self.bonusId = bonusId
        self.signedPart = signedPart
        self.serverPart = serverPart
        self.fullToken = fullToken
    }
}


public extension QrCode {
    init(with token: String) throws {
        if token == "" {
            throw TokenError.qrBadSyntaxException("empty token")
        }
        let elements = token.components(separatedBy: "|")
        if (elements.count < 16) || (elements.count > 17) {
            throw TokenError.qrBadSyntaxException("Invalid token size")
        }
        let issuerId = elements[0]
        let sessionId = elements[1]
        let productId = elements[2]
        let lastName = elements[3]
        let firstName = elements[4]
        let companyName = elements[5]
        let year = Int(elements[6])!
        let maxTotalValue : Money<EUR> = Money<EUR>(stringLiteral: elements[7]) //= Decimal(string: elements[7])!
        let currencyId = elements[8]
        guard let sessionStart = TokenManagement.shared.dateFormatter.date(from: elements[9]),
              let sessionEnd = TokenManagement.shared.dateFormatter.date(from: elements[10])
        else
        {
            throw TokenError.qrBadSyntaxException("Invalid date format")
        }
        let maxTopUpValue : Money<EUR> = Money<EUR>(stringLiteral: elements[11])
        let authorizationId = elements[12]
        let signature = elements[13]
        let totalValueUsed : Money<EUR> = Money<EUR>(stringLiteral: elements[14])
        let topUpUsed : Money<EUR> = Money<EUR>(stringLiteral: elements[15])
        let bonusId = elements.count > 16 ? elements[16] : ""

        //let signedPart = token.substring(to: token.index(token.endIndex, offsetBy: -signature.count - 1))
        //use string slicing with partial range
        let signedPart = token[..<token.index(token.endIndex, offsetBy: -signature.count - 1)]
        //let serverPart = token.substring(to: token.index(token.endIndex, offsetBy: -signature.count - 1)) + signature + "|"
        let serverPart = token[..<token.index(token.endIndex, offsetBy: -signature.count - 1)] + signature + "|"
        self.init(issuerId: issuerId, sessionId: sessionId, productId: productId, firstName: firstName, lastName: lastName, companyName: companyName, year: year, maxTotalValue: maxTotalValue, currencyId: currencyId, sessionStart: sessionStart, sessionEnd: sessionEnd, maxTopUpValue: maxTopUpValue, authorizationId: authorizationId, signature: signature, totalValueUsed: totalValueUsed, topUpUsed: topUpUsed, bonusId: bonusId, signedPart: String(signedPart), serverPart: String(serverPart), fullToken: token)
    }


    var sessionEndString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy hh:mm:ss"
        return dateFormatter.string(from: sessionEnd)
    }

    var sessionStartString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy hh:mm:ss"
        return dateFormatter.string(from: sessionStart)
    }
}


