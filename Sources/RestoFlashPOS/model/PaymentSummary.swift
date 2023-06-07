//
//  Payment.swift
//  RestoFlash
//
//   by Alexis Contour on 03/05/2023.
//

import Foundation
import Money

public enum PaymentResult{
    case canceled
    case summary(PaymentSummary)
}



public struct PaymentSummary {
    public let askedAmount : Money<EUR>
    public let paidAmount : Money<EUR>
    public let payments : [Payment]
    public var remainingAmount : Money<EUR> {
        return askedAmount - paidAmount
    }
    public var hasError : Bool {
        return payments.contains(where: { (payment) -> Bool in
            if case .error(_) = payment.result {
                return true
            }
            return false
        })
    }

    public var errorList : [RequestError] {
        return payments.compactMap { (payment) -> RequestError? in
            if case .error(let error) = payment.result {
                return error
            }
            return nil
        }
    }
    
    init(with askedAmount : Money<EUR>, payments : [Payment]){
        self.askedAmount = askedAmount
        self.payments = payments
        var totalAmount : Money<EUR> = 0.0
        for payment in payments {
            if case .success(let transaction) = payment.result {
                totalAmount += transaction.totalAmount
            }
        }
        self.paidAmount = totalAmount
    }
    
}
