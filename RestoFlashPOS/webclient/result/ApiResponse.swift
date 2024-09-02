//
//  ApiResponse.swift
//  RestoFlash
//
//  Created by Alexis Contour on 10/04/2023.
//

import Foundation


public struct ApiResponse<T: Codable>: Codable {
    var status: Int
    var msg: String
    var result: T?
    
    public static func createResponse(with result : T) -> ApiResponse<T>{
        return ApiResponse(status: 0, msg: "", result: result)
    }
}

extension ApiResponse : CustomStringConvertible
{
    public var description: String  {
        get {
            return "ApiResponse [status= \(status), msg= \(msg), result=\(String(describing: result))]";
        }
    }
}


