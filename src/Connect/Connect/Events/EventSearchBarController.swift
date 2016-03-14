import UIKit

class EventSearchBarController: UIViewController {
    private let nearbyEventsUseCase: NearbyEventsUseCase
    private let eventsNearAddressUseCase: EventsNearAddressUseCase
    private let resultQueue: NSOperationQueue
    private let zipCodeValidator: ZipCodeValidator
    private let theme: Theme

    let searchBar = UISearchBar.newAutoLayoutView()
    let cancelButton = UIButton.newAutoLayoutView()
    let searchButton = UIButton.newAutoLayoutView()

    private var preEditPlaceholder: String?

    init(
        nearbyEventsUseCase: NearbyEventsUseCase,
        eventsNearAddressUseCase: EventsNearAddressUseCase,
        resultQueue: NSOperationQueue,
        zipCodeValidator: ZipCodeValidator,
        theme: Theme) {
            self.nearbyEventsUseCase = nearbyEventsUseCase
            self.eventsNearAddressUseCase = eventsNearAddressUseCase
            self.resultQueue = resultQueue
            self.zipCodeValidator = zipCodeValidator
            self.theme = theme

            super.init(nibName: nil, bundle: nil)

            nearbyEventsUseCase.addObserver(self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        view.addSubview(searchBar)
        view.addSubview(cancelButton)
        view.addSubview(searchButton)

        searchBar.searchBarStyle = .Minimal
        searchBar.delegate = self

        cancelButton.addTarget(self, action: "didTapCancelButton", forControlEvents: .TouchUpInside)
        cancelButton.setTitle(NSLocalizedString("EventsSearchBar_cancelButtonTitle", comment: ""), forState: .Normal)

        searchButton.addTarget(self, action: "didTapSubmitButton", forControlEvents: .TouchUpInside)
        searchButton.setTitle(NSLocalizedString("EventsSearchBar_searchButtonTitle", comment: ""), forState: .Normal)
        searchButton.enabled = false

        setupConstraints()
        applyTheme()
    }

    private func setupConstraints() {
        cancelButton.autoPinEdgeToSuperviewEdge(.Left)
        cancelButton.autoAlignAxis(.Horizontal, toSameAxisOfView: searchBar)

        searchButton.autoPinEdgeToSuperviewEdge(.Right)
        searchButton.autoAlignAxis(.Horizontal, toSameAxisOfView: searchBar)

        searchBar.autoPinEdgeToSuperviewEdge(.Top)
        searchBar.autoPinEdge(.Left, toEdge: .Right, ofView: cancelButton)
        searchBar.autoPinEdge(.Right, toEdge: .Left, ofView: searchButton)
        searchBar.autoPinEdgeToSuperviewEdge(.Bottom)
    }

    private func applyTheme() {
        view.backgroundColor = theme.eventsSearchBarBackgroundColor()

        searchButton.setTitleColor(theme.defaultButtonDisabledTextColor(), forState: .Disabled)
        searchButton.setTitleColor(theme.navigationBarButtonTextColor(), forState: .Normal)
        searchButton.titleLabel!.font = self.theme.eventsSearchBarFont()

        cancelButton.setTitleColor(theme.defaultButtonDisabledTextColor(), forState: .Disabled)
        cancelButton.setTitleColor(theme.navigationBarButtonTextColor(), forState: .Normal)
        cancelButton.titleLabel!.font = self.theme.eventsSearchBarFont()

        if let textField = searchBar.valueForKey("searchField") as? UITextField {
            textField.textColor = self.theme.eventsZipCodeTextColor()
            textField.font = self.theme.eventsSearchBarFont()
            textField.backgroundColor = self.theme.eventsZipCodeBackgroundColor()
            textField.layer.borderColor = self.theme.eventsZipCodeBorderColor().CGColor
            textField.layer.borderWidth = self.theme.eventsZipCodeBorderWidth()
            textField.layer.cornerRadius = self.theme.eventsZipCodeCornerRadius()
            textField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("Events_zipCodeTextBoxPlaceholder",  comment: ""),
                attributes:[NSForegroundColorAttributeName: self.theme.eventsZipCodePlaceholderTextColor()])
        }
    }
}

extension EventSearchBarController: NearbyEventsUseCaseObserver {
    func nearbyEventsUseCase(useCase: NearbyEventsUseCase, didFetchEventSearchResult: EventSearchResult) {
        setPlaceholderToCurrentLocation()
    }

    func nearbyEventsUseCaseFoundNoNearbyEvents(useCase: NearbyEventsUseCase) {
        setPlaceholderToCurrentLocation()
    }

    func nearbyEventsUseCaseDidStartFetchingEvents(useCase: NearbyEventsUseCase) {
        resultQueue.addOperationWithBlock {
            self.searchBar.placeholder = NSLocalizedString("EventsSearchBar_loadingNearbyEvents", comment: "")
        }
    }

    func nearbyEventsUseCase(useCase: NearbyEventsUseCase, didFailFetchEvents: NearbyEventsUseCaseError) {}

    private func setPlaceholderToCurrentLocation() {
        resultQueue.addOperationWithBlock {
            self.searchBar.placeholder = NSLocalizedString("EventsSearchBar_foundNearbyResults", comment: "")
        }
    }
}

extension EventSearchBarController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        preEditPlaceholder = searchBar.placeholder
        if preEditPlaceholder == NSLocalizedString("EventsSearchBar_foundNearbyResults", comment: "") {
            searchBar.text = ""
        } else {
            searchBar.text = preEditPlaceholder
        }

        searchBar.placeholder = NSLocalizedString("EventsSearchBar_searchBarPlaceholder", comment: "")
        return true
    }

    func searchBar(searchBar: UISearchBar, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let updatedZipCode = (searchBar.text! as NSString).stringByReplacingCharactersInRange(range, withString: text)

        if updatedZipCode.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) < 6 {
            searchButton.enabled = zipCodeValidator.validate(updatedZipCode)
        }

        return updatedZipCode.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) <= 5
    }
}

extension EventSearchBarController {
    func didTapCancelButton() {
        searchBar.resignFirstResponder()
        searchBar.placeholder = preEditPlaceholder
    }

    func didTapSubmitButton() {
        searchBar.resignFirstResponder()
        eventsNearAddressUseCase.fetchEventsNearAddress(searchBar.text!, radiusMiles: 10.0)
        searchBar.placeholder = searchBar.text
        searchBar.text = nil
    }
}
