//
//  ProcessPayment.swift
//  RestoFlash
//
//  Created by Alexis Contour on 04/05/2023.
//

import Foundation
import Money


public struct GroupedPayments {
    let group : Group
    var payments : [Payment] = []
}

open class PaymentsViewModel{

    
    let askedAmount : Money<EUR>
    let ticketReference : String
    var retrievedPayments : [Payment] = []
    var manualPayments : [Payment] = []
    
    public var payments : [Payment]
    {
        get {
            manualPayments + retrievedPayments
        }
    }
    var selectedPayments : Set<Payment> = Set<Payment>()
    var dontAutoDownload : Bool = false

    
    public init(with askedAmount : Money<EUR>, ticketReference:String,  retrievedTokens : [Token]){
        self.askedAmount = askedAmount
        self.ticketReference = ticketReference
        for token in retrievedTokens {
            retrievedPayments.append(Payment(token: token, result: .pending))
        }
    }
    
    
    func replaceRetrievedTokens(tokens : [Token]){
        self.retrievedPayments = []
        self.selectedPayments.removeAll()
        for token in tokens {
            retrievedPayments.append(Payment(token: token, result: .pending))
        }
    }
    
    func addManualToken(token: Token){
        if let index = manualPayments.firstIndex(where: {$0.token.id == token.id}) {
            manualPayments[index].token = token
        }
        else {
            manualPayments.append(Payment(token: token, result: .pending))
        }
    }
    
    
    var paidAmount : Money<EUR> {
        get {
            retrievedPayments.map({$0.result.paidAmount}).reduce(0.0, +)
        }
    }
    
    var selectedAmount : Money<EUR> {
        get {
            selectedPayments.map({$0.token.amount}).reduce(0.0, +)
        }
    }

    var remainigAmount : Money<EUR> {
        get {
            askedAmount - selectedAmount
        }
    }
    
    var groupedPayments  : [GroupedPayments] {
        get {
            return retrievedPayments.grouped
        }
    }
    
    public func paymentSelected(_ payment: Payment){
        selectedPayments.formUnion(Set([payment]))
    }
    public func paymentUnselected(_ payment: Payment){
        selectedPayments.remove(payment)
    }
    public func paymentGroupSelected(_ group : GroupedPayments){
        selectedPayments.formUnion(Set(group.payments))
    }
    public func paymentGroupUnselected(_ group : GroupedPayments){
        selectedPayments.subtract(Set(group.payments))
    }
    public func isPaymentSelected(_ payment: Payment) -> Bool {
         selectedPayments.contains(payment)
    }
    public func isGroupSelected(_ group : GroupedPayments) -> Bool {
         group.payments.allSatisfy {isPaymentSelected($0)}
    }
}



public enum Group : Hashable
{
    case qr
    case unspecified
    case reference(String)

    var name : String {
        get {
            switch self {
            case .qr:
                return "QR Code"
            case .unspecified:
                return "Sans Référence"
            case .reference(let ref):
                return ref
            }
        }
    }
    //make it hashable
    public func hash(into hasher: inout Hasher) {
        switch self {
        case .qr:
            hasher.combine("qr")
        case .unspecified:
            hasher.combine("unspecified")
        case .reference(let ref):
            hasher.combine(ref)
        }
    }


}


extension Token{
    var group : Group {
        get {
            switch self {
            case .qrCode(_):
                return .qr
            case .checkout(let checkout):
                //check if checkout.reference exist and is not empty
                guard let ref = checkout.reference, !ref.isEmpty else {
                    return .unspecified
                }
                return .reference(ref)
            }
        }
    }
}


extension TokenResult{
    var status : String {
        switch self {
        case .pending:
            return "non confirmé"
        case .success(_):
            return "encaissé"
        case .error(_):
            return "erreur"
        }
    }
}
    
extension Array where Element == Payment {
    var grouped: [GroupedPayments] {
        var retValue = [GroupedPayments]()
        for payment in self {
            switch payment.token.group {
            case .qr:
                if let idx = retValue.firstIndex(where: { $0.group == .qr }) {
                    retValue[idx].payments.append(payment)
                } else {
                    retValue.append(GroupedPayments(group: .qr, payments: [payment]))
                }
            case .unspecified:
                if let idx = retValue.firstIndex(where: { $0.group == .unspecified }) {
                    retValue[idx].payments.append(payment)
                } else {
                    retValue.append(GroupedPayments(group: .unspecified, payments: [payment]))
                }
            case .reference(let name):
                if let idx = retValue.firstIndex(where: { $0.group.name == name }) {
                    retValue[idx].payments.append(payment)
                } else {
                    retValue.append(GroupedPayments(group: .reference(name), payments: [payment]))
                }
            }
        }

        // sort each group by date ASC (oldest first)
        for var groupedPayment in retValue {
            groupedPayment.payments.sort { $0.token.date < $1.token.date }
        }

        return retValue
    }
}

extension Array where Element == GroupedPayments {
    var groups: [Group] {
        return self.map({$0.group})
    }
    subscript(group: Group) -> [Payment]? {
        get {
            for groupedPayment in self {
                if groupedPayment.group == group {
                    return groupedPayment.payments
                }
            }
            return nil
        }
    }
}
