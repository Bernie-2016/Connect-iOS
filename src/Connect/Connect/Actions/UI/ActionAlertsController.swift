import UIKit

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

        collectionView.showsHorizontalScrollIndicator = false
        collectionView.decelerationRate = UIScrollViewDecelerationRateFast
        collectionView.clipsToBounds = false
        collectionView.hidden = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.registerClass(ActionAlertCell.self, forCellWithReuseIdentifier: kCollectionViewCellName)

        let backgroundImageView = UIImageView(image: UIImage(named: "actionAlertsBackground")!)
        backgroundImageView.contentMode = .ScaleAspectFill
        collectionView.backgroundView = backgroundImageView

        loadingIndicatorView.startAnimating()

        applyTheme()
        setupConstraints()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: false)

        pageControl.hidden = true
        loadingIndicatorView.hidden = false
        collectionView.hidden = true
        let webViewWidth = UIScreen.mainScreen().bounds.width - 10

        let future = actionAlertService.fetchActionAlerts()

        webViews.removeAll()

        future.then { actionAlerts in
            self.actionAlerts = actionAlerts

            for actionAlert in actionAlerts {
                let webView = self.actionAlertWebViewProvider.provideInstanceWithBody(actionAlert.body, width: webViewWidth)

                webView.hidden = true
                webView.layer.cornerRadius = 4.0
                webView.layer.masksToBounds = true
                webView.clipsToBounds = true
                webView.opaque = false
                webView.backgroundColor = UIColor.clearColor()
                webView.scrollView.showsVerticalScrollIndicator = false
                webView.delegate = self
                webView.scrollView.scrollEnabled = false

                // this is because the facebook embed code isn't responsive - we need to render it with the correct width
                // such that we work around its margins
                let webViewWidth = UIScreen.mainScreen().bounds.width - 20
                webView.autoSetDimension(.Width, toSize: webViewWidth)
                webView.autoSetDimension(.Height, toSize: 1)


                self.view.addSubview(webView)
                self.webViews.append(webView)
            }

            self.actionAlertLoadingMonitor.waitUntilWebViewsHaveLoaded(self.webViews) {
                for webView in self.webViews {
                    let removeIFrameMarginHack = "var i = document.documentElement.getElementsByTagName('iframe'); for (var j = 0 ; j < i.length ; j++ ) { k = i[j]; k.style.marginTop = '0px'; }"
                    webView.stringByEvaluatingJavaScriptFromString(removeIFrameMarginHack)
                }

                self.collectionView.reloadData()

                UIView.transitionWithView(self.view, duration: 0.3, options: .TransitionCrossDissolve, animations: {
                    self.pageControl.numberOfPages = self.actionAlerts.count
                    self.pageControl.hidden = false
                    self.collectionView.hidden = false
                    self.loadingIndicatorView.hidden = true
                    }, completion: { completed in })
            }
        }

        layout.invalidateLayout()
    }

    private func applyTheme() {
        view.backgroundColor = theme.actionsBackgroundColor()
        loadingIndicatorView.color = theme.defaultSpinnerColor()
    }

    private func setupConstraints() {
        collectionView.autoPinEdge(.Top, toEdge: .Top, ofView: view)
        collectionView.autoPinEdge(.Left, toEdge: .Left, ofView: view)
        collectionView.autoPinEdge(.Right, toEdge: .Right, ofView: view)
        collectionView.autoPinEdge(.Bottom, toEdge: .Bottom, ofView: view)

        loadingIndicatorView.autoCenterInSuperview()

        pageControl.autoAlignAxisToSuperviewAxis(.Vertical)
        pageControl.autoPinEdgeToSuperviewEdge(.Bottom, withInset: -10)
    }
}

extension ActionAlertsController: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return actionAlerts.count
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
        webView.hidden = false

        cell.titleLabel.text = actionAlerts[indexPath.item].title
        cell.webviewContainer.addSubview(webView)
        webView.autoPinEdgesToSuperviewEdges()

        let heightString = webView.stringByEvaluatingJavaScriptFromString("Math.max( document.documentElement.scrollHeight, document.documentElement.offsetHeight, document.documentElement.clientHeight);")

        let heightDouble = heightString != nil ? Double(heightString!) : 0.0
        let heightFloat: CGFloat = heightDouble != nil ? CGFloat(heightDouble!) : 0.0

        cell.webViewHeight = heightFloat

        cell.titleLabel.font = theme.actionsTitleFont()
        cell.titleLabel.textColor = theme.actionsTitleTextColor()

        return cell
    }
}

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
