//
//  PaymentResult.swift
//  RestoFlash
//
//  Created by Alexis Contour on 03/05/2023.
//

import Foundation
import Money

public enum TokenResult
{
    case pending
    case success(Transaction)
    case error(RequestError)
}

extension TokenResult
{
    var paidAmount : Money<EUR> {
        get {
            switch self {
            case .pending:
                return 0.0
            case .success(let transaction):
                return transaction.totalAmount
            case .error(_):
                return 0.0
            }
        }
    }
}
