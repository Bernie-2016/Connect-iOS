import UIKit

// swiftlint:disable type_body_length
class ActionAlertsController: UIViewController {
    private let actionAlertService: ActionAlertService
    private let actionAlertWebViewProvider: ActionAlertWebViewProvider
    private let actionAlertLoadingMonitor: ActionAlertLoadingMonitor
    private let urlOpener: URLOpener
    private let analyticsService: AnalyticsService
    private let tabBarItemStylist: TabBarItemStylist
    private let theme: Theme

    var collectionView: UICollectionView!
    let loadingIndicatorView = UIActivityIndicatorView()
    let pageControl = UIPageControl.newAutoLayoutView()
    let loadingMessageLabel = UILabel.newAutoLayoutView()
    let errorLabel = UILabel.newAutoLayoutView()
    let retryButton = UIButton.newAutoLayoutView()

    private let layout = CenterCellCollectionViewFlowLayout()
    private var webViews: [UIWebView] = []
    private var actionAlerts: [ActionAlert] = []

    private let kCollectionViewCellName = "ActionAlertsCollectionViewCell"
    private let kHorizontalSectionInset: CGFloat = 15

    private let kFBShareURLPrefix = "https://m.facebook.com/sharer.php"
    private let kTweetURLPrefix = "https://twitter.com/intent/tweet"
    private let kRetweetURLPrefix = "https://twitter.com/intent/retweet"
    private let kLikeTweetURLPrefix = "https://twitter.com/intent/like"

    init(
        actionAlertService: ActionAlertService,
        actionAlertWebViewProvider: ActionAlertWebViewProvider,
        actionAlertLoadingMonitor: ActionAlertLoadingMonitor,
        urlOpener: URLOpener,
        analyticsService: AnalyticsService,
        tabBarItemStylist: TabBarItemStylist,
        theme: Theme
        ) {
            self.actionAlertService = actionAlertService
            self.actionAlertWebViewProvider = actionAlertWebViewProvider
            self.actionAlertLoadingMonitor = actionAlertLoadingMonitor
            self.urlOpener = urlOpener
            self.analyticsService = analyticsService
            self.tabBarItemStylist = tabBarItemStylist
            self.theme = theme

            super.init(nibName: nil, bundle: nil)

            title = NSLocalizedString("Actions_title", comment: "")
            tabBarItemStylist.applyThemeToBarBarItem(tabBarItem,
                image: UIImage(named: "actionsTabBarIconInactive")!,
                selectedImage: UIImage(named: "actionsTabBarIcon")!)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)

        automaticallyAdjustsScrollViewInsets = false

        layout.scrollDirection = .Horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: kHorizontalSectionInset, bottom: 0, right: kHorizontalSectionInset)
        layout.minimumLineSpacing = 12

        view.addSubview(collectionView)
        view.addSubview(loadingIndicatorView)
        view.addSubview(pageControl)
        view.addSubview(loadingMessageLabel)
        view.addSubview(errorLabel)
        view.addSubview(retryButton)

        collectionView.showsHorizontalScrollIndicator = false
        collectionView.clipsToBounds = false
        collectionView.hidden = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.registerClass(ActionAlertCell.self, forCellWithReuseIdentifier: kCollectionViewCellName)

        retryButton.setTitle(NSLocalizedString("Actions_retryButton", comment: ""), forState: .Normal)
        retryButton.addTarget(self, action: "didTapRetryButton", forControlEvents: .TouchUpInside)

        loadingIndicatorView.startAnimating()
        loadingMessageLabel.text = NSLocalizedString("Actions_loadingMessage", comment: "")

        applyTheme()
        setupConstraints()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: false)

        showLoadingUI()

        webViews.removeAll()
        loadActionAlerts()

        layout.invalidateLayout()
    }

    private func applyTheme() {
        view.backgroundColor = theme.actionsBackgroundColor()
        collectionView.backgroundView = UIImageView(image: UIImage(named: "actionAlertsBackground")!)

        loadingIndicatorView.color = theme.defaultSpinnerColor()

        loadingMessageLabel.font = theme.actionsShortLoadingMessageFont()
        loadingMessageLabel.textColor = theme.actionsShortLoadingMessageTextColor()

        errorLabel.font = theme.actionsErrorMessageFont()
        errorLabel.textColor = theme.actionsErrorMessageTextColor()
        retryButton.setTitleColor(theme.fullWidthRSVPButtonTextColor(), forState: .Normal)
        retryButton.titleLabel!.font = theme.fullWidthRSVPButtonFont()
        retryButton.backgroundColor = theme.fullWidthButtonBackgroundColor()
    }

    private func setupConstraints() {
        collectionView.autoPinEdge(.Top, toEdge: .Top, ofView: view)
        collectionView.autoPinEdge(.Left, toEdge: .Left, ofView: view)
        collectionView.autoPinEdge(.Right, toEdge: .Right, ofView: view)
        collectionView.autoPinEdge(.Bottom, toEdge: .Bottom, ofView: view)

        loadingIndicatorView.autoAlignAxisToSuperviewAxis(.Vertical)
        loadingIndicatorView.autoAlignAxis(.Horizontal, toSameAxisOfView: view, withOffset: -20)

        pageControl.autoAlignAxisToSuperviewAxis(.Vertical)
        pageControl.autoPinEdgeToSuperviewEdge(.Bottom, withInset: -10)

        loadingMessageLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: loadingIndicatorView, withOffset: 40)
        loadingMessageLabel.autoAlignAxis(.Vertical, toSameAxisOfView: loadingIndicatorView)

        errorLabel.autoAlignAxis(.Horizontal, toSameAxisOfView: view, withOffset: -120)
        errorLabel.autoAlignAxisToSuperviewAxis(.Vertical)

        retryButton.autoPinEdgeToSuperviewEdge(.Left)
        retryButton.autoPinEdgeToSuperviewEdge(.Right)
        retryButton.autoAlignAxis(.Horizontal, toSameAxisOfView: view)
        retryButton.autoSetDimension(.Height, toSize: 54)

    }

    private func loadActionAlerts() {
        let future = actionAlertService.fetchActionAlerts()

        future.then { actionAlerts in
            if actionAlerts.count == 0 {
                self.hideLoadingUI()
                self.showErrorUI(NSLocalizedString("Actions_noResultsMessage", comment: ""))
            } else {
                self.updateUIWithActionAlerts(actionAlerts)
            }
        }

        future.error { error in
            self.hideLoadingUI()
            self.showErrorUI(NSLocalizedString("Actions_errorMessage", comment: ""))
        }
    }

    private func showLoadingUI() {
        loadingMessageLabel.hidden = false
        pageControl.hidden = true
        loadingIndicatorView.hidden = false
        collectionView.hidden = true
        errorLabel.hidden = true
        retryButton.hidden = true
    }

    private func showResultsUI() {
        pageControl.hidden = false
        collectionView.hidden = false
    }

    private func hideLoadingUI() {
        loadingMessageLabel.hidden = true
        loadingIndicatorView.hidden = true
    }

    private func showErrorUI(errorMessage: String) {
        errorLabel.text = errorMessage
        errorLabel.hidden = false
        retryButton.hidden = false
    }

    private func hideErrorUI() {
        errorLabel.hidden = false
        retryButton.hidden = false
    }

    private func updateUIWithActionAlerts(actionAlerts: [ActionAlert]) {
        let webViewWidth = UIScreen.mainScreen().bounds.width - 10

        self.actionAlerts = actionAlerts

        for actionAlert in actionAlerts {
            let webView = self.actionAlertWebViewProvider.provideInstanceWithBody(actionAlert.body, width: webViewWidth)

            webView.layer.cornerRadius = 4.0
            webView.layer.masksToBounds = true
            webView.clipsToBounds = true
            webView.opaque = false
            webView.backgroundColor = UIColor.clearColor()
            webView.scrollView.showsVerticalScrollIndicator = false
            webView.delegate = self
            webView.scrollView.scrollEnabled = false
            webView.alpha = 0

            // this is because the facebook embed code isn't responsive - we need to render it with the correct width
            // such that we work around its margins
            self.view.addSubview(webView)

            let webViewWidth = UIScreen.mainScreen().bounds.width - 10
            webView.autoSetDimension(.Width, toSize: webViewWidth)
            webView.autoSetDimension(.Height, toSize: 220)
            webView.autoCenterInSuperview()

            self.webViews.append(webView)
        }

        self.actionAlertLoadingMonitor.waitUntilWebViewsHaveLoaded(self.webViews) {
            for webView in self.webViews {
                let removeIFrameMarginHack = "var i = document.documentElement.getElementsByTagName('iframe'); for (var j = 0 ; j < i.length ; j++ ) { k = i[j]; k.style.marginTop = '0px'; }"
                webView.stringByEvaluatingJavaScriptFromString(removeIFrameMarginHack)
            }

            self.collectionView.reloadData()

            UIView.transitionWithView(self.view, duration: 0.4, options: .TransitionCrossDissolve, animations: {
                self.hideLoadingUI()
                self.pageControl.numberOfPages = self.actionAlerts.count
                self.showResultsUI()
                }, completion: { _ in })
        }
    }
}

// MARK: Actions

extension ActionAlertsController {
    func didTapRetryButton() {
        self.loadActionAlerts()

        UIView.transitionWithView(self.view, duration: 0.3, options: .TransitionCrossDissolve, animations: {
            self.hideErrorUI()
            self.showLoadingUI()

            }, completion: { _ in

            })
    }
}

// MARK: UICollectionViewDataSource

extension ActionAlertsController: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return webViews.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kCollectionViewCellName, forIndexPath: indexPath) as? ActionAlertCell else {
            fatalError("Badly configured collectoinview :(")
        }

        for view in cell.webviewContainer.subviews {
            view.removeFromSuperview()
        }

        let webView = webViews[indexPath.item]
        webView.removeConstraints(webView.constraints)
        webView.alpha = 1

        cell.titleLabel.text = actionAlerts[indexPath.item].title
        cell.shortDescriptionLabel.text = actionAlerts[indexPath.item].shortDescription

        cell.webviewContainer.addSubview(webView)
        webView.autoPinEdgesToSuperviewEdges()

        let heightString = webView.stringByEvaluatingJavaScriptFromString("Math.max( document.documentElement.scrollHeight, document.documentElement.offsetHeight, document.documentElement.clientHeight);")

        let heightDouble = heightString != nil ? Double(heightString!) : 0.0
        let heightFloat: CGFloat = heightDouble != nil ? CGFloat(heightDouble!) : 0.0

        cell.webViewHeight = heightFloat

        cell.titleLabel.font = theme.actionsTitleFont()
        cell.titleLabel.textColor = theme.actionsTitleTextColor()
        cell.shortDescriptionLabel.font = theme.actionsShortDescriptionFont()
        cell.shortDescriptionLabel.textColor = theme.actionsShortDescriptionTextColor()

        return cell
    }
}

// MARK: UICollectionViewDelegateFlowLayout

extension ActionAlertsController: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        var s = collectionView.bounds.size
        s.width = s.width - (2 * kHorizontalSectionInset)
        return s
    }

    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let pageWidth = UIScreen.mainScreen().bounds.width
        let currentPage: Float = Float(scrollView.contentOffset.x / pageWidth)

        if (0.0 != fmodf(currentPage, 1.0)) {
            pageControl.currentPage = Int(currentPage) + 1
        } else {
            pageControl.currentPage = Int(currentPage)
        }
    }
}


// MARK: UIWebViewDelegate

extension ActionAlertsController: UIWebViewDelegate {
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if navigationType != .LinkClicked {
            return true
        }

        guard let url = request.URL else {
            return false
        }

        trackLinkClick(url)

        urlOpener.openURL(url)

        return false
    }

    private func trackLinkClick(url: NSURL) {
        let actionAlert = actionAlerts[pageControl.currentPage]

        var attributes = [
            AnalyticsServiceConstants.contentIDKey: actionAlert.identifier,
            AnalyticsServiceConstants.contentNameKey: actionAlert.title,
        ]


        switch url.absoluteString {
        case let s where s.hasPrefix(kFBShareURLPrefix):
            attributes[AnalyticsServiceConstants.contentTypeKey] = "Action Alert - Facebook"
            break
        case let s where s.hasPrefix(kTweetURLPrefix):
            attributes[AnalyticsServiceConstants.contentTypeKey] = "Action Alert - Tweet"
            break
        case let s where s.hasPrefix(kRetweetURLPrefix):
            attributes[AnalyticsServiceConstants.contentTypeKey] = "Action Alert - Retweet"
            break
        case let s where s.hasPrefix(kLikeTweetURLPrefix):
            attributes[AnalyticsServiceConstants.contentTypeKey] = "Action Alert - Like Tweet"
            break
        default:
            attributes[AnalyticsServiceConstants.contentTypeKey] = "Action Alert - Followed Other Link"
            attributes[AnalyticsServiceConstants.contentURLKey] = url.absoluteString
        }

        analyticsService.trackCustomEventWithName("Began Share", customAttributes: attributes)
    }
}
// swiftlint:enable type_body_length
