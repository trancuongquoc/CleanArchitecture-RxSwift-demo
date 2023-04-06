//
//  DefaultInsurancesListRepositoryTest.swift
//  DAWPatientTests
//
//  Created by Quoc Cuong on 01/03/2023.
//  Copyright © 2023 Doctor Anywhere. All rights reserved.
//

import Foundation
import XCTest
import RxSwift
import Mocker

@testable import DAWPatient

class DefaultInsurancesListRepositoryTest: BaseTestCase {
    var defaultRepository: DefaultInsurancesListRepository!
    
    override func setUp() {
        super.setUp()
        defaultRepository = DefaultInsurancesListRepository()
    }
    
    func testDefaultInsurancesListAPI_with_network_layer_Mock() {
        useMockNetworkLayer()
        
        let rq = InsuranceRequest.fetchInsuranceList(pageCount: 1, country: "SG").requestInfo()
        
        let fetchTrigger = PublishSubject<(Int, String)>()
        let result = scheduler.createObserver(InsuranceLists.self)
                
        let apiURL = URL(string: rq.url)!
                
        let response = InsurancesListMockedData.insurances_list_MockedData
        
        //mock api data, use Mocker
        let mock = Mock(url: apiURL, dataType: .json, statusCode: 200, data: [.get: response])
        mock.register()
        
        scheduler
            .createColdObservable([.next(2, (1, "SG"))])
            .bind(to: fetchTrigger)
            .disposed(by: disposeBag)
        
        let obser = fetchTrigger.flatMap { (page, location) in
            self.defaultRepository.fetchInsurancesList(pageCount: page, country: location)
        }
        
        obser.asDriverOnErrorJustComplete().drive(result).disposed(by: disposeBag)
        
        scheduler.start()
        
        //delay or wait for asyn tasks. due to we are mocking network layer (Alamofire request)
        delay(2)
        
        //make sure have data response
        XCTAssertEqual(result.events.count, 1)
        XCTAssertEqual(result.events[0].value.element?.total, 3)
        XCTAssertEqual(result.events[0].value.element?.insurances?.first?.name, "Allianz Corporate Programme")
    }
    
}
