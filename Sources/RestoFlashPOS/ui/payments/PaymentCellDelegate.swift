//
//  PaymentCellDelegate.swift
//  RestoFlashPOS
//
//  Created by Alexis Contour on 24/05/2023.
//

import Foundation


protocol PaymentCellDelegate: AnyObject {
    func didSelectPayment(_ payments: Payment)
    func didDeselectPayment(_ payments: Payment)
    func didSelectGroup(_ group : GroupedPayments, section : Int)
    func didDeselectGroup(_ group: GroupedPayments, section : Int)
}
