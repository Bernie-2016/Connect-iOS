import UIKit

// swiftlint:disable type_body_length
// swiftlint:disable file_length
class ActionAlertsController: UIViewController {
    private let actionAlertService: ActionAlertService
    private let actionAlertWebViewProvider: ActionAlertWebViewProvider
    private let actionAlertLoadingMonitor: ActionAlertLoadingMonitor
    private let urlOpener: URLOpener
    private let moreController: UIViewController
    private let analyticsService: AnalyticsService
    private let tabBarItemStylist: TabBarItemStylist
    private let theme: Theme

    var collectionView: UICollectionView!
    let loadingIndicatorView = UIActivityIndicatorView()
    var pageControl = UIPageControl.newAutoLayoutView()
    let errorLabel = UILabel.newAutoLayoutView()
    let retryButton = UIButton.newAutoLayoutView()
    let backgroundImageView = UIImageView.newAutoLayoutView()
    let connectLogoImageView = UIImageView.newAutoLayoutView()
    let infoButton = UIButton(type: .Custom)

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
        moreController: UIViewController,
        analyticsService: AnalyticsService,
        tabBarItemStylist: TabBarItemStylist,
        theme: Theme
        ) {
        self.actionAlertService = actionAlertService
        self.actionAlertWebViewProvider = actionAlertWebViewProvider
        self.actionAlertLoadingMonitor = actionAlertLoadingMonitor
        self.urlOpener = urlOpener
        self.moreController = moreController
        self.analyticsService = analyticsService
        self.tabBarItemStylist = tabBarItemStylist
        self.theme = theme

        super.init(nibName: nil, bundle: nil)

        tabBarItem.title = NSLocalizedString("Actions_title", comment: "")
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
        layout.minimumLineSpacing = 15


        let infoButtonImage = UIImage(named: "infoButton")!.imageWithRenderingMode(.AlwaysTemplate)
        infoButton.setImage(infoButtonImage, forState: .Normal)
        infoButton.tintColor = theme.actionsInfoButtonTintColor()
        infoButton.addTarget(self, action: #selector(ActionAlertsController.didTapInfoButton), forControlEvents: .TouchUpInside)

        let backBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Actions_backButtonTitle", comment: ""),
                                                style: UIBarButtonItemStyle.Plain,
                                                target: nil, action: nil)

        navigationItem.backBarButtonItem = backBarButtonItem

        view.addSubview(backgroundImageView)
        view.addSubview(collectionView)
        view.addSubview(loadingIndicatorView)
        view.addSubview(errorLabel)
        view.addSubview(retryButton)
        view.addSubview(connectLogoImageView)
        view.addSubview(pageControl)
        view.addSubview(infoButton)

        collectionView.backgroundColor = UIColor.clearColor()
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.clipsToBounds = false
        collectionView.hidden = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.registerClass(ActionAlertCell.self, forCellWithReuseIdentifier: kCollectionViewCellName)
        collectionView.decelerationRate = UIScrollViewDecelerationRateFast

        errorLabel.numberOfLines = 0

        retryButton.setTitle(NSLocalizedString("Actions_retryButton", comment: ""), forState: .Normal)
        retryButton.addTarget(self, action: #selector(ActionAlertsController.didTapRetryButton), forControlEvents: .TouchUpInside)

        loadingIndicatorView.startAnimating()

        applyTheme()
        setupConstraints()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: true)

        showLoadingUI()

        webViews.removeAll()
        loadActionAlerts()

        layout.invalidateLayout()
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

    private func applyTheme() {
        pageControl.currentPageIndicatorTintColor = theme.defaultCurrentPageIndicatorTintColor()
        pageControl.pageIndicatorTintColor = theme.defaultPageIndicatorTintColor()

        view.backgroundColor = theme.actionsBackgroundColor()
        backgroundImageView.image = UIImage(named: "gradientBackground")!

        loadingIndicatorView.color = theme.defaultSpinnerColor()

        errorLabel.font = theme.actionsErrorMessageFont()
        errorLabel.textColor = theme.actionsErrorMessageTextColor()
        retryButton.setTitleColor(theme.fullWidthRSVPButtonTextColor(), forState: .Normal)
        retryButton.titleLabel!.font = theme.fullWidthRSVPButtonFont()
        retryButton.backgroundColor = theme.fullWidthButtonBackgroundColor()

        connectLogoImageView.image = UIImage(named: "connectLogo")!
    }

    private func setupConstraints() {
        backgroundImageView.autoPinEdgesToSuperviewEdges()

        infoButton.autoPinEdgeToSuperviewEdge(.Top, withInset: 30)
        infoButton.autoPinEdgeToSuperviewEdge(.Right, withInset: 16)

        pageControl.autoAlignAxisToSuperviewAxis(.Vertical)
        pageControl.autoPinEdgeToSuperviewEdge(.Top, withInset: 25)

        collectionView.autoPinEdgeToSuperviewEdge(.Top, withInset: 70)
        collectionView.autoPinEdgeToSuperviewEdge(.Left)
        collectionView.autoPinEdgeToSuperviewEdge(.Right)
        collectionView.autoPinEdgeToSuperviewEdge(.Bottom)

        loadingIndicatorView.autoAlignAxisToSuperviewAxis(.Vertical)
        loadingIndicatorView.autoAlignAxis(.Horizontal, toSameAxisOfView: view, withOffset: -20)

        errorLabel.autoAlignAxis(.Horizontal, toSameAxisOfView: view, withOffset: -120)
        errorLabel.autoAlignAxisToSuperviewAxis(.Vertical)

        retryButton.autoPinEdgeToSuperviewEdge(.Left)
        retryButton.autoPinEdgeToSuperviewEdge(.Right)
        retryButton.autoAlignAxis(.Horizontal, toSameAxisOfView: view)
        retryButton.autoSetDimension(.Height, toSize: 54)

        connectLogoImageView.autoAlignAxisToSuperviewAxis(.Vertical)

        let screen = UIScreen.mainScreen()
        let bigDevice = screen.bounds.height >= 667
        let bottomOffset: CGFloat = bigDevice ? 82 : 72
        connectLogoImageView.autoPinEdgeToSuperviewEdge(.Bottom, withInset: bottomOffset)
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

            self.view.addSubview(webView)

            // this is because the facebook embed code isn't responsive - we need to render it with the correct width
            // such that we work around its margins

            let webViewWidth = UIScreen.mainScreen().bounds.width - 10
            webView.autoSetDimension(.Width, toSize: webViewWidth)

            if actionAlert.isFacebookVideo() {
                webView.autoSetDimension(.Height, toSize: 205)
            } else {
                webView.autoSetDimension(.Height, toSize: 300)
            }

            webView.autoCenterInSuperview()

            self.webViews.append(webView)
        }

        self.actionAlertLoadingMonitor.waitUntilWebViewsHaveLoaded(self.webViews) {
            for webView in self.webViews {
                let removeIFrameMarginHack = "var i = document.documentElement.getElementsByTagName('iframe'); for (var j = 0 ; j < i.length ; j++ ) { k = i[j]; k.style.marginTop = '0px';  }"
                webView.stringByEvaluatingJavaScriptFromString(removeIFrameMarginHack)
            }

            self.collectionView.reloadData()
            self.collectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0), atScrollPosition: .CenteredHorizontally, animated: false)

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
            fatalError("Badly configured collection view 💩")
        }

        for view in cell.webviewContainer.subviews {
            view.removeFromSuperview()
        }

        if webViews.count == 0 || indexPath.item > webViews.count - 1 {
            return cell
        }

        let webView = webViews[indexPath.item]
        webView.removeConstraints(webView.constraints)
        webView.alpha = 1

        let actionAlert = actionAlerts[indexPath.item]
        cell.titleLabel.text = actionAlert.title
        cell.shortDescriptionText = actionAlert.shortDescription

        cell.webviewContainer.addSubview(webView)
        webView.autoPinEdgesToSuperviewEdges()

        let heightString = webView.stringByEvaluatingJavaScriptFromString("var iframes = document.getElementsByTagName('iframe') ; var heights = [] ; for(var i = 0; i < iframes.length ; i++) { if(iframes[i].name == 'fb_xdm_frame_https') { continue; } heights.push(iframes[i].scrollHeight); } var maxIframeHeight = Math.max.apply(null, heights); if ( maxIframeHeight > 0 ) { maxIframeHeight } else { Math.min(document.documentElement.scrollHeight, document.documentElement.offsetHeight, document.documentElement.clientHeight ); }")

        let heightDouble = heightString != nil ? Double(heightString!) : 0.0
        let heightFloat: CGFloat = heightDouble != nil ? CGFloat(heightDouble!) : 0.0

        cell.webViewHeight = actionAlert.isFacebookPost() ?  heightFloat - 21 : heightFloat

        cell.titleLabel.font = theme.actionsTitleFont()
        cell.titleLabel.textColor = theme.actionsTitleTextColor()
        cell.shortDescriptionLabel.font = theme.actionsShortDescriptionFont()
        cell.shortDescriptionLabel.textColor = theme.actionsShortDescriptionTextColor()
        cell.activityIndicatorView.color = theme.defaultSpinnerColor()
        cell.shareButton.titleLabel!.font = theme.actionsShareButtonFont()

        let title = NSAttributedString(
            string: NSLocalizedString("Actions_shareButtonTitle", comment: ""),
            attributes: [
                NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue,
                NSForegroundColorAttributeName: theme.actionsShareButtonTextColor()
            ])

        cell.shareButton.setAttributedTitle(title, forState: .Normal)
        cell.shareButtonVisible = (actionAlert.shareURL() != nil)
        cell.shareButton.addTarget(self, action: #selector(ActionAlertsController.didTapShareButton), forControlEvents: .TouchUpInside)

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

    func scrollViewDidScroll(scrollView: UIScrollView) {
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
        guard let url = request.URL else {
            return false
        }

        if navigationType == .Other && url.absoluteString.rangeOfString("https://twitter.com/\\w+/status/\\d+", options: .RegularExpressionSearch) != nil {
            trackLinkClick(url)
            urlOpener.openURL(url)
            return false
        }

        if navigationType != .LinkClicked {
            return true
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

// MARK: Actions

extension ActionAlertsController {
    func didTapInfoButton() {
        navigationController?.pushViewController(moreController, animated: true)
        analyticsService.trackCustomEventWithName("User tapped info button on action alerts", customAttributes: nil)
    }

    func didTapShareButton() {
        let actionAlert = actionAlerts[pageControl.currentPage]

        guard let url = actionAlert.shareURL() else {
            return
        }

        let attributes = [
            AnalyticsServiceConstants.contentIDKey: actionAlert.identifier,
            AnalyticsServiceConstants.contentNameKey: actionAlert.title,
            AnalyticsServiceConstants.contentTypeKey: "Action Alert - Facebook Video"
        ]

        analyticsService.trackCustomEventWithName("Began Share", customAttributes: attributes)

        urlOpener.openURL(url)
    }
}

// swiftlint:enable type_body_length
// swiftlint:enable file_length
