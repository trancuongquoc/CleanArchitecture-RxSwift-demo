//
//  InsurancesListRepository.swift
//
//  Created by Cuong.tran on 06/10/2022.
//

import RxSwift
protocol InsurancesListRepository {
    func fetchInsurancesList(pageCount: Int, country: String) -> Observable<InsuranceLists>
}

final class DefaultInsurancesListRepository: InsurancesListRepository {
    func fetchInsurancesList(pageCount: Int, country: String) -> Observable<InsuranceLists> {
        AppManager.shared.dataAdapter.fetchInsurancesList(pageCount: pageCount, country: country)
    }
}
