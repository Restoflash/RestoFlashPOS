//
//  RestoFlashOptions.swift
//  RestoFlash
//
//  Created by Alexis Contour on 28/04/2023.
//

import Foundation


public struct RestoFlashOptions
{
    public static var defaultOptions : RestoFlashOptions = RestoFlashOptions()
    public var networkRequestTimeout : TimeInterval  // seconds
    public var retryNetworkRequestCount : UInt
    public var mockServerResponse = false
    public var customizeConfiguration : ((URLSessionConfiguration) -> ())? = nil

    init( networkRequestTimeout : TimeInterval = 5.0 , retryNetworkRequestCount: UInt = 2){
        self.networkRequestTimeout = networkRequestTimeout
        self.retryNetworkRequestCount = retryNetworkRequestCount
    }
    
}

