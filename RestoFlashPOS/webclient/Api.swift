//
//  Api.swift
//  RestoFlash
//
//  Created by Alexis Contour on 12/04/2023.
//

import Foundation


extension RestoFlashClient
{
    
    func initDevice(with editorInfo : EditorInfo, etablissement : Etablissement, devicePassword : DevicePassword, result : @escaping((ApiResult<String>) -> Void)){
        let service = "/editor/\(editorInfo.editorLogin)/device/init"
        let params = InitDeviceParameters(siret:etablissement.siret,
                                          name: etablissement.name,
                                          phoneNumber: etablissement.phone,
                                          encodedPassword: devicePassword.encoded(),
                                          encodedImei: editorInfo.editorIMEI.urlBase64())
        self.request(with:.post, service:service, parameters: params, result:result)
    }
    
    
    /*
     
     //java
     private PaymentParameter createPaymentParameterFromConfig(String basketReference, BigDecimal amountToPay, String token,
                                                                  long timestampInMs, boolean acceptPartial) {
            PaymentParameter paymentParameter = new PaymentParameter();
            paymentParameter.setAmount(amountToPay);
            paymentParameter.setEncodedToken(Base64.encodeToutf8StringUrlSafeNoWrap(token));
            paymentParameter.setAcceptPartial(acceptPartial);
            paymentParameter.setTimestampInMsUTC(timestampInMs);
            paymentParameter.setActivityTime(timestampInMs);
            paymentParameter.setEncodedImei(encodedImei);

            String encodedReference = Base64.encodeToutf8StringUrlSafeNoWrap(basketReference);
            String dataToSign = Divers.buildSignedData(imei, basketReference, String.valueOf(timestampInMs),
                    Divers.toCents(amountToPay));

            paymentParameter.setEncodedReference(encodedReference);
            paymentParameter.setEncodedSignature(sign(dataToSign));

            return paymentParameter;
        }
     @POST("/pay/process/{editorId}.json")
     void processPayment(@Path(value = "editorId", encode = false) String editorId,
                                             @Body PaymentParameter paymentParameter,Callback<ApiResponse<Transaction>> responseCallback);


     */
    func processPayment(with editor : EditorInfo, receiptReference : String,  token : Token, result : @escaping((ApiResult<Transaction>) -> Void)){
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
    
    /*
     @GET("/checkouts/{editorId}/{encodedImei}.json")
         void checkoutsToValidate(@Path(value = "editorId", encode = false) String editorId,
                                  @Path(value = "encodedImei", encode = false) String encodedImei,
                                            Callback<ApiResponse<List<Checkout>>> responseCallback);
     */

    func checkoutsToValidate(with editor : EditorInfo, result : @escaping((ApiResult<[Checkout]>) -> Void)) {
        let service = "/checkouts/\(editor.editorLogin)/\(editor.editorIMEI)"
        self.request(with: .get, service: service, parameters: nil, result: result)
    }
}
