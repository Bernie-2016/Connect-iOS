import UIKit

protocol NearbyEventsFilterControllerDelegate {
    func nearbyEventsFilterControllerDidCancel(controller: NearbyEventsFilterController)
}


class NearbyEventsFilterController: UIViewController {
    private let nearbyEventsUseCase: NearbyEventsUseCase
    private let radiusDataSource: RadiusDataSource
    private let workerQueue: NSOperationQueue
    private let analyticsService: AnalyticsService
    private let theme: Theme

    let searchButton = ResponderButton.newAutoLayoutView()
    let cancelButton = UIButton.newAutoLayoutView()
    let pickerView = UIPickerView()

    var delegate: NearbyEventsFilterControllerDelegate?

    init(nearbyEventsUseCase: NearbyEventsUseCase, radiusDataSource: RadiusDataSource, workerQueue: NSOperationQueue, analyticsService: AnalyticsService, theme: Theme) {
        self.nearbyEventsUseCase = nearbyEventsUseCase
        self.radiusDataSource = radiusDataSource
        self.workerQueue = workerQueue
        self.analyticsService = analyticsService
        self.theme = theme

        super.init(nibName: nil, bundle: nil)
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
        pickerView.showsSelectionIndicator = true
        pickerView.selectRow(radiusDataSource.confirmedSelectedIndex, inComponent: 0, animated: false) // bad hack :/

        searchButton.buttonInputView = pickerView

        cancelButton.setTitle(NSLocalizedString("EventsSearchBar_cancelButtonTitle", comment: ""), forState: .Normal)
        cancelButton.addTarget(self, action: #selector(NearbyEventsFilterController.didTapCancelButton), forControlEvents: .TouchUpInside)

        searchButton.setTitle(NSLocalizedString("EventsSearchBar_searchButtonTitle", comment: ""), forState: .Normal)
        searchButton.addTarget(self, action: #selector(NearbyEventsFilterController.didTapSearchButton), forControlEvents: .TouchUpInside)

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

extension NearbyEventsFilterController {
    func didTapSearchButton() {
        radiusDataSource.confirmSelection()

        workerQueue.addOperationWithBlock {
            let radiusMiles = self.radiusDataSource.currentMilesValue
            let loggedSearchQuery = "NEARBY|\(radiusMiles)"

            self.analyticsService.trackSearchWithQuery(loggedSearchQuery, context: .Events)
            self.nearbyEventsUseCase.fetchNearbyEventsWithinRadiusMiles(radiusMiles)
        }
    }

    func didTapCancelButton() {
        analyticsService.trackCustomEventWithName("Tapped cancel on Nearby Events Filter", customAttributes: nil)
        delegate?.nearbyEventsFilterControllerDidCancel(self)
    }
}
