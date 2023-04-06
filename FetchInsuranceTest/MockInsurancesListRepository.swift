//
//  MockInsurancesListRepository.swift
//  DAWPatientTests
//
//  Created by Quoc Cuong on 01/03/2023.
//  Copyright © 2023 Doctor Anywhere. All rights reserved.
//

import Foundation
import RxSwift

@testable import DAWPatient

class MockInsurancesListRepository: InsurancesListRepository {
    enum MockDataCase {
        case fetchInsurancesListError
        case fetchInsurancesListSuccess
    }
    
    var dataCase: MockDataCase = .fetchInsurancesListError
        
    func fetchInsurancesList(pageCount: Int, country: String) -> Observable<InsuranceLists> {
        switch dataCase {
        case .fetchInsurancesListError:
            return Observable.error(NSError(domain: "Test Error case 1", code: -1))
        default:
            let data = InsurancesListMockedData.insurances_list_MockedData
            do {
                let insurancesList = try InsuranceLists(data: data)
                return Observable.just(insurancesList)
            } catch {
                print(error)
                return Observable.error(NSError(domain: "Test Error case 2", code: -2))
            }
        }
    }
}
