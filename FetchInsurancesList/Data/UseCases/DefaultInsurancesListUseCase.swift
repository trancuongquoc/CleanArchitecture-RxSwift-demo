//
//  DefaultInsurancesListUseCase.swift
//
//  Created by Cuong.tran on 06/10/2022.
//

import RxSwift

final class DefaultInsurancesListUseCase: InsurancesListUseCase {
    private let repository: InsurancesListRepository
    
    public init(repository: InsurancesListRepository) {
        self.repository = repository
    }
    
    func fetchInsurancesList(pageCount: Int, country: String) -> Observable<InsuranceLists> {
        return repository.fetchInsurancesList(pageCount: pageCount, country: country)
    }
}
