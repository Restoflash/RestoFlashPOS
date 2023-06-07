//
//  Payment.swift
//  RestoFlash
//
//  Created by Alexis Contour on 10/05/2023.
//

import Foundation


//public typealias Payment = (token:Token, result:TokenResult)


//use struct
public struct Payment {
    public var token: Token
    public var result: TokenResult
}

extension Payment: Hashable
{
    public static func == (lhs: Payment, rhs: Payment) -> Bool {
        return lhs.token.id == rhs.token.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(token.id)
    }
}
