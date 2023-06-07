//
//  Error.swift
//  RestoFlash
//
//  Created by Alexis Contour on 26/04/2023.
//

import Foundation
import Alamofire

public enum TokenError : Error
 {
     case qrBadSyntaxException(String)
 }
public enum RestoFlashError : Error
{
    case apiError(ApiError) //error sent by Resto Flash Server
    case networkError(AFError)
}


extension RestoFlashError : LocalizedError
{
    public var errorDescription: String? {
        get {
            switch self
            {
                
            case .apiError(let error):
                return error.errorDescription
            case .networkError(let error):
                return error.errorDescription
                /*case .tokenError(let error):
                 switch error {
                 case .qrBadSyntaxException(let description):
                 return description
                 }
                 }*/
            }
        }
    }

   
}
