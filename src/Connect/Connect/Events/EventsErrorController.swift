import UIKit

class EventsErrorController: UIViewController {
    private let nearbyEventsUseCase: NearbyEventsUseCase
    private let eventsNearAddressUseCase: EventsNearAddressUseCase
    private let resultQueue: NSOperationQueue
    private let theme: Theme


    let genericErrorView = UIView.newAutoLayoutView()
    let genericErrorHeadingLabel = UILabel.newAutoLayoutView()
    let genericErrorDetailLabel = UILabel.newAutoLayoutView()

    let permissionsErrorView = UIView.newAutoLayoutView()
    let permissionsErrorImageView = UIImageView.newAutoLayoutView()
    let permissionsErrorHeadingLabel = UILabel.newAutoLayoutView()

    init(nearbyEventsUseCase: NearbyEventsUseCase,
        eventsNearAddressUseCase: EventsNearAddressUseCase,
        resultQueue: NSOperationQueue,
        theme: Theme) {
            self.nearbyEventsUseCase = nearbyEventsUseCase
            self.eventsNearAddressUseCase = eventsNearAddressUseCase
            self.resultQueue = resultQueue
            self.theme = theme

            super.init(nibName: nil, bundle: nil)

            nearbyEventsUseCase.addObserver(self)
            eventsNearAddressUseCase.addObserver(self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(genericErrorView)
        genericErrorView.addSubview(genericErrorHeadingLabel)
        genericErrorView.addSubview(genericErrorDetailLabel)
        genericErrorHeadingLabel.text = NSLocalizedString("EventsErrors_genericHeading", comment: "")
        genericErrorDetailLabel.text = NSLocalizedString("EventsErrors_genericDetail", comment: "")

        view.addSubview(permissionsErrorView)
        permissionsErrorView.addSubview(permissionsErrorImageView)
        permissionsErrorView.addSubview(permissionsErrorHeadingLabel)
        permissionsErrorImageView.image = UIImage(named: "eventSearch")
        permissionsErrorHeadingLabel.text = NSLocalizedString("EventsErrors_permissionsHeading", comment: "")

        setupConstraints()
        applyTheme()
    }

    private func setupConstraints() {
        genericErrorView.autoAlignAxis(.Horizontal, toSameAxisOfView: view, withOffset: -50)
        genericErrorView.autoAlignAxis(.Vertical, toSameAxisOfView: view, withOffset: 0)
        genericErrorHeadingLabel.autoAlignAxis(.Vertical, toSameAxisOfView: genericErrorView)
        genericErrorHeadingLabel.autoPinEdgeToSuperviewEdge(.Top)
        genericErrorDetailLabel.autoAlignAxis(.Vertical, toSameAxisOfView: genericErrorView)
        genericErrorDetailLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: genericErrorHeadingLabel)

        permissionsErrorView.autoAlignAxis(.Horizontal, toSameAxisOfView: view, withOffset: -50)
        permissionsErrorView.autoAlignAxis(.Vertical, toSameAxisOfView: view, withOffset: 0)
        permissionsErrorImageView.autoAlignAxis(.Vertical, toSameAxisOfView: genericErrorView)
        permissionsErrorImageView.autoPinEdgeToSuperviewEdge(.Top)
        permissionsErrorHeadingLabel.autoAlignAxis(.Vertical, toSameAxisOfView: genericErrorView)
        permissionsErrorHeadingLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: permissionsErrorImageView)
    }

    private func applyTheme() {
       permissionsErrorHeadingLabel.font = theme.eventsErrorHeadingFont()
       genericErrorHeadingLabel.font = theme.eventsErrorHeadingFont()
       genericErrorDetailLabel.font = theme.eventsErrorDetailFont()

       permissionsErrorHeadingLabel.textColor = theme.eventsErrorTextColor()
       genericErrorHeadingLabel.textColor = theme.eventsErrorTextColor()
       genericErrorDetailLabel.textColor = theme.eventsErrorTextColor()
    }

    private func showPermissionsError() {
        resultQueue.addOperationWithBlock {
            self.genericErrorView.hidden = true
            self.permissionsErrorView.hidden = false
        }
    }

    private func showGenericError() {
        resultQueue.addOperationWithBlock {
            self.genericErrorView.hidden = false
            self.permissionsErrorView.hidden = true
        }
    }
}

extension EventsErrorController: NearbyEventsUseCaseObserver {

    func nearbyEventsUseCase(useCase: NearbyEventsUseCase, didFailFetchEvents error: NearbyEventsUseCaseError) {
        switch error {
        case .FindingLocationError(let currentLocationError):
            switch currentLocationError {
            case .PermissionsError:
                showPermissionsError()
            default:
                showGenericError()
            }
        default:
            showGenericError()
        }
    }

    func nearbyEventsUseCase(useCase: NearbyEventsUseCase, didFetchEventSearchResult: EventSearchResult) {}

    func nearbyEventsUseCaseDidStartFetchingEvents(useCase: NearbyEventsUseCase) {}

    func nearbyEventsUseCaseFoundNoNearbyEvents(useCase: NearbyEventsUseCase) {}
}

extension EventsErrorController: EventsNearAddressUseCaseObserver {
    func eventsNearAddressUseCase(useCase: EventsNearAddressUseCase, didFailFetchEvents error: EventsNearAddressUseCaseError, address: Address) {
        showGenericError()
    }

    func eventsNearAddressUseCase(useCase: EventsNearAddressUseCase, didFetchEventSearchResult eventSearchResult: EventSearchResult, address: Address) {}

    func eventsNearAddressUseCaseDidStartFetchingEvents(useCase: EventsNearAddressUseCase, address: Address) {}

    func eventsNearAddressUseCaseFoundNoEvents(useCase: EventsNearAddressUseCase, address: Address) {}
}
