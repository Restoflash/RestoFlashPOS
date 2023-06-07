//
//  sample_data.swift
//  RestoFlash
//
//  Created by Alexis Contour on 06/05/2023.
//

import Foundation
import Money
public let checkouts_list_data = """
[
{
    "id": 1,
    "userName": "John Doe",
    "date": 1573662324368,
    "amount": 12.20,
    "reference": "TABLE 11",
    "sponsorshipKey": "1234",
    "issuer": 1,
    "topUpAmount": 10.00
},
{
    "id": 2,
    "userName": "Alex Legrand",
    "date": \(1573662324368 - 86400),
    "amount": 5.00,
    "reference": "TABLE 11",
    "sponsorshipKey": "5678",
    "issuer": 1,
    "topUpAmount": 5.00
},
{
    "id": 3,
    "userName": "Alice Gerard",
    "date": \(Int64(Date().timeIntervalSince1970)*1000),
    "amount": 19.51,
    "reference": "",
    "sponsorshipKey": "9100",
    "issuer": 1,
    "topUpAmount": null
}
]
""".data(using: .utf8)!



