//
//  AsyncParameter.swift
//  RestoFlash
//
//  Created by Alexis Contour on 11/04/2023.
//

import Foundation

enum PaymentStatus: String, Codable {
    case waitConfirmation = "WAIT_CONFIRMATION"
    case confirmed = "CONFIRMED"
    case canceled = "CANCELED"
    case canceledAfterConfirmed = "CANCELED_AFTER_CONFIRMED"
    case synced = "SYNCED"
    case cancelSynced = "CANCEL_SYNCED"
    case error = "ERROR"
}


struct PaymentLog: Codable, CustomStringConvertible {
    var date: String
    var command: String
    var status: PaymentStatus
    var amounts: String
    
    var description: String {
        return "LOG \(date) \(command) \(status) amounts:\(amounts)"
    }
}

struct AsyncParameter: Codable {
    let localId: String
    let encodedToken: String
    let amount: Decimal
    let acceptPartial: Bool
    let scanDate: Int64
    let encodedImei: String
    let encodedReference: String
    let activityTime: Int64?
    let cancelledAmount: Decimal
    let logs: [PaymentLog]
}
