//
//  RestoFlashClientTests.swift
//  RestoFlashTests
//
//  Created by Alexis Contour on 16/05/2023.
//

import Foundation
import Mocker
import Disk
import XCTest
@testable import RestoFlashPOS

final class RestoFlashClientTests: XCTestCase {
    var editorInfo : EditorInfo?
    var options : RestoFlashOptions?
    var rfApi : RestoFlashApi?
    
    override func setUpWithError() throws {
         editorInfo = EditorInfo(
            editorLogin: "1000003",
            editorPassword: "API",
            editorIMEI : "TEST_MODULES",
            issuerId: "1"
        )
        options = RestoFlashOptions.defaultOptions
        options!.customizeConfiguration = { config in
            config.protocolClasses = [MockingURLProtocol.self] + (config.protocolClasses ?? [])
        }
        rfApi = RestoFlashApi(with: editorInfo!, endpoint: .custom(url: "https://server.com"), options: options!)
    }

    override func tearDownWithError() throws {
        do {
            try Disk.clear(.applicationSupport)
        } catch {
            
            fatalError(error.localizedDescription)
        }
            
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testInitDevice() throws {
    
        let etablissement = Etablissement(siret: "50521816400018", name:"4 Pat")
        let posCredential : DevicePassword = "password"
        let requestExpectation = expectation(description: "Request should finish")
    
        let serverData = try! JSONEncoder().encode(ApiResponse.createResponse(with:  "abcd"))
        
        //let responce =
        let mock = Mock(url: URL(string:"https://server.com/editor/\(self.editorInfo!.editorLogin)/device/init")!, dataType: .json, statusCode: 200, data: [.post: serverData])
        mock.register()

        
        self.rfApi!.registerPOS(etablissement: etablissement, posPassword: posCredential) { result in
            switch(result){
            case .success(let posCredential):
                print(posCredential.login)
                XCTAssert(posCredential.login == "abcd")
                requestExpectation.fulfill()
            case .failure(let error ):
                XCTFail(error.errorDescription!)
                requestExpectation.fulfill()
            }
        }
        wait(for: [requestExpectation], timeout: 10.0)
        XCTAssert(Disk.exists(RestoFlashApi.resourceNames.posCredentials.rawValue, in: .applicationSupport))
    }
    
    func testDeserialize() throws{
        let text = """
        {\"status\":0,\"msg\":\"\",\"result\":{\"id\":\"25055\",\"is\":\"1\",\"totalAmount\":11.15,\"product\":\"1\",\"productAmount\":11.15,\"topUpAmount\":0.00,\"loginPos\":\"19037\",\"scanTime\":1684956620757000,\"reference\":\"6AF2572E\",\"ben\":\"RF T.\",\"company\":\"GreenPay\"}}
        """.data(using: .utf8)!

        XCTAssertNoThrow(try JSONDecoder().decode(ApiResponse<Transaction>.self, from: text))

    }

}
