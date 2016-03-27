import UIKit

class EventsNoResultsController: UIViewController {
    private let urlOpener: URLOpener
    private let urlProvider: URLProvider
    private let analyticsService: AnalyticsService
    private let theme: Theme

    let noResultsLabel = UILabel.newAutoLayoutView()
    let createEventCTATextView = UITextView.newAutoLayoutView()

    init(
        urlOpener: URLOpener,
        urlProvider: URLProvider,
        analyticsService: AnalyticsService,
        theme: Theme
        ) {
            self.urlOpener = urlOpener
            self.urlProvider = urlProvider
            self.analyticsService = analyticsService
            self.theme = theme

            super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(noResultsLabel)
        view.addSubview(createEventCTATextView)

        noResultsLabel.numberOfLines = 0
        noResultsLabel.textAlignment = .Center
        noResultsLabel.text = NSLocalizedString("Events_noEventsFound", comment: "")
        noResultsLabel.lineBreakMode = .ByTruncatingTail

        setupCreateEventCTATextView()
        applyTheme()
        setupConstraints()
    }

    func setupCreateEventCTATextView() {
        createEventCTATextView.scrollEnabled = false
        createEventCTATextView.selectable = false
        createEventCTATextView.textAlignment = .Center

        var fullTextAttributes = [String:AnyObject]()
        let paragraphStyle: NSMutableParagraphStyle? = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as? NSMutableParagraphStyle

        if paragraphStyle != nil {
            paragraphStyle!.alignment = .Center
            fullTextAttributes[NSParagraphStyleAttributeName] = paragraphStyle!
        }

        let fullText = NSMutableAttributedString(string: NSLocalizedString("Events_createEventCTAText", comment:""),
            attributes: fullTextAttributes)
        let organize = NSAttributedString(string: NSLocalizedString("Events_organizeText", comment: ""), attributes: [NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue, "organize": true])

        fullText.replaceCharactersInRange((fullText.string as NSString).rangeOfString("{0}"), withAttributedString: organize)

        createEventCTATextView.attributedText = fullText

        let tapOrganizeRecognizer = UITapGestureRecognizer(target: self, action: #selector(EventsNoResultsController.didTapOrganize(_:)))
        createEventCTATextView.addGestureRecognizer(tapOrganizeRecognizer)

    }

    private func applyTheme() {
        noResultsLabel.textColor = theme.eventsInformationTextColor()
        noResultsLabel.font = theme.eventsNoResultsFont()

        createEventCTATextView.font = theme.eventsCreateEventCTAFont()
        createEventCTATextView.textColor = theme.eventsInformationTextColor()
        createEventCTATextView.backgroundColor = theme.defaultBackgroundColor()
    }

    private func setupConstraints() {
        noResultsLabel.autoAlignAxisToSuperviewAxis(.Vertical)
        noResultsLabel.autoAlignAxis(.Horizontal, toSameAxisOfView: view, withOffset: -75)
        noResultsLabel.autoSetDimension(.Width, toSize: 220)

        createEventCTATextView.autoPinEdge(.Top, toEdge: .Bottom, ofView: noResultsLabel, withOffset: 15)
        createEventCTATextView.autoPinEdge(.Left, toEdge: .Left, ofView: noResultsLabel, withOffset: 10)
        createEventCTATextView.autoPinEdge(.Right, toEdge: .Right, ofView: noResultsLabel, withOffset: -10)
    }
}


// MARK: Actions
extension EventsNoResultsController {
    func didTapOrganize(recognizer: UIGestureRecognizer) {
        guard let textView = recognizer.view as? UITextView else { return }
        let layoutManager = textView.layoutManager
        var location = recognizer.locationInView(textView)
        location.x = location.x - textView.textContainerInset.left
        location.y = location.y - textView.textContainerInset.top

        let characterIndex = layoutManager.characterIndexForPoint(location, inTextContainer: textView.textContainer, fractionOfDistanceBetweenInsertionPoints: nil)

        if characterIndex < textView.textStorage.length {
            let organizeValue = textView.textStorage.attribute("organize", atIndex: characterIndex, effectiveRange: nil)

            if organizeValue != nil {
                let url = self.urlProvider.hostEventFormURL()
                self.analyticsService.trackContentViewWithName("Create Events Form", type: .Event, identifier: url.absoluteString)
                self.urlOpener.openURL(url)
                return
            }
        }
    }
}
