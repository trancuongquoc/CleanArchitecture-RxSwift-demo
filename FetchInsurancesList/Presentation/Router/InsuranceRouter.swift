//
//  InsuranceRouter.swift
//  Created by Quoc Cuong on 27/02/2023.
//

import UIKit

protocol InsuranceRouter: BaseRouter {
    func popToBeginningScreen(animated: Bool)
    func navigateToLocationSelectScreen(locationValue: String, controller: UIViewController)
    func navigateToMembershipDetailScreen(_ viewModel: MembershipDetailViewModel)
    func presentConsentTermsView(controller: UIViewController)
}

extension InsuranceRouter {
    static func create() -> Self {
        return DefaultInsuranceRouter() as! Self
    }
}

final class DefaultInsuranceRouter: InsuranceRouter {
    func navigateToLocationSelectScreen(locationValue: String, controller: UIViewController) {
        pushTo(MembershipSelectLocationViewController.self,
               storyId: "MembershipSelectLocationViewController",
               board: UIStoryboard.InsuranceStoryBoard()) { viewController in
            viewController.currentSelectedIndex = viewController.countries.firstIndex(where: { $0.rawValue == locationValue }) ?? 0
            viewController.delegate = controller as? MembershipSelectLocationViewDelegate
        }
    }
    
    func navigateToMembershipDetailScreen(_ viewModel: MembershipDetailViewModel) {
        let controller = MembershipDetailViewController(viewModel: viewModel)
        pushTo(controller)
    }
    
    func presentConsentTermsView(controller: UIViewController) {
        present(ConsentTermsViewController.self, type: .overCurrentContext) { consentVC in
            consentVC.delegate = controller as? any ConsentTermsDelegate
        }
    }
    
    func popToBeginningScreen(animated: Bool = true) {
        guard let topViewController = UIApplication.topViewController(),
        let nav = topViewController.navigationController else {
            popToRoot(animated: animated, completion: nil)
            return
        }
        
        let controllers = nav.viewControllers.filter { controller in controller.isMember(of: PaymentViewController.self) || controller.isMember(of: MyInfoViewController.self) }
        
        guard let controller = controllers.first else {
            popToRoot(animated: animated, completion: nil)
            return
        }

        nav.popToViewController(controller, animated: animated)
    }
}
