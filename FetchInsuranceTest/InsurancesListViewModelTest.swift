//
//  InsurancesListViewModel.swift
//  DAWPatientTests
//
//  Created by Quoc Cuong on 01/03/2023.
//  Copyright © 2023 Doctor Anywhere. All rights reserved.
//

import XCTest
import RxSwift

@testable import DAWPatient

class InsurancesListViewModelTest: BaseTestCase {
    var viewModel: InsurancesListViewModel!
    var mockRepository: MockInsurancesListRepository!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockInsurancesListRepository()
    }
    
    func testInsurancesListSuccess() {
        mockRepository.dataCase = .fetchInsurancesListSuccess
        viewModel = InsurancesListViewModel(useCase: DefaultInsurancesListUseCase(repository: mockRepository))

        let insurancesList = scheduler.createObserver(InsuranceLists.self)
        let error = scheduler.createObserver(Error.self)
        
        viewModel.output.error
            .drive(error)
            .disposed(by: disposeBag)
        
        viewModel.output.insurancesList
            .drive(insurancesList)
            .disposed(by: disposeBag)
                
        scheduler.start()
        
        XCTAssertEqual(error.events.count, 0)
        XCTAssertEqual(insurancesList.events.first?.value.element?.total, 3)
        XCTAssertEqual(insurancesList.events.first?.value.element?.insurances?.first?.name, "Allianz Corporate Programme")
    }
    
    func testInsurancesListError() {
        mockRepository.dataCase = .fetchInsurancesListError
        viewModel = InsurancesListViewModel(useCase: DefaultInsurancesListUseCase(repository: mockRepository))

        let insurancesList = scheduler.createObserver(InsuranceLists.self)
        let error = scheduler.createObserver(Error.self)
        
        viewModel.output.error
            .drive(error)
            .disposed(by: disposeBag)
        
        viewModel.output.insurancesList
            .drive(insurancesList)
            .disposed(by: disposeBag)
                    
        scheduler.start()
                
        XCTAssertEqual(error.events.count, 1)
        XCTAssertEqual(insurancesList.events.count, 0)
    }
}
