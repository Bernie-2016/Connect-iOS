import UIKit

protocol EventsNearAddressFilterControllerDelegate {
    func eventsNearAddressFilterControllerDidCancel(controller: EventsNearAddressFilterController)
}

class EventsNearAddressFilterController: UIViewController {
    private let eventsNearAddressUseCase: EventsNearAddressUseCase
    private let radiusDataSource: RadiusDataSource
    private let workerQueue: NSOperationQueue
    private let resultQueue: NSOperationQueue
    private let theme: Theme

    let searchButton = ResponderButton.newAutoLayoutView()
    let cancelButton = UIButton.newAutoLayoutView()
    let pickerView = UIPickerView()

    var delegate: EventsNearAddressFilterControllerDelegate?
    var currentAddress = ""

    init(eventsNearAddressUseCase: EventsNearAddressUseCase,
        radiusDataSource: RadiusDataSource,
        workerQueue: NSOperationQueue,
        resultQueue: NSOperationQueue,
        theme: Theme) {
            self.eventsNearAddressUseCase = eventsNearAddressUseCase
            self.radiusDataSource = radiusDataSource
            self.workerQueue = workerQueue
            self.resultQueue = resultQueue
            self.theme = theme

            super.init(nibName: nil, bundle: nil)

            eventsNearAddressUseCase.addObserver(self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(searchButton)
        view.addSubview(cancelButton)

        pickerView.dataSource = radiusDataSource
        pickerView.delegate = radiusDataSource

        searchButton.buttonInputView = pickerView
        searchButton.enabled = false

        cancelButton.setTitle(NSLocalizedString("EventsSearchBar_cancelButtonTitle", comment: ""), forState: .Normal)
        cancelButton.addTarget(self, action: "didTapCancelButton", forControlEvents: .TouchUpInside)

        searchButton.setTitle(NSLocalizedString("EventsSearchBar_searchButtonTitle", comment: ""), forState: .Normal)
        searchButton.addTarget("self", action: "didTapSearchButton", forControlEvents: .TouchUpInside)

        applyTheme()
        setupConstraints()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        searchButton.becomeFirstResponder()
    }

    private func applyTheme() {
        view.backgroundColor = theme.eventsSearchBarBackgroundColor()

        searchButton.setTitleColor(theme.defaultButtonDisabledTextColor(), forState: .Disabled)
        searchButton.setTitleColor(theme.navigationBarButtonTextColor(), forState: .Normal)
        searchButton.titleLabel!.font = self.theme.eventsSearchBarFont()

        cancelButton.setTitleColor(theme.defaultButtonDisabledTextColor(), forState: .Disabled)
        cancelButton.setTitleColor(theme.navigationBarButtonTextColor(), forState: .Normal)
        cancelButton.titleLabel!.font = self.theme.eventsSearchBarFont()
    }

    private func setupConstraints() {
        let buttonWidth: CGFloat = 60

        cancelButton.autoPinEdgeToSuperviewEdge(.Left, withInset: theme.eventSearchBarHorizontalPadding())
        cancelButton.autoPinEdgeToSuperviewEdge(.Bottom, withInset: 29)
        cancelButton.autoSetDimension(.Width, toSize: buttonWidth)

        searchButton.autoPinEdgeToSuperviewEdge(.Right, withInset: theme.eventSearchBarHorizontalPadding())
        searchButton.autoPinEdgeToSuperviewEdge(.Bottom, withInset: 29)
        searchButton.autoSetDimension(.Width, toSize: buttonWidth)

    }
}

// MARK: Actions
extension EventsNearAddressFilterController {
    func didTapSearchButton() {
        radiusDataSource.confirmSelection()

        workerQueue.addOperationWithBlock {
            let radiusMiles = self.radiusDataSource.currentMilesValue
            self.eventsNearAddressUseCase.fetchEventsNearAddress(self.currentAddress, radiusMiles: radiusMiles)
        }
    }

    func didTapCancelButton() {
        delegate?.eventsNearAddressFilterControllerDidCancel(self)
    }
}

extension EventsNearAddressFilterController: EventsNearAddressUseCaseObserver {
    func eventsNearAddressUseCase(useCase: EventsNearAddressUseCase, didFailFetchEvents error: EventsNearAddressUseCaseError, address: Address) {

    }

    func eventsNearAddressUseCase(useCase: EventsNearAddressUseCase, didFetchEventSearchResult eventSearchResult: EventSearchResult, address: Address) {

    }

    func eventsNearAddressUseCaseDidStartFetchingEvents(useCase: EventsNearAddressUseCase, address: Address) {
        resultQueue.addOperationWithBlock {
            self.currentAddress = address
            self.searchButton.enabled = true
        }
    }

    func eventsNearAddressUseCaseFoundNoEvents(useCase: EventsNearAddressUseCase, address: Address) {

    }
}
