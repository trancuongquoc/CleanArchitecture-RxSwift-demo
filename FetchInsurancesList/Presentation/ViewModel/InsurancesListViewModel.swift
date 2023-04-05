    //
    //  InsurancesListViewModel.swift
    //
    //  Created by Cuong.tran on 06/10/2022.
    //

    import Foundation
    import RxSwift
    import RxCocoa

    final class InsurancesListViewModel: ViewModelType {
        struct Input {
            let location: AnyObserver<(String)>
            let pageCount: AnyObserver<(Int)>
        }
        
        struct Output {
            let insurancesList: Driver<InsuranceLists>
            let locationRawValue: BehaviorSubject<(String)>
            let pageCount: BehaviorSubject<(Int)>
            let error: Driver<Error>
        }
        
        private(set) var input: Input!
        private(set) var output: Output!
        
        private let locationRawValue = BehaviorSubject<(String)>(value: AppManager.shared.userLocation.rawValue)
        private let pageCount = BehaviorSubject<(Int)>(value: 1)
        private let error = PublishSubject<Error>()
        
        private let useCase: InsurancesListUseCase
        
        init(useCase: InsurancesListUseCase) {
            self.input = Input(location: locationRawValue.asObserver(), pageCount: pageCount.asObserver())
            
            self.useCase = useCase
            
            self.output = Output(insurancesList: buildInsurancesList(),
                                 locationRawValue: locationRawValue,
                                 pageCount: pageCount,
                                 error: error.asDriverOnErrorJustComplete())
        }
        
        private func buildInsurancesList() -> Driver<InsuranceLists> {
            let fetch = Observable.combineLatest(locationRawValue, pageCount)
            return (fetch.flatMapLatest { [weak self] location, pageNum in
                self?.useCase.fetchInsurancesList(pageCount: pageNum, country: location)
                    .catch({ [weak self] error in
                        self?.error.onNext(error)
                        return Observable.empty()
                    }) ?? Observable.empty()
            }).asDriverOnErrorJustComplete()
        }
}
