import Quick
import Nimble

@testable import Movement

class ActionAlertControllerSpec: QuickSpec {
    override func spec() {
        describe("ActionAlertController") {
            var subject: ActionAlertController!
            var markdownConverter: FakeMarkdownConverter!
            var actionAlert: ActionAlert!
            var urlOpener: FakeURLOpener!
            var urlProvider: FakeActionAlertURLProvider!

            beforeEach {
                actionAlert = TestUtils.actionAlert("Do the thing")
                urlOpener = FakeURLOpener()
                urlProvider = FakeActionAlertURLProvider()

                markdownConverter = FakeMarkdownConverter()
                subject = ActionAlertController(
                    actionAlert: actionAlert,
                    markdownConverter: markdownConverter,
                    urlOpener: urlOpener,
                    urlProvider: urlProvider,
                    theme: FakeActionAlertControllerTheme()
                )
            }

            describe("when the view loads") {
                beforeEach {
                    expect(subject.view).toNot(beNil())
                }

                it("adds the screen content as subviews of a container view in a scroll view") {
                    expect(subject.view.subviews.count).to(equal(1))

                    let scrollView = subject.view.subviews.first!
                    expect(scrollView).to(beAnInstanceOf(UIScrollView.self))

                    let containerView = scrollView.subviews.first!
                    expect(containerView.subviews.count).to(equal(6))

                    expect(containerView.subviews).to(contain(subject.dateLabel))
                    expect(containerView.subviews).to(contain(subject.titleLabel))
                    expect(containerView.subviews).to(contain(subject.bodyTextView))
                    expect(containerView.subviews).to(contain(subject.facebookShareButton))
                    expect(containerView.subviews).to(contain(subject.twitterShareButton))
                    expect(containerView.subviews).to(contain(subject.retweetButton))
                }

                it("sets the title label text from the action alert") {
                    expect(subject.titleLabel.text).to(equal("Do the thing"))
                }

                it("sets the body text view with text from the markdown converter") {
                    expect(markdownConverter.lastReceivedMarkdown).to(equal(actionAlert.body))
                    expect(subject.bodyTextView.attributedText.string).to(equal(markdownConverter.returnedAttributedString.string))
                }

                it("has the correct icon for the facebook share button") {
                    expect(subject.facebookShareButton.imageForState(.Normal)).to(equal(UIImage(named: "FacebookShare")))
                }

                it("has the correct icon for the twitter share button") {
                    expect(subject.twitterShareButton.imageForState(.Normal)).to(equal(UIImage(named: "TwitterShare")))
                }

                it("has the correct icon for the retweet button") {
                    expect(subject.retweetButton.imageForState(.Normal)).to(equal(UIImage(named: "Retweet")))
                }

                it("styles the non-body text content using the theme") {
                    expect(subject.view.backgroundColor).to(equal(UIColor.yellowColor()))

                    expect(subject.dateLabel.font).to(equal(UIFont.systemFontOfSize(111)))
                    expect(subject.dateLabel.textColor).to(equal(UIColor.magentaColor()))

                    expect(subject.titleLabel.font).to(equal(UIFont.systemFontOfSize(222)))
                    expect(subject.titleLabel.textColor).to(equal(UIColor.redColor()))

                    expect(UIColor(CGColor: subject.facebookShareButton.layer.borderColor!)).to(equal(UIColor.orangeColor()))
                    expect(UIColor(CGColor: subject.twitterShareButton.layer.borderColor!)).to(equal(UIColor.orangeColor()))
                    expect(UIColor(CGColor: subject.retweetButton.layer.borderColor!)).to(equal(UIColor.orangeColor()))
                }

                describe("the facebook button") {
                    context("when the action alert has a target url") {
                        beforeEach {
                            actionAlert = TestUtils.actionAlert(targetURL: NSURL(string: "https://example.com/bern")!)
                            subject = ActionAlertController(
                                actionAlert: actionAlert,
                                markdownConverter: markdownConverter,
                                urlOpener: urlOpener,
                                urlProvider: urlProvider,
                                theme: FakeActionAlertControllerTheme()
                            )
                            subject.view.layoutSubviews()
                        }

                        it("is visible") {
                            expect(subject.facebookShareButton.hidden).to(beFalse())
                        }

                        describe("when tapped") {
                            beforeEach {
                                subject.facebookShareButton.tap()
                            }

                            it("should present an activity view controller for sharing the story URL") {
                                let activityViewControler = subject.presentedViewController as! UIActivityViewController
                                let activityItems = activityViewControler.activityItems()

                                expect(activityItems.count).to(equal(1))
                                expect(activityItems.first as? NSURL).to(equal(actionAlert.targetURL))
                            }
                        }
                    }

                    context("when the action alert does not have a target url") {
                        beforeEach {
                            let actionAlert = TestUtils.actionAlert(targetURL: nil)
                            subject = ActionAlertController(
                                actionAlert: actionAlert,
                                markdownConverter: markdownConverter,
                                urlOpener: urlOpener,
                                urlProvider: urlProvider,
                                theme: FakeActionAlertControllerTheme()
                            )
                            subject.view.layoutSubviews()
                        }

                        it("is not visible") {
                            expect(subject.facebookShareButton.hidden).to(beTrue())
                        }
                    }
                }

                describe("the twitter share button") {
                    context("when the action alert has a twitter url") {
                        beforeEach {
                            actionAlert = TestUtils.actionAlert(twitterURL: NSURL(string: "https://example.com/bern")!)
                            subject = ActionAlertController(
                                actionAlert: actionAlert,
                                markdownConverter: markdownConverter,
                                urlOpener: urlOpener,
                                urlProvider: urlProvider,
                                theme: FakeActionAlertControllerTheme()
                            )
                            subject.view.layoutSubviews()
                        }

                        it("is visible") {
                            expect(subject.twitterShareButton.hidden).to(beFalse())
                        }

                        describe("when tapped") {
                            it("opens the twitter share intent in safari") {
                                expect(urlOpener.lastOpenedURL).to(beNil())

                                subject.twitterShareButton.tap()

                                expect(urlProvider.lastTwitterSharedURL).to(equal(actionAlert.twitterURL))
                                expect(urlOpener.lastOpenedURL).to(beIdenticalTo(urlProvider.returnedTwitterShareURL))
                            }
                        }
                    }

                    context("when the action alert does not have a twitter url") {
                        beforeEach {
                            let actionAlert = TestUtils.actionAlert(twitterURL: nil)
                            subject = ActionAlertController(
                                actionAlert: actionAlert,
                                markdownConverter: markdownConverter,
                                urlOpener: urlOpener,
                                urlProvider: urlProvider,
                                theme: FakeActionAlertControllerTheme()
                            )
                            subject.view.layoutSubviews()
                        }

                        it("is not visible") {
                            expect(subject.twitterShareButton.hidden).to(beTrue())
                        }
                    }
                }

                describe("the retweet button") {
                    context("when the action alert has a retweet id") {
                        beforeEach {
                            actionAlert = TestUtils.actionAlert(tweetID: "12345")

                            subject = ActionAlertController(
                                actionAlert: actionAlert,
                                markdownConverter: markdownConverter,
                                urlOpener: urlOpener,
                                urlProvider: urlProvider,
                                theme: FakeActionAlertControllerTheme()
                            )
                            subject.view.layoutSubviews()
                        }

                        it("is visible") {
                            expect(subject.retweetButton.hidden).to(beFalse())
                        }

                        describe("when tapped") {
                            it("opens the retweet intent in safari") {
                                expect(urlOpener.lastOpenedURL).to(beNil())

                                subject.retweetButton.tap()

                                expect(urlProvider.lastRetweetedTweetID).to(equal(actionAlert.tweetID))
                                expect(urlOpener.lastOpenedURL).to(beIdenticalTo(urlProvider.returnedRetweetURL))
                            }
                        }
                    }

                    context("when the action alert does not have a retweet id") {
                        beforeEach {
                            let actionAlert = TestUtils.actionAlert(tweetID: nil)
                            subject = ActionAlertController(
                                actionAlert: actionAlert,
                                markdownConverter: markdownConverter,
                                urlOpener: urlOpener,
                                urlProvider: urlProvider,
                                theme: FakeActionAlertControllerTheme()
                            )
                            subject.view.layoutSubviews()
                        }

                        it("is not visible") {
                            expect(subject.retweetButton.hidden).to(beTrue())
                        }
                    }
                }
            }
        }
    }
}

private class FakeActionAlertControllerTheme: FakeTheme {
    private override func actionAlertDateFont() -> UIFont {
        return UIFont.systemFontOfSize(111)
    }

    private override func actionAlertDateTextColor() -> UIColor {
        return UIColor.magentaColor()
    }

    private override func actionAlertTitleFont() -> UIFont {
        return UIFont.systemFontOfSize(222)
    }

    private override func actionAlertTitleTextColor() -> UIColor {
        return UIColor.redColor()
    }

    private override func contentBackgroundColor() -> UIColor {
        return UIColor.yellowColor()
    }

    private override func defaultButtonBorderColor() -> UIColor {
        return UIColor.orangeColor()
    }
}

private class FakeActionAlertURLProvider: FakeURLProvider {
    var lastTwitterSharedURL: NSURL!
    let returnedTwitterShareURL = NSURL(string: "https://berniesanders.com")!
    private override func twitterShareURL(urlToShare: NSURL) -> NSURL {
        lastTwitterSharedURL = urlToShare
        return returnedTwitterShareURL
    }

    var lastRetweetedTweetID: TweetID!
    let returnedRetweetURL = NSURL(string: "https://twitter.com/BernieSanders/status/694208555935662080")!
    private override func retweetURL(tweetID: TweetID) -> NSURL {
        lastRetweetedTweetID = tweetID
        return returnedRetweetURL
    }
}
