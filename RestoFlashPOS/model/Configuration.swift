//
//  EditorConfiguration.swift
//  RestoFlash
//
//  Created by Alexis Contour on 11/04/2023.
//

import Foundation

public struct EditorInfo : Codable{
    let editorLogin : String
    let editorPassword : String
    let editorIMEI: String
    let issuerId : String
    
    var credentials : Credentials {
        get {
            return Credentials(login: editorLogin, password: editorPassword)
        }
    }

    public init(editorLogin : String, editorPassword : String, editorIMEI: String, issuerId : String) {
        self.editorLogin = editorLogin
        self.editorPassword = editorPassword
        self.editorIMEI = editorIMEI
        self.issuerId = issuerId
    }
}

extension EditorInfo
{
    public static func fromJSON(json : Data) throws -> EditorInfo  {
        return try JSONDecoder().decode(EditorInfo.self, from: json)
    }
    public static func fromJSON(json : String) throws -> EditorInfo {
        let data = json.data(using: .utf8)!
        return try fromJSON(json: data)
    }
    public static func fromJSON(jsonName : String) throws -> EditorInfo {
        guard let resourcePath = Bundle.main.path(forResource: jsonName, ofType: "json") else {throw "cannot find resource \(jsonName).json"}
        guard let data = FileManager.default.contents(atPath: resourcePath) else {throw "cannot read resource \(jsonName).json"}
        return try fromJSON(json: data)
    }
    public static func fromPlist(plistName : String) throws -> EditorInfo {
        guard let resourcePath = Bundle.main.path(forResource: plistName, ofType: "plist") else {throw "cannot find resource \(plistName).plist"}
        guard let data = FileManager.default.contents(atPath: resourcePath) else {throw "cannot read resource \(plistName).plist"}
        return try PropertyListDecoder().decode(EditorInfo.self, from: data)
    }
}


extension EditorInfo : Equatable
{
    public static func ==(lhs: EditorInfo, rhs: EditorInfo) -> Bool {
        return lhs.editorLogin == rhs.editorLogin &&
            lhs.editorPassword == rhs.editorPassword &&
            lhs.editorIMEI == rhs.editorIMEI &&
            lhs.issuerId == rhs.issuerId
    }
}

public typealias Siret = String

protocol EtablissementInfo {}

public struct Etablissement : EtablissementInfo, Equatable, Codable {
    let siret : Siret
    let name: String
    let phone : String
    public static func ==(lhs: Etablissement, rhs: Etablissement) -> Bool {
        return lhs.siret == rhs.siret &&
               lhs.name == rhs.name &&
               lhs.phone == rhs.phone
    }
    public init(siret : Siret, name:String="", phone:String="") {
        self.siret = siret
        self.name = name
        self.phone = phone
    }
}


struct Address:EtablissementInfo, Equatable, Codable {
    
    let name: String
    let addressNumber: String
    let addressStreet: String
    let zipCode: String
    let town: String
    let phone: String
    let webSite: String
    let email: String
    
    static func ==(lhs: Address, rhs: Address) -> Bool {
        return lhs.name == rhs.name &&
        lhs.addressNumber == rhs.addressNumber &&
        lhs.addressStreet == rhs.addressStreet &&
        lhs.zipCode == rhs.zipCode &&
        lhs.town == rhs.town &&
        lhs.phone == rhs.phone &&
        lhs.webSite == rhs.webSite &&
        lhs.email == rhs.email
    }

    init(name:String, addressNumber:String?, addressStreet:String?, zipCode:String?, town:String?, phone:String?, webSite:String?, email:String?) {
        self.name = name
        self.addressNumber = addressNumber ?? ""
        self.addressStreet = addressStreet ?? ""
        self.zipCode = zipCode ?? ""
        self.town = town ?? ""
        self.phone = phone ?? ""
        self.webSite = webSite ?? ""
        self.email = email ?? ""
    }
}






