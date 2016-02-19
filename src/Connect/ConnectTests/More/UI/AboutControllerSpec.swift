import Foundation
import Quick
import Nimble
@testable import Connect

class AboutControllerSpec : QuickSpec {
    override func spec() {
        describe("AboutController") {
            var subject: AboutController!
            var analyticsService: FakeAnalyticsService!
            var urlOpener: FakeURLOpener!
            let urlProvider = AboutFakeURLProvider()
            let theme = AboutFakeTheme()


            beforeEach {
                analyticsService = FakeAnalyticsService()
                urlOpener = FakeURLOpener()
                subject = AboutController(
                    analyticsService: analyticsService,
                    urlOpener: urlOpener,
                    urlProvider: urlProvider,
                    theme: theme)
            }

            it("has the correct title") {
                expect(subject.title).to(equal("About"))
            }

            context("When the view loads") {
                beforeEach {
                    subject.view.layoutSubviews()
                }

                it("has a label explaining about the app") {
                    expect(subject.bodyTextLabel.text).to(contain("This app is built by a small group of volunteers"))
                }

                it("has a label instructing the user to look at reddit") {
                    expect(subject.redditLabel.text).to(contain("look into these sub-reddits:"))
                }

                it("has a scroll view containing the UI elements") {
                    expect(subject.view.subviews.count).to(equal(1))
                    let scrollView = subject.view.subviews.first as! UIScrollView

                    expect(scrollView).to(beAnInstanceOf(UIScrollView.self))
                    expect(scrollView.subviews.count).to(equal(1))

                    let containerView = scrollView.subviews.first!

                    expect(containerView.subviews.count).to(equal(6))

                    let containerViewSubViews = containerView.subviews

                    expect(containerViewSubViews.contains(subject.versionLabel)).to(beTrue())
                    expect(containerViewSubViews.contains(subject.bodyTextLabel)).to(beTrue())
                    expect(containerViewSubViews.contains(subject.redditLabel)).to(beTrue())
                    expect(containerViewSubViews.contains(subject.codersButton)).to(beTrue())
                    expect(containerViewSubViews.contains(subject.designersButton)).to(beTrue())
                    expect(containerViewSubViews.contains(subject.sandersForPresidentButton)).to(beTrue())
                }

                it("tracks taps on the back button with the analytics service") {
                    subject.didMoveToParentViewController(UIViewController())

                    expect(analyticsService.lastBackButtonTapScreen).to(beNil())

                    subject.didMoveToParentViewController(nil)

                    expect(analyticsService.lastBackButtonTapScreen).to(equal("About"))
                    expect(analyticsService.lastBackButtonTapAttributes).to(beNil())
                }

                it("has a button for the coders for sanders subreddit") {
                    expect(subject.codersButton.titleForState(.Normal)).to((equal("/r/codersforsanders")))
                }

                describe("tapping on the coders button") {
                    beforeEach {
                        subject.codersButton.tap()
                    }

                    it("opens maps with the correct arugments") {
                        expect(urlOpener.lastOpenedURL).to(equal(NSURL(string: "http://example.com/reddit/coders")))
                    }

                    it("logs that the user tapped the coders button") {
                        expect(analyticsService.lastContentViewName).to(equal("CodersForSanders"))
                        expect(analyticsService.lastContentViewType).to(equal(AnalyticsServiceContentType.About))
                        expect(analyticsService.lastContentViewID).to(equal("http://example.com/reddit/coders"))
                    }
                }

                it("has a button for the designers for sanders subreddit") {
                    expect(subject.designersButton.titleForState(.Normal)).to((equal("/r/designersforsanders")))
                }


                describe("tapping on the designers button") {
                    beforeEach {
                        subject.designersButton.tap()
                    }

                    it("opens maps with the correct arugments") {
                        expect(urlOpener.lastOpenedURL).to(equal(NSURL(string: "http://example.com/reddit/designers")))
                    }

                    it("logs that the user tapped the designers button") {
                        expect(analyticsService.lastContentViewName).to(equal("DesignersForSanders"))
                        expect(analyticsService.lastContentViewType).to(equal(AnalyticsServiceContentType.About))
                        expect(analyticsService.lastContentViewID).to(equal("http://example.com/reddit/designers"))
                    }
                }

                it("has a button for the sanders for president subreddit") {
                    expect(subject.sandersForPresidentButton.titleForState(.Normal)).to((equal("/r/sandersforpresident")))
                }


                describe("tapping on the sanders for president button") {
                    beforeEach {
                        subject.sandersForPresidentButton.tap()
                    }

                    it("opens maps with the correct arguments") {
                        expect(urlOpener.lastOpenedURL).to(equal(NSURL(string: "http://example.com/reddit/prez")))
                    }

                    it("logs that the user tapped the sanders for president button") {
                        expect(analyticsService.lastContentViewName).to(equal("SandersForPresident"))
                        expect(analyticsService.lastContentViewType).to(equal(AnalyticsServiceContentType.About))
                        expect(analyticsService.lastContentViewID).to(equal("http://example.com/reddit/prez"))
                    }
                }


                it("styles the screen components with the theme") {
                    expect(subject.view.backgroundColor).to(equal(UIColor.orangeColor()))
                    expect(subject.versionLabel.font).to(equal(UIFont.italicSystemFontOfSize(222)))
                    expect(subject.bodyTextLabel.font).to(equal(UIFont.italicSystemFontOfSize(222)))
                    expect(subject.redditLabel.font).to(equal(UIFont.italicSystemFontOfSize(222)))
                    expect(subject.codersButton.backgroundColor).to(equal(UIColor.yellowColor()))
                    expect(subject.codersButton.titleLabel!.font).to(equal(UIFont.italicSystemFontOfSize(111)))
                    expect(subject.codersButton.titleColorForState(.Normal)).to(equal(UIColor.redColor()))
                    expect(subject.designersButton.backgroundColor).to(equal(UIColor.yellowColor()))
                    expect(subject.designersButton.titleLabel!.font).to(equal(UIFont.italicSystemFontOfSize(111)))
                    expect(subject.designersButton.titleColorForState(.Normal)).to(equal(UIColor.redColor()))
                    expect(subject.sandersForPresidentButton.backgroundColor).to(equal(UIColor.yellowColor()))
                    expect(subject.sandersForPresidentButton.titleLabel!.font).to(equal(UIFont.italicSystemFontOfSize(111)))
                    expect(subject.sandersForPresidentButton.titleColorForState(.Normal)).to(equal(UIColor.redColor()))
                }
            }
        }
    }
}

private class AboutFakeTheme: FakeTheme {
    override func contentBackgroundColor() -> UIColor { return UIColor.orangeColor() }
    override func aboutButtonBackgroundColor() -> UIColor { return UIColor.yellowColor() }
    override func aboutButtonTextColor() -> UIColor { return UIColor.redColor() }
    override func aboutButtonFont() -> UIFont { return UIFont.italicSystemFontOfSize(111) }
    override func aboutBodyTextFont() -> UIFont { return UIFont.italicSystemFontOfSize(222) }
}

private class AboutFakeURLProvider: FakeURLProvider {
    override func codersForSandersURL() -> NSURL {
        return NSURL(string: "http://example.com/reddit/coders")!
    }

    override func designersForSandersURL() -> NSURL {
        return NSURL(string: "http://example.com/reddit/designers")!
    }

    override func sandersForPresidentURL() -> NSURL {
        return NSURL(string: "http://example.com/reddit/prez")!
    }
}
