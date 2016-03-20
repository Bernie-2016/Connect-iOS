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
            var analyticsService: FakeAnalyticsService!
            var tabBarItemStylist: FakeTabBarItemStylist!
            let theme = ActionAlertsControllerFakeTheme()

            var navigationController: UINavigationController!

            beforeEach {
                actionAlertService = FakeActionAlertService()
                actionAlertWebViewProvider = FakeActionAlertWebViewProvider()
                actionAlertLoadingMonitor = FakeActionAlertLoadingMonitor()
                urlOpener = FakeURLOpener()
                analyticsService = FakeAnalyticsService()
                tabBarItemStylist = FakeTabBarItemStylist()

                subject = ActionAlertsController(
                    actionAlertService: actionAlertService,
                    actionAlertWebViewProvider: actionAlertWebViewProvider,
                    actionAlertLoadingMonitor: actionAlertLoadingMonitor,
                    urlOpener: urlOpener,
                    analyticsService: analyticsService,
                    tabBarItemStylist: tabBarItemStylist,
                    theme: theme
                )

                navigationController = UINavigationController()
                navigationController.pushViewController(subject, animated: false)
            }

            it("has the correct title") {
                subject.view.layoutSubviews()

                expect(subject.title).to(equal("Act Now"))
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

                it("styles the spinner with the theme") {
                    subject.view.layoutSubviews()

                    expect(subject.loadingIndicatorView.color) == UIColor.greenColor()
                }

                it("animates the spinner") {
                    subject.view.layoutSubviews()

                    expect(subject.loadingIndicatorView.isAnimating()) == true
                }

                it("sets up the collection view background image") {
                    subject.view.layoutSubviews()

                    guard let backgroundImageView = subject.collectionView.backgroundView as? UIImageView else {
                        fail("unable to get background image view")
                        return
                    }

                    expect(backgroundImageView.image) == UIImage(named: "actionAlertsBackground")!
                }

                it("sets the background color with the theme") {
                    subject.view.layoutSubviews()

                    expect(subject.view.backgroundColor) == UIColor.yellowColor()
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


                it("makes a request to the action alert service") {
                    expect(actionAlertService.fetchActionAlertsCalled) == false

                    subject.viewWillAppear(false)

                    expect(actionAlertService.fetchActionAlertsCalled) == true
                }

                it("ensures that the navigation bar is hidden") {
                    navigationController.navigationBarHidden = false

                    subject.viewWillAppear(false)

                    expect(navigationController.navigationBarHidden) == true
                }
            }

            describe("when using the action alerts service") {
                beforeEach {
                    subject.view.layoutSubviews()
                    subject.viewWillAppear(false)

                    subject.collectionView.numberOfItemsInSection(0)
                }

                context("when the service resolves its promise with some action alerts") {
                    let actionAlertA = TestUtils.actionAlert("Alert A", body: "Alert Body A")
                    let actionAlertB = TestUtils.actionAlert("Alert B", body: "Alert Body B")

                    it("adds a hidden web view to the controller's view for each action alert, using the provider") {
                        // this is a hack to load content before we show them in the collection view
                        actionAlertService.lastReturnedActionAlertsPromise.resolve([actionAlertA, actionAlertB])

                        expect(actionAlertWebViewProvider.receivedBodies) == ["Alert Body A", "Alert Body B"]

                        let webViews = actionAlertWebViewProvider.returnedWebViews
                        expect(webViews.count) == 2

                        expect(webViews[0].hidden) == true
                        expect(webViews[1].hidden) == true

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
                    pending("design") {}
                }

                context("when the service rejects its promise with an error") {
                    pending("design") {}
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


                it("shows the web view as adds it as a subview of the cell") {
                    actionAlertLoadingMonitor.lastCompletionHandler!()

                    guard let cell = subject.collectionView.dataSource?.collectionView(subject.collectionView, cellForItemAtIndexPath: NSIndexPath(forItem: 0, inSection: 0)) as? ActionAlertCell else {
                        fail("Unable to get cell")
                        return
                    }

                    let expectedWebView = actionAlertWebViewProvider.returnedWebViews[0]
                    expect(cell.webviewContainer.subviews).to(contain(expectedWebView))
                    expect(expectedWebView.hidden) == false
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

private class ActionAlertsControllerFakeTheme: FakeTheme {
    override func defaultSpinnerColor() -> UIColor { return UIColor.greenColor() }
    override func actionsBackgroundColor() -> UIColor { return UIColor.yellowColor() }
    override func actionsTitleFont() -> UIFont { return UIFont.systemFontOfSize(111) }
    override func actionsTitleTextColor() -> UIColor { return UIColor.magentaColor() }
    override func actionsShortDescriptionFont() -> UIFont { return UIFont.systemFontOfSize(222) }
    override func actionsShortDescriptionTextColor() -> UIColor { return UIColor.orangeColor() }
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
