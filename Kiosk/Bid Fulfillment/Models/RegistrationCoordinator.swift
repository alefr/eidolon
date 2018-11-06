import UIKit
import RxSwift

enum RegistrationIndex {
    case mobileVC
    case emailVC
    case passwordVC
    case creditCardVC
    case zipCodeVC
    case confirmVC
    
    func toInt() -> Int {
        switch (self) {
            case .mobileVC: return 0
            case .emailVC: return 1
            case .passwordVC: return 1
            case .zipCodeVC: return 2
            case .creditCardVC: return 3
            case .confirmVC: return 4
        }
    }
}

class RegistrationCoordinator: NSObject {
    fileprivate let _currentIndex = Variable(0)
    var currentIndex: Observable<Int> {
        return _currentIndex.asObservable().distinctUntilChanged()
    }
    var storyboard: UIStoryboard!

    fileprivate func viewControllerForIndex(_ index: RegistrationIndex) -> UIViewController {
        _currentIndex.value = index.toInt()
        
        switch index {

        case .mobileVC:
            return storyboard.viewController(withID: .RegisterMobile)

        case .emailVC:
            return storyboard.viewController(withID: .RegisterEmail)

        case .passwordVC:
            return storyboard.viewController(withID: .RegisterPassword)

        case .zipCodeVC:
            return storyboard.viewController(withID: .RegisterPostalorZip)

        case .creditCardVC:
            if AppSetup.sharedState.disableCardReader {
                return storyboard.viewController(withID: .ManualCardDetailsInput)
            } else {
                return storyboard.viewController(withID: .RegisterCreditCard)
            }

        case .confirmVC:
            return storyboard.viewController(withID: .RegisterConfirm)
        }
    }

    func nextViewControllerForBidDetails(_ details: BidDetails, sale: Sale) -> UIViewController {
        if notSet(details.newUser.phoneNumber.value) {
            return viewControllerForIndex(.mobileVC)
        }

        if notSet(details.newUser.email.value) {
            return viewControllerForIndex(.emailVC)
        }

        if notSet(details.newUser.password.value) && notSet(details.bidderPIN.value) {
            return viewControllerForIndex(.passwordVC)
        }

        if notSet(details.newUser.zipCode.value) && AppSetup.sharedState.needsZipCode {
            return viewControllerForIndex(.zipCodeVC)
        }

        if notSet(details.newUser.creditCardToken.value) && (sale.bypassCreditCardRequirement == false) {
            return viewControllerForIndex(.creditCardVC)
        }

        return viewControllerForIndex(.confirmVC)
    }
}

private func notSet(_ string: String?) -> Bool {
    return string?.isEmpty ?? true
}
