//
//  InsuranceTypeViewController.swift
//
//  Created by Quoc Cuong on 27/02/2023.
//
import RxSwift
import UIKit
import RxDataSources

private struct InsuranceSection {
    var header: String
    var items: [Insurance]
}

extension InsuranceSection: SectionModelType {
    typealias Item = Insurance
    
    var identity: String {
        return header
    }
    
    init(original: InsuranceSection, items: [Item]) {
        self = original
        self.items = items
    }
}

class InsuranceTypeViewController: GenericViewViewController<InsuranceChoicesView> {
    var viewModel: InsurancesListViewModel
    
    private let router: InsuranceRouter = DefaultInsuranceRouter.create()

    fileprivate lazy var dataSource: RxTableViewSectionedReloadDataSource<InsuranceSection> = {
        let dataSource = RxTableViewSectionedReloadDataSource<InsuranceSection>(
            configureCell: { [weak self] dataSource, tableView, indexPath, item in
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "InsuranceTableViewCell", for: indexPath) as? InsuranceTableViewCell else { return UITableViewCell() }
                cell.insurance = item
                
                if let self = self {
                    self.numberOfRows = self.dataSource.tableView(self.myView.tableView, numberOfRowsInSection: 0)
                    cell.seperator.isHidden = (indexPath.row == (self.numberOfRows - 1))
                }
                
                return cell
            })
        return dataSource
    }()
    
    var selectedInsurance: Insurance?
    var numberOfRows = 0
    var totalInsurancesCount = 0
    
    let dataAdapter = AppManager.shared.dataAdapter
    let settings = AppManager.shared
    var visual = UIVisualEffectView()
        
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
                                    #selector(handleRefresh(_:)),
                                 for: UIControl.Event.valueChanged)
        return refreshControl
    }()
    
    init() {
        viewModel = InsurancesListViewModel(useCase: DefaultInsurancesListUseCase(repository: DefaultInsurancesListRepository()))
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        viewModel = InsurancesListViewModel(useCase: DefaultInsurancesListUseCase(repository: DefaultInsurancesListRepository()))
        super.init(coder: coder)
    }

    /// Handles pull to refresh action
    @objc
    func handleRefresh(_ refreshControl: UIRefreshControl) {
        let dataAdapter = AppManager.shared.dataAdapter
        guard dataAdapter.isReachable else {
            perform(#selector(stopRefresh), with: nil, afterDelay: 0.1)
            return
        }
        resetPageCountIfNeeded()
    }
    
    func resetPageCountIfNeeded() {
        do {
            let pageNum = try self.viewModel.output.pageCount.value()
            guard pageNum != 1 else {
                if self.refreshControl.isRefreshing {
                    self.stopRefresh()
                }
                return
            }
            viewModel.input.pageCount.onNext(1)
        } catch {
            print(error)
        }
    }
    
    /// Stops pull to refresh animation
    @objc
    func stopRefresh() {
        refreshControl.endRefreshing()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MixpanelTracker.trackEvent(EventNames.screenView, properties: ["screenName": ScreenNames.insuranceList.rawValue])
        myView.delegate = self

        setupNavBar()
        setupTableView()
        bindOutput()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }

    func setupNavBar() {
        self.updateNavBarWithPrimaryColor()
        self.setUpGreenBackButton(#selector(pop))
        self.setUpCrossButton(#selector(cancelTapped(sender:)))
    }

    func setupTableView() {
        myView.tableView.refreshControl = refreshControl
        myView.tableView.clipsToBounds = true
        myView.tableView.dataSource = nil
        myView.tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        myView.tableView.rx.modelSelected(Insurance.self)
            .subscribe(onNext: { [weak self] model in
                guard let self = self else { return }
                self.selectedInsurance = model
                self.handleTapAtInsurance(at: model)
            }).disposed(by: disposeBag)
        
         _ = self.viewModel.output.insurancesList
            .asObservable()
            .subscribe(onNext: { [weak self] list in
                if self?.refreshControl.isRefreshing ?? true {
                    self?.stopRefresh()
                }

                guard let self = self else { return }
                
                self.totalInsurancesCount = list.total ?? 0
            }).disposed(by: disposeBag)
        
        myView.tableView.rx
            .willDisplayCell
            .subscribe(onNext: { [weak self] cell, indexPath in
                guard let self = self else { return }
                                
                if self.numberOfRows < self.totalInsurancesCount && indexPath.row == (self.numberOfRows - 1) {
                    do {
                        let pageNum = try self.viewModel.output.pageCount.value()
                        self.viewModel.input.pageCount.onNext(pageNum + 1)
                    } catch {
                        print(error)
                    }
                }
                
                if indexPath.row == 0 {
                    cell.roundCorners([.topLeft, .topRight], radius: 10)
                } else if indexPath.row == self.numberOfRows - 1 {
                    cell.roundCorners([.bottomLeft, .bottomRight], radius: 10)
                }
            })
            .disposed(by: disposeBag)
    }

    func bindOutput() {
        viewModel.output.insurancesList.map { [InsuranceSection(header: "Insurances", items: $0.insurances ?? [])] }
        .drive(myView.tableView.rx.items(dataSource: dataSource))
        .disposed(by: disposeBag)
        
        viewModel.output.error.drive { error in
            Utility.showAlert(message: error.localizedDescription)
        }.disposed(by: disposeBag)

        viewModel.output.locationRawValue.map({ location in
            NSAttributedString(string: UserLocation(rawValue: location)?.getCountryName() ?? "",
                               attributes: [.kern: 0.2,
                                            .paragraphStyle: NSMutableParagraphStyle(),
                                            .font: AppFont.primaryFontSemiBold16])
        }).bind(to: myView.locationNameLbl.rx.attributedText)
                          .disposed(by: disposeBag)
    }
    
    @objc
    func cancelTapped(sender: Any) {
        router.popToBeginningScreen(animated: true)
    }
    
    @objc
    func backAction() {
        router.pop()
    }
    
    func handleTapAtInsurance(at insurance: Insurance) {
        MixpanelTracker.trackEvent(EventNames.insurerSelected, screenName: "InsuranceProviderList", properties: [:])
        
        guard let type = insurance.type else {return}
        let insuranceType = InsurerType.fetchInsurerType(value: type)
        
        if AppManager.shared.userLocation == .sg || (AppManager.shared.userLocation == .th && insuranceType != .cignaLHB) {
            if let view = navigationController?.view {
                visual = Utility.showVisualEffect(view: view)
            }
            router.presentConsentTermsView(controller: self)
            return
        }
        
        moveNext(with: insurance)
    }
    
    func moveNext(with insurance: Insurance) {
        do {
            let locationStr = try viewModel.output.locationRawValue.value()
            guard let userLocation = UserLocation(rawValue: locationStr) else {
                print("Invalid user location raw value!")
                return
            }
            let viewModel = MembershipDetailViewModel(insurance: insurance, country: userLocation)
            router.navigateToMembershipDetailScreen(viewModel)
        } catch {
            print(error)
        }
    }
}

extension InsuranceTypeViewController: ConsentTermsDelegate {
    func consentDidClose() {
        visual.removeFromSuperview()
    }
    
    func consentDidAccept() {
        visual.removeFromSuperview()
        AppManager.shared.currentInsuranceProvider.acceptConsent = true
        guard let insurance = selectedInsurance else { return }
        moveNext(with: insurance)
    }
    
    func consentDidDecline() {
        visual.removeFromSuperview()
        self.dismiss(animated: true, completion: nil)
    }
}

extension InsuranceTypeViewController: MembershipSelectLocationViewDelegate {
    func membership(didFinishPicking userLocation: UserLocation) {
        do {
            let locationStr = try viewModel.output.locationRawValue.value()
            guard userLocation.rawValue != locationStr else { return }
            resetPageCountIfNeeded()
            viewModel.input.location.onNext(userLocation.rawValue)
        } catch {
            print(error)
        }
    }
}

extension InsuranceTypeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 93
    }
}

extension InsuranceTypeViewController: InsuranceChoicesViewDelegate {
    func insuranceChoicesViewDidRecognizeTapAtLocation() {
        MixpanelTracker.trackEvent(EventNames.locationTappedNewFlow)

        do {
            let locationValue = try viewModel.output.locationRawValue.value()
            router.navigateToLocationSelectScreen(locationValue: locationValue, controller: self)
        } catch {
            print(error)
        }
    }
}
