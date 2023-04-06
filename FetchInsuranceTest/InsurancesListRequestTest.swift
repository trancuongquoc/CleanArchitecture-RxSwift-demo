//
//  InsurancesListTest.swift
//  DAWPatientTests
//
//  Created by Quoc Cuong on 01/03/2023.
//  Copyright © 2023 Doctor Anywhere. All rights reserved.
//

import XCTest
@testable import DAWPatient

class InsurancesListTest: XCTestCase {

    func testInsurancesListRequests() {
        let userLocation = UserLocation.sg.rawValue
        let fetchRequestInfo = InsuranceRequest.fetchInsuranceList(pageCount: 0, country: userLocation).requestInfo()
        print(fetchRequestInfo.url)
        XCTAssertEqual(fetchRequestInfo.url, "https://da-api.dranywhere-dev.com/v1/insurance/membership/insurance-lists?page=0&size=\(Request.pageSize())&country=\(userLocation)")
        XCTAssertEqual(fetchRequestInfo.method, .get)
    }
}
