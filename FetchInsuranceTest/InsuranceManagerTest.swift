//
//  InsuranceManagerTest.swift
//  DAWPatientTests
//
//  Created by Le Trung Thu on 2/1/23.
//  Copyright © 2023 Doctor Anywhere. All rights reserved.
//

import Foundation
import XCTest
import RxSwift
import Mocker

@testable import DAWPatient

class InsuranceManagerTest : BaseTestCase {
    
    func testUpdateInsuranceMembership(){
        // Create an expectation for an asynchronous task.
        let expectation = XCTestExpectation(description: "call api updateInsuranceMembership asynchronously.")

        
        useMockNetworkLayer()
        
        //{"insuranceType":"CIGNA","country":"SG","isMain":true,"policyNumber":"S000816","productCode":null,"label":null}
        
        let insuranceType = "CIGNA"
        let country = "SG"
        let isMain = true
        let policyNumber = "S000823167"
            
        let rq = Request.updateInsuranceMembership(insuranceType: insuranceType, country: country, isMain: isMain, policyNumber: policyNumber).execute().convertible.urlRequest
        
        let apiURL = URL(string: rq?.url?.absoluteString)!
                
        let mockedResponse = InsuranceMockedData.updateInsuranceMembershipResponseMockedData
        
        //mock api data, use Mocker
        let mock = Mock(url: apiURL, dataType: .json, statusCode: 200, data: [.post: mockedResponse])
        mock.register()

        AppManager.shared.insuranceManager.updateInsuranceMembership(insuranceType: insuranceType,
                                                                     country: country,
                                                                     policyNumber: policyNumber,
                                                                     isMain: isMain) { result in
            print("\(result)")
            
            switch result {
            case .success:
                expectation.fulfill()
            case .failure:
                print("fail test for updateInsuranceMembership")
            }
        }
                
        // Wait for the expectation to fulfill or time out.
        wait(for: [expectation], timeout: 3.0)
    }
}
