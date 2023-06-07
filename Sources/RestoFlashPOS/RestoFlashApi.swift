//
//  RestoFlashApi.swift
//  RestoFlash
//
//  Created by Alexis Contour on 28/04/2023.
//

import Foundation
import Disk

public class RestoFlashApi {

    let editorInfo: EditorInfo
    var standardApiClient: RestoFlashClient? = nil
    var editorClient: RestoFlashClient? = nil
    let endpoint: EndPoint
    let options: RestoFlashOptions

    public init(with editorInfo: EditorInfo, endpoint: EndPoint, options: RestoFlashOptions = RestoFlashOptions.defaultOptions) {
        let savedEditorInfo = try? Disk.retrieve(resourceNames.editodInfo.rawValue, from: .applicationSupport, as: EditorInfo.self)
        if editorInfo != savedEditorInfo {
            try? RestoFlashApi.deletePOSCredentials()
            try? RestoFlashApi.saveEditorInfo(editorInfo)
        }
        self.editorInfo = editorInfo
        self.endpoint = endpoint
        self.options = options
        if let posCredentials = RestoFlashApi.loadPOSCredentials() {
            standardApiClient = RestoFlashClient(endpoint: endpoint, credential: posCredentials, options: options)
        }
    }

    var isPOSInitialized: Bool {
        return RestoFlashApi.loadPOSCredentials() != nil
    }

    func registerPOS(etablissement: Etablissement, posPassword: DevicePassword = DevicePassword.automatic(), completion: @escaping (Completion<Credentials>)) {
        let editorCredentials = editorInfo.credentials
        editorClient = RestoFlashClient(endpoint: self.endpoint, credential: editorCredentials, options: self.options)
        editorClient!.initDevice(with: editorInfo, etablissement: etablissement, devicePassword: posPassword) { result in
            switch result {
            case .success(let loginPos):
                let posCredential: Credentials
                do {
                    posCredential = Credentials(login: loginPos, password: posPassword)
                    try RestoFlashApi.savePOSCredentials(posCredential)
                    self.standardApiClient = RestoFlashClient(endpoint: self.endpoint, credential: posCredential, options: self.options)
                } catch {
                    completion(.failure(.unexpected(error: error)))
                    return
                }
                completion(.success(posCredential))
            case .failure(let error):
                completion(.failure(error))
            }

        }
    }
    
    func downloadCheckouts(result: @escaping(Completion<[Checkout]>)){
        self.standardApiClient?.checkoutsToValidate(with: self.editorInfo, result: result)
    }


    func processPayment(receiptReference: String, token: Token, result: @escaping(Completion<Transaction>)) {
        print("processPayment receiptReference:\(receiptReference) token:\(token) from \(token.userName) with amount \(token.amount)")
        standardApiClient?.processPayment(with: editorInfo, receiptReference: receiptReference, token: token, result: result)
     
    }
}


extension RestoFlashApi {
    public enum resourceNames : String {
        case editodInfo = "rf_editorInfo"
        case posCredentials = "rf_posCredentials"
        case etablissement = "rf_etablissement"
    }
    static func loadPOSCredentials() -> Credentials? {
        return try? Disk.retrieve(resourceNames.posCredentials.rawValue, from: .applicationSupport, as: Credentials.self)
    }
    static func savePOSCredentials(_ credentials : Credentials) throws {
        try Disk.save(credentials, to: .applicationSupport, as: resourceNames.posCredentials.rawValue)
    }
    static func deletePOSCredentials() throws {
        try Disk.remove(resourceNames.posCredentials.rawValue, from: .applicationSupport)
    }

    static func loadEditorInfo() -> EditorInfo? {
        return try? Disk.retrieve(resourceNames.editodInfo.rawValue, from: .applicationSupport, as: EditorInfo.self)
    }
    static func saveEditorInfo(_ editorInfo : EditorInfo) throws {
        try Disk.save(editorInfo, to: .applicationSupport, as: resourceNames.editodInfo.rawValue)
    }

    static func loadEtablissement() -> Etablissement? {
        return try? Disk.retrieve(resourceNames.etablissement.rawValue, from: .applicationSupport, as: Etablissement.self)
    }
    static func saveEtablissement(_ etablissement : Etablissement) throws {
        try Disk.save(etablissement, to: .applicationSupport, as: resourceNames.etablissement.rawValue)
    }
}
