//
//  EndPoint.swift
//  RestoFlash
//
//  Created by Alexis Contour on 10/04/2023.
//

import Foundation

public enum EndPoint{

    case test
    case prod
    case demo
    case custom(url : String)

    var url : URL
    {
        switch self {
        case .test:
            return URL(string:"https://preapi.restoflash.fr")!
        case .prod:
            return URL(string:"https://api.restoflash.fr")!
        case .demo:
            return URL(string:"https://demoapi.restoflash.fr")!
        case .custom(let url):
            return URL(string:url)!
        
        }
    }
}
