//
//  InsurancesList.swift
//  DAWPatientTests
//
//  Created by Quoc Cuong on 05/03/2023.
//  Copyright © 2023 Doctor Anywhere. All rights reserved.
//

import Foundation
import XCTest
import RxSwift

@testable import DAWPatient

class InsuranceListTest: BaseTestCase {
    
    func testInsurancesList() {
        let mockedData = InsurancesListMockedData.insurances_list_MockedData
        XCTAssertNoThrow(try InsuranceLists(data: mockedData))
    }
}
