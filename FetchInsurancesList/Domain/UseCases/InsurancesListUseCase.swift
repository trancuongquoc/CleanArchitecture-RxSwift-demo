//
//  InsurancesListUseCase.swift
//
//  Created by Cuong.tran on 06/10/2022.
//

import Foundation
import RxSwift
protocol InsurancesListUseCase {
    func fetchInsurancesList(pageCount: Int, country: String) -> Observable<InsuranceLists>
}
