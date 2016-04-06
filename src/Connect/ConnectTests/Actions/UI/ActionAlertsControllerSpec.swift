import Quick
import Nimble

@testable import Connect

class ActionAlertsControllerSpec: QuickSpec {
    override func spec() {
        describe("ActionAlertsController") {
            var subject: ActionAlertsController!
            var actionAlertService: FakeActionAlertService!
            var actionAlertWebViewProvider: FakeActionAlertWebViewProvider!
            var actionAlertLoadingMonitor: FakeActionAlertLoadingMonitor!
            var urlOpener: FakeURLOpener!
            var moreController: UIViewController!
            var analyticsService: FakeAnalyticsService!
            var tabBarItemStylist: FakeTabBarItemStylist!
            let theme = ActionAlertsControllerFakeTheme()

            var navigationController: UINavigationController!

            beforeEach {
                actionAlertService = FakeActionAlertService()
                actionAlertWebViewProvider = FakeActionAlertWebViewProvider()
                actionAlertLoadingMonitor = FakeActionAlertLoadingMonitor()
                urlOpener = FakeURLOpener()
                moreController = UIViewController()
                analyticsService = FakeAnalyticsService()
                tabBarItemStylist = FakeTabBarItemStylist()

                subject = ActionAlertsController(
                    actionAlertService: actionAlertService,
                    actionAlertWebViewProvider: actionAlertWebViewProvider,
                    actionAlertLoadingMonitor: actionAlertLoadingMonitor,
                    urlOpener: urlOpener,
                    moreController: moreController,
                    analyticsService: analyticsService,
                    tabBarItemStylist: tabBarItemStylist,
                    theme: theme
                )

                navigationController = UINavigationController()
                navigationController.pushViewController(subject, animated: false)
            }

            it("has the correct title") {
                subject.view.layoutSubviews()

                expect(subject.tabBarItem.title).to(equal("Act Now"))
            }

            it("uses the tab bar item stylist to style its tab bar item") {
                expect(tabBarItemStylist.lastReceivedTabBarItem).to(beIdenticalTo(subject.tabBarItem))

                expect(tabBarItemStylist.lastReceivedTabBarImage).to(equal(UIImage(named: "actionsTabBarIconInactive")))
                expect(tabBarItemStylist.lastReceivedTabBarSelectedImage).to(equal(UIImage(named: "actionsTabBarIcon")))
            }

            describe("when the view first loads") {
                it("adds the collection view as a subview") {
                    subject.view.layoutSubviews()

                    expect(subject.view.subviews).to(contain(subject.collectionView))
                }

                it("has the spinner as a subview") {
                    subject.view.layoutSubviews()

                    expect(subject.view.subviews).to(contain(subject.loadingIndicatorView))
                }

                it("adds the page control as a subview") {
                    subject.view.layoutSubviews()

                    expect(subject.view.subviews).to(contain(subject.pageControl))
                }

                it("adds the error message as a subview") {
                    subject.view.layoutSubviews()

                    expect(subject.view.subviews).to(contain(subject.errorLabel))
                }

                it("adds the retry button as a subview") {
                    subject.view.layoutSubviews()

                    expect(subject.view.subviews).to(contain(subject.retryButton))
                }

                it("adds the logo as a subview") {
                    subject.view.layoutSubviews()

                    expect(subject.view.subviews).to(contain(subject.connectLogoImageView))
                }

                it("styles the spinner with the theme") {
                    subject.view.layoutSubviews()

                    expect(subject.loadingIndicatorView.color) == UIColor.greenColor()
                }

                it("styles the loading message with the theme") {
                    subject.view.layoutSubviews()

                    expect(subject.loadingMessageLabel.textColor) == UIColor.blueColor()
                    expect(subject.loadingMessageLabel.font) == UIFont.systemFontOfSize(333)
                }

                it("styles the error message with the theme") {
                    subject.view.layoutSubviews()

                    expect(subject.errorLabel.textColor) == UIColor.brownColor()
                    expect(subject.errorLabel.font) == UIFont.systemFontOfSize(444)
                }

                it("styles the retry button with the theme") {
                    subject.view.layoutSubviews()

                    expect(subject.retryButton.titleColorForState(.Normal)) == UIColor.redColor()
                    expect(subject.retryButton.backgroundColor) == UIColor.purpleColor()
                    expect(subject.retryButton.titleLabel!.font) ==  UIFont.systemFontOfSize(444)
                }

                it("styles the page control with the theme") {
                    subject.view.layoutSubviews()

                    expect(subject.pageControl.currentPageIndicatorTintColor) == UIColor.whiteColor()
                    expect(subject.pageControl.pageIndicatorTintColor) == UIColor.lightGrayColor()
                }

                it("sets the retry button text correctly") {
                    subject.view.layoutSubviews()

                    expect(subject.retryButton.titleForState(.Normal)) == "RETRY"
                }

                it("adds the loading message as a subview") {
                    subject.view.layoutSubviews()

                    expect(subject.view.subviews).to(contain(subject.loadingMessageLabel))
                }

                it("sets the correct text for the loading message") {
                    subject.view.layoutSubviews()

                    expect(subject.loadingMessageLabel.text) == "Amplify Bernie's Message by Sharing!"
                }

                it("animates the spinner") {
                    subject.view.layoutSubviews()

                    expect(subject.loadingIndicatorView.isAnimating()) == true
                }

                it("sets the background color with the theme") {
                    subject.view.layoutSubviews()

                    expect(subject.view.backgroundColor) == UIColor.yellowColor()
                }

                it("sets the view's background image") {
                    subject.view.layoutSubviews()

                    let backgroundImageView = subject.backgroundImageView
                    expect(backgroundImageView.image) == UIImage(named: "actionAlertsBackground")
                }

                it("sets the correct logo image") {
                    subject.view.layoutSubviews()

                    let connectLogoImageView = subject.connectLogoImageView
                    expect(connectLogoImageView.image) == UIImage(named: "connectLogo")!
                }

                it("has the info button as a subview") {
                    subject.view.layoutSubviews()

                    expect(subject.view.subviews).to(contain(subject.infoButton))
                }

                it("styles the info button with the theme") {
                    subject.view.layoutSubviews()

                    expect(subject.infoButton.tintColor) == UIColor.darkGrayColor()
                }

                it("should set the back bar button item title correctly") {
                    subject.view.layoutSubviews()

                    expect(subject.navigationItem.backBarButtonItem?.title) == ""
                }
            }

            describe("when the view appears") {
                beforeEach {
                    subject.view.layoutSubviews()
                }

                it("hides the collection view") {
                    subject.collectionView.hidden = false

                    subject.viewWillAppear(false)

                    expect(subject.collectionView.hidden) == true
                }

                it("hides the page control") {
                    subject.pageControl.hidden = false

                    subject.viewWillAppear(false)

                    expect(subject.pageControl.hidden) == true
                }

                it("shows the spinner") {
                    subject.loadingIndicatorView.hidden = true

                    subject.viewWillAppear(false)

                    expect(subject.loadingIndicatorView.hidden) == false
                }

                it("shows the loading message") {
                    subject.loadingMessageLabel.hidden = true

                    subject.viewWillAppear(false)

                    expect(subject.loadingMessageLabel.hidden) == false
                }

                it("hides the error message") {
                    subject.errorLabel.hidden = false

                    subject.viewWillAppear(false)

                    expect(subject.errorLabel.hidden) == true
                }

                it("hides the retry button") {
                    subject.retryButton.hidden = false

                    subject.viewWillAppear(false)

                    expect(subject.retryButton.hidden) == true
                }

                it("makes a request to the action alert service") {
                    expect(actionAlertService.fetchActionAlertsCalled) == false

                    subject.viewWillAppear(false)

                    expect(actionAlertService.fetchActionAlertsCalled) == true
                }

                describe("loading the action alerts") {
                    beforeEach {
                        subject.viewWillAppear(false)
                        subject.collectionView.numberOfItemsInSection(0)
                    }

                    itBehavesLike("an event that triggers an update of action alerts") { [
                        "subject": subject,
                        "actionAlertService": actionAlertService,
                        "actionAlertWebViewProvider": actionAlertWebViewProvider,
                        "actionAlertLoadingMonitor": actionAlertLoadingMonitor
                        ] }
                }
            }

            describe("tapping on the retry button") {
                beforeEach {
                    subject.view.layoutSubviews()
                }

                it("shows the spinner") {
                    subject.loadingIndicatorView.hidden = true

                    subject.retryButton.tap()

                    expect(subject.loadingIndicatorView.hidden) == false
                }

                it("shows the loading message") {
                    subject.loadingMessageLabel.hidden = true

                    subject.retryButton.tap()

                    expect(subject.loadingMessageLabel.hidden) == false
                }

                it("hides the error message") {
                    subject.errorLabel.hidden = false

                    subject.retryButton.tap()

                    expect(subject.errorLabel.hidden) == true
                }

                it("hides the retry button") {
                    subject.retryButton.hidden = false

                    subject.retryButton.tap()

                    expect(subject.retryButton.hidden) == true
                }

                describe("fetching the action alerts") {
                    beforeEach {
                        subject.retryButton.tap()
                    }

                    itBehavesLike("an event that triggers an update of action alerts") { [
                        "subject": subject,
                        "actionAlertService": actionAlertService,
                        "actionAlertWebViewProvider": actionAlertWebViewProvider,
                        "actionAlertLoadingMonitor": actionAlertLoadingMonitor
                        ] }
                }
            }

            describe("tapping the info button") {
                beforeEach { subject.view.layoutSubviews() }

                it("pushes the more view controller") {
                    subject.infoButton.tap()

                    expect(navigationController.topViewController) === moreController
                }

                it("logs an event to the analytics service") {
                    subject.infoButton.tap()

                    expect(analyticsService.lastCustomEventName).to(equal("User tapped info button on action alerts"))
                }
            }

            describe("the collection view") {
                let actionAlertA = TestUtils.actionAlert("Alert A", shortDescription: "Short Desc A")
                let actionAlertB = TestUtils.actionAlert("Alert B", shortDescription: "")

                beforeEach {
                    subject.view.layoutSubviews()
                    subject.viewWillAppear(false)
                    actionAlertService.lastReturnedActionAlertsPromise.resolve([actionAlertA, actionAlertB])
                }

                it("has one section") {
                    actionAlertLoadingMonitor.lastCompletionHandler!()

                    expect(subject.collectionView.numberOfSections()) == 1
                }

                it("has an item per action alert") {
                    actionAlertLoadingMonitor.lastCompletionHandler!()

                    expect(subject.collectionView.numberOfItemsInSection(0)) == 2
                }

                it("sets the title of the action alert cell with the action alert") {
                    actionAlertLoadingMonitor.lastCompletionHandler!()

                    guard let cell = subject.collectionView.dataSource?.collectionView(subject.collectionView, cellForItemAtIndexPath: NSIndexPath(forItem: 0, inSection: 0)) as? ActionAlertCell else {
                        fail("Unable to get cell")
                        return
                    }

                    expect(cell.titleLabel.text) == "Alert A"
                }

                it("sets the short description") {
                    actionAlertLoadingMonitor.lastCompletionHandler!()

                    guard let cell = subject.collectionView.dataSource?.collectionView(subject.collectionView, cellForItemAtIndexPath: NSIndexPath(forItem: 0, inSection: 0)) as? ActionAlertCell else {
                        fail("Unable to get cell")
                        return
                    }

                    expect(cell.shortDescriptionLabel.text) == "Short Desc A"
                }

                it("makes the web view visible and adds it as a subview of the cell") {
                    actionAlertLoadingMonitor.lastCompletionHandler!()

                    guard let cell = subject.collectionView.dataSource?.collectionView(subject.collectionView, cellForItemAtIndexPath: NSIndexPath(forItem: 0, inSection: 0)) as? ActionAlertCell else {
                        fail("Unable to get cell")
                        return
                    }

                    let expectedWebView = actionAlertWebViewProvider.returnedWebViews[0]
                    expect(cell.webviewContainer.subviews).to(contain(expectedWebView))
                    expect(expectedWebView.alpha) == 1
                }

                it("removes the web view from the controller's view") {
                    actionAlertLoadingMonitor.lastCompletionHandler!()
                    subject.collectionView.dataSource?.collectionView(subject.collectionView, cellForItemAtIndexPath: NSIndexPath(forItem: 0, inSection: 0))

                    let webViews = actionAlertWebViewProvider.returnedWebViews
                    expect(webViews.count) == 2

                    expect(subject.view.subviews.contains(webViews[0])) == false
                }

                it("styles the cell with the theme") {
                    actionAlertLoadingMonitor.lastCompletionHandler!()
                    guard let cell = subject.collectionView.dataSource?.collectionView(subject.collectionView, cellForItemAtIndexPath: NSIndexPath(forItem: 0, inSection: 0)) as? ActionAlertCell else {
                        fail("Unable to get cell")
                        return
                    }

                    expect(cell.titleLabel.font) == UIFont.systemFontOfSize(111)
                    expect(cell.titleLabel.textColor) == UIColor.magentaColor()
                    expect(cell.shortDescriptionLabel.font) == UIFont.systemFontOfSize(222)
                    expect(cell.shortDescriptionLabel.textColor) == UIColor.orangeColor()
                    expect(cell.activityIndicatorView.color) == UIColor.greenColor()
                }
            }


            describe("webview behavior") {
                let actionAlert = TestUtils.actionAlert("Alert A", body: "Alert Body A")
                let expectedURL = NSURL(string: "https://example.com")!
                let urlRequest = NSURLRequest(URL: expectedURL)

                beforeEach {
                    subject.view.layoutSubviews()
                    subject.viewWillAppear(false)
                    actionAlertService.lastReturnedActionAlertsPromise.resolve([actionAlert])

                    subject.pageControl.currentPage = 0 // laziness strikes
                }

                describe("tapping a link") {
                    it("opens the link in safari") {
                        let webView = actionAlertWebViewProvider.returnedWebViews[0]

                        webView.delegate?.webView!(webView, shouldStartLoadWithRequest: urlRequest, navigationType: .LinkClicked)

                        expect(urlOpener.lastOpenedURL) == expectedURL
                    }

                    it("prevents the link being followed in the web view") {
                        let webView = actionAlertWebViewProvider.returnedWebViews[0]

                        let result = webView.delegate?.webView!(webView, shouldStartLoadWithRequest: urlRequest, navigationType: .LinkClicked)

                        expect(result) == false
                    }

                    context("when that link is to share on facebook") {
                        it("tracks the share via the analytics service") {
                            let fbShareRequest = NSURLRequest(URL: NSURL(string: "https://m.facebook.com/sharer.php?fs=0&sid=1004277179627286&locale2=en_US")!)
                            let webView = actionAlertWebViewProvider.returnedWebViews[0]

                            webView.delegate?.webView!(webView, shouldStartLoadWithRequest: fbShareRequest, navigationType: .LinkClicked)


                            expect(analyticsService.lastCustomEventName).to(equal("Began Share"))
                            let expectedAttributes = [
                                AnalyticsServiceConstants.contentIDKey: actionAlert.identifier,
                                AnalyticsServiceConstants.contentNameKey: actionAlert.title,
                                AnalyticsServiceConstants.contentTypeKey: "Action Alert - Facebook",
                            ]
                            expect(analyticsService.lastCustomEventAttributes! as? [String: String]).to(equal(expectedAttributes))
                        }
                    }

                    context("when that link is to tweet on twitter") {
                        it("tracks the share via the analytics service") {
                            let tweetRequest = NSURLRequest(URL: NSURL(string: "https://twitter.com/intent/tweet?in_reply_to=700796414750695424&ref_src=twsrc%5Etfw&original_referer=https%3A%2F%2Fsanders-connect-staging.herokuapp.com%2F&tw_i=700796414750695424&tw_p=tweetembed")!)
                            let webView = actionAlertWebViewProvider.returnedWebViews[0]

                            webView.delegate?.webView!(webView, shouldStartLoadWithRequest: tweetRequest, navigationType: .LinkClicked)


                            expect(analyticsService.lastCustomEventName).to(equal("Began Share"))
                            let expectedAttributes = [
                                AnalyticsServiceConstants.contentIDKey: actionAlert.identifier,
                                AnalyticsServiceConstants.contentNameKey: actionAlert.title,
                                AnalyticsServiceConstants.contentTypeKey: "Action Alert - Tweet"
                            ]
                            expect(analyticsService.lastCustomEventAttributes! as? [String: String]).to(equal(expectedAttributes))
                        }
                    }

                    context("when that link is to retweet on twitter") {
                        it("tracks the share via the analytics service") {
                            let retweetRequest = NSURLRequest(URL: NSURL(string: "https://twitter.com/intent/retweet?tweet_id=700796414750695424&ref_src=twsrc%5Etfw&original_referer=https%3A%2F%2Fsanders-connect-staging.herokuapp.com%2F&tw_i=700796414750695424&tw_p=tweetembedd")!)
                            let webView = actionAlertWebViewProvider.returnedWebViews[0]

                            webView.delegate?.webView!(webView, shouldStartLoadWithRequest: retweetRequest, navigationType: .LinkClicked)


                            expect(analyticsService.lastCustomEventName).to(equal("Began Share"))
                            let expectedAttributes = [
                                AnalyticsServiceConstants.contentIDKey: actionAlert.identifier,
                                AnalyticsServiceConstants.contentNameKey: actionAlert.title,
                                AnalyticsServiceConstants.contentTypeKey: "Action Alert - Retweet"
                            ]
                            expect(analyticsService.lastCustomEventAttributes! as? [String: String]).to(equal(expectedAttributes))
                        }
                    }

                    context("when that link is to link on twitter") {
                        it("tracks the share via the analytics service") {
                            let retweetRequest = NSURLRequest(URL: NSURL(string: "https://twitter.com/intent/like?tweet_id=700796414750695424&ref_src=twsrc%5Etfw&original_referer=https%3A%2F%2Fsanders-connect-staging.herokuapp.com%2F&tw_i=700796414750695424&tw_p=tweetembed")!)
                            let webView = actionAlertWebViewProvider.returnedWebViews[0]

                            webView.delegate?.webView!(webView, shouldStartLoadWithRequest: retweetRequest, navigationType: .LinkClicked)


                            expect(analyticsService.lastCustomEventName).to(equal("Began Share"))
                            let expectedAttributes = [
                                AnalyticsServiceConstants.contentIDKey: actionAlert.identifier,
                                AnalyticsServiceConstants.contentNameKey: actionAlert.title,
                                AnalyticsServiceConstants.contentTypeKey: "Action Alert - Like Tweet"
                            ]
                            expect(analyticsService.lastCustomEventAttributes! as? [String: String]).to(equal(expectedAttributes))
                        }
                    }

                    context("when that link is to anywhere else") {
                        it("tracks the share via the analytics service") {
                            let retweetRequest = NSURLRequest(URL: NSURL(string: "https://berniesanders.com")!)
                            let webView = actionAlertWebViewProvider.returnedWebViews[0]

                            webView.delegate?.webView!(webView, shouldStartLoadWithRequest: retweetRequest, navigationType: .LinkClicked)


                            expect(analyticsService.lastCustomEventName).to(equal("Began Share"))
                            let expectedAttributes = [
                                AnalyticsServiceConstants.contentIDKey: actionAlert.identifier,
                                AnalyticsServiceConstants.contentNameKey: actionAlert.title,
                                AnalyticsServiceConstants.contentTypeKey: "Action Alert - Followed Other Link",
                                AnalyticsServiceConstants.contentURLKey: retweetRequest.URL!.absoluteString
                            ]
                            expect(analyticsService.lastCustomEventAttributes! as? [String: String]).to(equal(expectedAttributes))
                        }
                    }
                }

                describe("other url loading") {
                    it("allows the link to be loaded") {
                        let webView = actionAlertWebViewProvider.returnedWebViews[0]

                        let navigationTypes: [UIWebViewNavigationType] = [.BackForward, .FormResubmitted, .FormSubmitted, .Other, .Reload]

                        for navigationType in navigationTypes {
                            let result = (webView.delegate?.webView!(webView, shouldStartLoadWithRequest: urlRequest, navigationType: navigationType))!

                            expect(result) == true
                        }

                    }
                }
            }
        }
    }
}

class ActionAlertsSharedExamplesConfiguration: QuickConfiguration {
    override class func configure(configuration: Configuration) {
        sharedExamples("an event that triggers an update of action alerts") { (sharedExampleContext: SharedExampleContext) in
            var subject: ActionAlertsController!
            var actionAlertService: FakeActionAlertService!
            var actionAlertWebViewProvider: FakeActionAlertWebViewProvider!
            var actionAlertLoadingMonitor: FakeActionAlertLoadingMonitor!

            beforeEach {
                subject = sharedExampleContext()["subject"] as! ActionAlertsController
                actionAlertService = sharedExampleContext()["actionAlertService"] as! FakeActionAlertService!
                actionAlertWebViewProvider = sharedExampleContext()["actionAlertWebViewProvider"] as! FakeActionAlertWebViewProvider!
                actionAlertLoadingMonitor = sharedExampleContext()["actionAlertLoadingMonitor"] as! FakeActionAlertLoadingMonitor!
            }

            describe("when using the action alerts service") {
                context("when the service resolves its promise with some action alerts") {
                    let actionAlertA = TestUtils.actionAlert("Alert A", body: "Alert Body A")
                    let actionAlertB = TestUtils.actionAlert("Alert B", body: "Alert Body B")

                    it("adds an invisible (not hidden) web view to the controller's view for each action alert, using the provider") {
                        // this is a hack to load content before we show them in the collection view
                        actionAlertService.lastReturnedActionAlertsPromise.resolve([actionAlertA, actionAlertB])

                        expect(actionAlertWebViewProvider.receivedBodies) == ["Alert Body A", "Alert Body B"]

                        let webViews = actionAlertWebViewProvider.returnedWebViews
                        expect(webViews.count) == 2

                        expect(webViews[0].alpha) == 0
                        expect(webViews[1].alpha) == 0

                        expect(subject.view.subviews.contains(webViews[0])) == true
                        expect(subject.view.subviews.contains(webViews[1])) == true
                    }

                    it("waits until all the webviews have loaded") {
                        actionAlertService.lastReturnedActionAlertsPromise.resolve([actionAlertA, actionAlertB])

                        let webViews = actionAlertWebViewProvider.returnedWebViews
                        expect(webViews.count) == 2

                        guard let receivedWebViews = actionAlertLoadingMonitor.receivedWebViews else {
                            fail("No monitored web views")
                            return
                        }

                        expect(receivedWebViews.count) == 2
                        expect(receivedWebViews[0]) === webViews[0]
                        expect(receivedWebViews[1]) === webViews[1]
                    }

                    describe("when the webviews have all loaded") {
                        beforeEach {
                            actionAlertService.lastReturnedActionAlertsPromise.resolve([actionAlertA, actionAlertB])
                        }

                        it("sets the page control count") {
                            actionAlertLoadingMonitor.lastCompletionHandler!()

                            expect(subject.pageControl.numberOfPages) == 2
                        }

                        it("shows the page control") {
                            subject.pageControl.hidden = true

                            actionAlertLoadingMonitor.lastCompletionHandler!()

                            expect(subject.pageControl.hidden) == false
                        }

                        it("hides the loading message") {
                            subject.loadingIndicatorView.hidden = false

                            actionAlertLoadingMonitor.lastCompletionHandler!()

                            expect(subject.loadingMessageLabel.hidden) == true
                        }

                        it("hides the spinner") {
                            actionAlertLoadingMonitor.lastCompletionHandler!()

                            expect(subject.loadingIndicatorView.hidden) == true
                        }

                        it("shows the collection view") {
                            actionAlertLoadingMonitor.lastCompletionHandler!()

                            expect(subject.collectionView.hidden) == false
                        }

                        it("reloads the collection view") {
                            actionAlertLoadingMonitor.lastCompletionHandler!()

                            expect(subject.collectionView.dataSource?.collectionView(subject.collectionView, numberOfItemsInSection: 0)) == 2
                        }
                    }
                }

                context("when the service resolves its promise with zero action alerts") {
                    it("hides the loading message") {
                        subject.loadingIndicatorView.hidden = false

                        actionAlertService.lastReturnedActionAlertsPromise.resolve([])

                        expect(subject.loadingMessageLabel.hidden) == true
                    }

                    it("hides the spinner") {
                        actionAlertService.lastReturnedActionAlertsPromise.resolve([])

                        expect(subject.loadingIndicatorView.hidden) == true
                    }

                    it("shows the error message") {
                        subject.errorLabel.hidden = true

                        actionAlertService.lastReturnedActionAlertsPromise.resolve([])

                        expect(subject.errorLabel.hidden) == false
                    }

                    it("shows the retry button") {
                        subject.retryButton.hidden = true

                        actionAlertService.lastReturnedActionAlertsPromise.resolve([])

                        expect(subject.retryButton.hidden) == false
                    }

                    it("has the correct text in the error label") {
                        actionAlertService.lastReturnedActionAlertsPromise.resolve([])

                        expect(subject.errorLabel.text) == "There's nothing for you to share right now. Check back later!"
                    }
                }

                context("when the service rejects its promise with an error") {
                    it("hides the loading message") {
                        subject.loadingMessageLabel.hidden = false

                        actionAlertService.lastReturnedActionAlertsPromise.reject(ActionAlertRepositoryError.InvalidJSON(jsonObject: []))

                        expect(subject.loadingMessageLabel.hidden) == true
                    }

                    it("hides the spinner") {
                        subject.loadingIndicatorView.hidden = false


                        actionAlertService.lastReturnedActionAlertsPromise.reject(ActionAlertRepositoryError.InvalidJSON(jsonObject: []))

                        expect(subject.loadingIndicatorView.hidden) == true
                    }

                    it("shows the error message") {
                        subject.errorLabel.hidden = true

                        actionAlertService.lastReturnedActionAlertsPromise.reject(ActionAlertRepositoryError.InvalidJSON(jsonObject: []))

                        expect(subject.errorLabel.hidden) == false
                    }

                    it("shows the retry button") {
                        subject.retryButton.hidden = true

                        actionAlertService.lastReturnedActionAlertsPromise.reject(ActionAlertRepositoryError.InvalidJSON(jsonObject: []))

                        expect(subject.retryButton.hidden) == false
                    }

                    it("has the correct text in the error label") {
                        actionAlertService.lastReturnedActionAlertsPromise.reject(ActionAlertRepositoryError.InvalidJSON(jsonObject: []))

                        expect(subject.errorLabel.text) == "An error occurred while loading this content."
                    }
                }
            }
        }
    }
}

private class ActionAlertsControllerFakeTheme: FakeTheme {
    override func defaultSpinnerColor() -> UIColor { return UIColor.greenColor() }
    override func actionsBackgroundColor() -> UIColor { return UIColor.yellowColor() }
    override func actionsTitleFont() -> UIFont { return UIFont.systemFontOfSize(111) }
    override func actionsTitleTextColor() -> UIColor { return UIColor.magentaColor() }
    override func actionsShortDescriptionFont() -> UIFont { return UIFont.systemFontOfSize(222) }
    override func actionsShortDescriptionTextColor() -> UIColor { return UIColor.orangeColor() }
    override func actionsShortLoadingMessageFont() -> UIFont { return UIFont.systemFontOfSize(333) }
    override func actionsShortLoadingMessageTextColor() -> UIColor { return UIColor.blueColor() }
    override func actionsErrorMessageFont() -> UIFont { return UIFont.systemFontOfSize(444) }
    override func actionsErrorMessageTextColor() -> UIColor { return UIColor.brownColor() }
    override func fullWidthButtonBackgroundColor() -> UIColor { return UIColor.purpleColor() }
    override func fullWidthRSVPButtonTextColor() -> UIColor { return UIColor.redColor() }
    override func fullWidthRSVPButtonFont() -> UIFont { return UIFont.systemFontOfSize(444) }
    override func defaultCurrentPageIndicatorTintColor() -> UIColor { return UIColor.whiteColor() }
    override func defaultPageIndicatorTintColor() -> UIColor { return UIColor.lightGrayColor() }
    override func actionsInfoButtonTintColor() -> UIColor { return UIColor.darkGrayColor() }
}

private class FakeActionAlertWebViewProvider: ActionAlertWebViewProvider {
    var returnedWebViews: [UIWebView] = []
    var receivedBodies: [String] = []
    var receivedWidths: [CGFloat] = []
    func provideInstanceWithBody(body: String, width: CGFloat) -> UIWebView {
        receivedBodies.append(body)
        receivedWidths.append(width)
        returnedWebViews.append(UIWebView())

        return returnedWebViews.last!
    }
}

private class FakeActionAlertLoadingMonitor: ActionAlertLoadingMonitor {
    var receivedWebViews: [UIWebView]?
    var lastCompletionHandler: (() -> ())?

    func waitUntilWebViewsHaveLoaded(webViews: [UIWebView], completionHandler: () -> ()) {
        receivedWebViews = webViews
        lastCompletionHandler = completionHandler
    }
}
