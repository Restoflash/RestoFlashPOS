//
//  ApiResult.swift
//  RestoFlash
//
//  Created by Alexis Contour on 10/04/2023.
//

import Foundation

public enum ApiResult<T> {
    case success(T)
    case failure(RequestError)
}

public typealias Completion<T>  = (ApiResult<T>) -> Void
