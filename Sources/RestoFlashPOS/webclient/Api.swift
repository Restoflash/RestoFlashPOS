//
//  Api.swift
//  RestoFlash
//
//  Created by Alexis Contour on 12/04/2023.
//

import Foundation


extension RestoFlashClient
{
    func initDevice(with editorInfo : EditorInfo, etablissement : Etablissement, devicePassword : DevicePassword, result : @escaping(Completion<String>)){
        let service = "/editor/\(editorInfo.editorLogin)/device/init"
        let params = InitDeviceParameters(siret:etablissement.siret,
                                          name: etablissement.name,
                                          phoneNumber: etablissement.phone,
                                          encodedPassword: devicePassword.encoded(),
                                          encodedImei: editorInfo.editorIMEI.urlBase64())
        self.request(with:.post, service:service, parameters: params, result:result)
    }
    

    func processPayment(with editor : EditorInfo, receiptReference : String,  token : Token, result : @escaping(Completion<Transaction>)){
        let service = "/pay/process/\(editor.editorLogin)"
        let paymentParameter = PaymentParameter(
            encodedToken: token.paymentKeyEncoded,
            amount: token.amount,
            acceptPartial: true,
            timestampInMsUTC: Int64(token.date.timeIntervalSince1970*1000) ,
            encodedSignature: nil,
            encodedImei: editor.editorIMEI.urlBase64(),
            encodedReference: receiptReference.urlBase64(),
            activityTime:nil)
        
        self.request(with:.post, service:service, parameters: paymentParameter, result:result)
    }
    
    func checkoutsToValidate(with editor : EditorInfo, result : @escaping((ApiResult<[Checkout]>) -> Void)) {
        let service = "/checkouts/\(editor.editorLogin)/\(editor.editorIMEI)"
        self.request(with: .get, service: service, parameters: nil, result: result)
    }
}
