//
//  RestoFlashClient.swift
//  RestoFlash
//
//  Created by Alexis Contour on 10/04/2023.
//

import Foundation
import Alamofire
//import Mocker

public class Credentials : Codable
{
    let login : String
    let password : String
    
    init(login : String, password : String)
    {
        self.login = login
        self.password = password
    }
}

extension Credentials
{
    class func create() -> Credentials
    {
        let login = UUID().uuidString
        let password = UUID().uuidString
        return Credentials(login: login, password: password)
    }
}

typealias DevicePassword = String

extension DevicePassword
{
    static func automatic() -> DevicePassword {
        return UUID().uuidString
    }
    func encoded() -> String {
        return self.urlBase64()
    }
}

class RestoFlashClient
{
    let endpoint : EndPoint
    let credential : Credentials
    let options : RestoFlashOptions
    private var _restoflashSession:Session?  = nil
    var restoflashSession : Session {
        get {
            if _restoflashSession == nil
            {
                _restoflashSession = createSession(options: self.options)
            }
            return _restoflashSession!
        }
    }
    
    func createSession(options : RestoFlashOptions) -> Session {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = options.networkRequestTimeout
        configuration.timeoutIntervalForResource = options.networkRequestTimeout
        options.customizeConfiguration?(configuration)
        //, interceptor: RetryPolicy(retryLimit:options.retryNetworkRequestCount)
        return Alamofire.Session(configuration: configuration)
    }
    
   

    init(endpoint : EndPoint, credential : Credentials, options : RestoFlashOptions = RestoFlashOptions.defaultOptions) {
        self.endpoint = endpoint
        self.credential = credential
        self.options = options
    }
    

    func request<T: Codable>(with method : HTTPMethod, service : String, parameters : Codable?, result : @escaping(Completion<T>))
    {
        let url : URLConvertible = self.endpoint.url.appendingPathComponent(service)
     //   let credential = URLCredential(user: self.credential.login, password: self.credential.password, persistence: URLCredential.Persistence.none)
        let credentialData = "\(self.credential.login):\(self.credential.password)".data(using:.utf8)!
        let base64Credentials = credentialData.base64EncodedString()
          
        let headers : HTTPHeaders = ["Authorization": "Basic \(base64Credentials)"]
        let dataRequest : DataRequest
        let curencyEncoder : JSONEncoder = JSONEncoder()
        curencyEncoder.moneyEncodingOptions = [.omitCurrency]
        let parameterEncoder : JSONParameterEncoder = JSONParameterEncoder(encoder: curencyEncoder)
        if let parameters = parameters {
            dataRequest = self.restoflashSession.request(url,  method: method,parameters: parameters, encoder:parameterEncoder, headers: headers)
        }
        else
        {
            dataRequest = self.restoflashSession.request(url,  method: method, headers: headers)
        }

        dataRequest
        //.authenticate(with: credential)
               .validate()
               .responseRestoflash(completionHandler: result)
               .cURLDescription { description in
                   print(description)
               }
            

    }
    
}

extension DataRequest {
    @discardableResult
    public func responseRestoflash<T: Codable>(queue: DispatchQueue = .main,
                                                dataPreprocessor: DataPreprocessor = DecodableResponseSerializer<T>.defaultDataPreprocessor,
                                                decoder: DataDecoder = JSONDecoder(),
                                                emptyResponseCodes: Set<Int> = DecodableResponseSerializer<T>.defaultEmptyResponseCodes,
                                                emptyRequestMethods: Set<HTTPMethod> = DecodableResponseSerializer<T>.defaultEmptyRequestMethods,
                                                completionHandler: @escaping (Completion<T>)) -> Self {
        
        
        let handler : (AFDataResponse<ApiResponse<T>>) -> Void = { afResponse in
            
            switch afResponse.result {
            case .success(let apiResponse):
                if(apiResponse.status == 0){
                    if let result = apiResponse.result {
                        completionHandler(.success(result))
                    }
                    else
                    {
                        completionHandler(.failure(.unexpected(error: "status = 0 but empty result")))
                    }
                }
                else
                {
                    //bad status
                    if (apiResponse.msg == "FUNCTIONAL_ERROR") {
                        
                        guard let apiErrorResponse = try? JSONDecoder().decode(ApiResponse<ApiError>.self, from: afResponse.data!), let apiError = apiErrorResponse.result else  {
                            completionHandler(.failure(RequestError.unexpected(error: "FUNCTIONAL_ERROR found but no api error")))
                            return
                        }
                        
                        completionHandler(.failure(RequestError.api(error: apiError)))
                    }
                    else {
                        completionHandler(.failure(RequestError.unexpected(error:apiResponse.msg)))
                    }
                    
                }
            case .failure(let afError):
                completionHandler(.failure(.http(error: afError)))
            }
            
            
        }
        
        return response(queue: queue,
                 responseSerializer: DecodableResponseSerializer<ApiResponse<T>>(dataPreprocessor: dataPreprocessor,
                                                                 decoder: decoder,
                                                                 emptyResponseCodes: emptyResponseCodes,
                                                                 emptyRequestMethods: emptyRequestMethods),
                 completionHandler: handler)
    }
    
}
