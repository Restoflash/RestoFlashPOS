//
//  ApiError.swift
//  RestoFlash
//
//  Created by Alexis Contour on 10/04/2023.
//

import Foundation

import Alamofire

public enum RequestError : Error{
    case http(error : AFError) // cannot reach server
    case api(error : ApiError)  // server send an error
    case unexpected( error : Error)
}

extension RequestError : LocalizedError {
    public var errorDescription: String? {
        switch self{
        case .http(let error):
            return error.errorDescription
        case .api(let error):
            return error.errorDescription
        case .unexpected( let error):
            return error.localizedDescription
        }

    }
    public var failureReason: String? {
        switch self{
        case .http(let error):
            return error.failureReason
        case .api(let error):
            return error.failureReason
        case .unexpected( let error):
            return error.localizedDescription
        }
    }
}

enum ErrorCode: Int, Codable {
    case protocolError = 1001 //erreur signature etc..
    case wrongKey = 2000 //  Code SCO, QR ou autre incorrect. ( inclus les cas de double présentation, inconnu, faux etc)
    case wrongAffiliate = 2001 // Pour les modes où le benef choisit le restau et se trompe
    case lowBalance = 2002 // Pas de solde pour couvrir la demande ( en partial ou alors si plus de solde du tout )
    var id: Int {
        return self.rawValue
    }
    
}

public struct ApiError: Codable, LocalizedError {
    let code: ErrorCode
    let message: String

    public var errorDescription: String? {
        return message
    }

    public var failureReason: String? {
        return "Error " + String(code.id) + " : " + message
    }
}

extension String : LocalizedError
{
    public var errorDescription: String? {
        return self
    }
    public var  failureReason: String? {
        return self
    }
}
