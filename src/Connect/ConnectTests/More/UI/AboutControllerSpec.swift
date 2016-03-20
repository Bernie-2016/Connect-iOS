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

                it("has a label telling the user how to contribute") {
                    expect(subject.contributeLabel.text).to(contain("If you'd like to contribute"))
                }

                it("has a scroll view containing the UI elements") {
                    expect(subject.view.subviews.count).to(equal(1))
                    let scrollView = subject.view.subviews.first as! UIScrollView

                    expect(scrollView).to(beAnInstanceOf(UIScrollView.self))
                    expect(scrollView.subviews.count).to(equal(1))

                    let containerView = scrollView.subviews.first!

                    expect(containerView.subviews.count).to(equal(5))

                    let containerViewSubViews = containerView.subviews

                    expect(containerViewSubViews.contains(subject.versionLabel)).to(beTrue())
                    expect(containerViewSubViews.contains(subject.bodyTextLabel)).to(beTrue())
                    expect(containerViewSubViews.contains(subject.githubButton)).to(beTrue())
                    expect(containerViewSubViews.contains(subject.slackButton)).to(beTrue())
                }

                it("tracks taps on the back button with the analytics service") {
                    subject.didMoveToParentViewController(UIViewController())

                    expect(analyticsService.lastBackButtonTapScreen).to(beNil())

                    subject.didMoveToParentViewController(nil)

                    expect(analyticsService.lastBackButtonTapScreen).to(equal("About"))
                    expect(analyticsService.lastBackButtonTapAttributes).to(beNil())
                }

                it("has a button for the github repo") {
                    expect(subject.githubButton.titleForState(.Normal)) == "View code on GitHub"
                }

                describe("tapping on the github button") {
                    beforeEach {
                        subject.githubButton.tap()
                    }

                    it("opens maps with the correct arugments") {
                        expect(urlOpener.lastOpenedURL).to(equal(NSURL(string: "http://example.com/github")))
                    }

                    it("logs that the user tapped the coders button") {
                        expect(analyticsService.lastContentViewName).to(equal("GitHub"))
                        expect(analyticsService.lastContentViewType).to(equal(AnalyticsServiceContentType.About))
                        expect(analyticsService.lastContentViewID).to(equal("http://example.com/github"))
                    }
                }

                it("has a button for the slack invite page") {
                    expect(subject.slackButton.titleForState(.Normal)) == "Talk to us on Slack"
                }


                describe("tapping on the slack button") {
                    beforeEach {
                        subject.slackButton.tap()
                    }

                    it("opens maps with the correct arugments") {
                        expect(urlOpener.lastOpenedURL).to(equal(NSURL(string: "http://example.com/slack")))
                    }

                    it("logs that the user tapped the designers button") {
                        expect(analyticsService.lastContentViewName).to(equal("Slack"))
                        expect(analyticsService.lastContentViewType).to(equal(AnalyticsServiceContentType.About))
                        expect(analyticsService.lastContentViewID).to(equal("http://example.com/slack"))
                    }
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
    override func githubURL() -> NSURL {
        return NSURL(string: "http://example.com/github")!
    }

    override func slackURL() -> NSURL {
        return NSURL(string: "http://example.com/slack")!
    }
}
