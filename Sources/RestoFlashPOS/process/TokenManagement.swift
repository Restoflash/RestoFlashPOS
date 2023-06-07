//
//  TokenManagement.swift
//  RestoFlash
//
//  Created by Alexis Contour on 26/04/2023.
//

import Foundation


struct TokenManagement {
    static let shared = TokenManagement()
    let dateFormatter = DateFormatter()

    init() {
        dateFormatter.dateFormat = "yyyyMMddHHmm"
    }
}



