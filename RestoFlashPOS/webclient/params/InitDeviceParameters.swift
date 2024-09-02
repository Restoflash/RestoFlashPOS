//
//  InitDeviceParameters.swift
//  RestoFlash
//
//  Created by Alexis Contour on 12/04/2023.
//

import Foundation


struct InitDeviceParameters: Codable {
    var apiKey: String = ""
    var sponsorshipKey: String = ""
    var siret: String = ""
    var name: String = ""
    var addressNumber: String = ""
    var addressStreet: String = ""
    var zipCode: String = ""
    var town: String = ""
    var phoneNumber: String = ""
    var webSite: String = ""
    var userName: String = ""
    var encodedPassword: String
    var encodedImei: String
    var email: String = ""
}
