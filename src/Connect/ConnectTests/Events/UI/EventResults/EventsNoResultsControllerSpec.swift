import Quick
import Nimble

@testable import Connect

class EventsNoResultsControllerSpec: QuickSpec {
    override func spec() {
        describe("EventsNoResultsController") {
            var subject: EventsNoResultsController!
            var urlOpener: FakeURLOpener!
            let urlProvider = EventsNoResultsFakeURLProvider()
            var analyticsService: FakeAnalyticsService!
            let theme = EventsNoResultsFakeTheme()

            beforeEach {
                urlOpener = FakeURLOpener()
                analyticsService = FakeAnalyticsService()

                subject = EventsNoResultsController(
                    urlOpener: urlOpener,
                    urlProvider: urlProvider,
                    analyticsService: analyticsService,
                    theme: theme
                )
            }

            describe("when the view loads") {

                it("should add its view components as subviews") {
                    let subViews = subject.view.subviews

                    expect(subViews.count).to(equal(2))

                    expect(subViews.contains(subject.noResultsLabel)).to(beTrue())
                    expect(subViews.contains(subject.createEventCTATextView)).to(beTrue())
                }

                it("should display a no results message") {
                    subject.view.layoutSubviews()

                    expect(subject.noResultsLabel.text).to(contain("We couldn't find any"))
                }

                it("should display a call to action to create an event") {
                    subject.view.layoutSubviews()

                    expect(subject.createEventCTATextView.text).to(equal("Try another search or be the first to organize."))
                }

                it("styles the page components with the theme") {
                    subject.view.layoutSubviews()

                    expect(subject.noResultsLabel.font).to(equal(UIFont.italicSystemFontOfSize(888)))
                    expect(subject.noResultsLabel.textColor).to(equal(UIColor.blueColor()))

                    expect(subject.createEventCTATextView.font).to(equal(UIFont.italicSystemFontOfSize(777)))
                    expect(subject.createEventCTATextView.textColor).to(equal(UIColor.blueColor()))
                    expect(subject.createEventCTATextView.backgroundColor).to(equal(UIColor(rgba: "#462462")))
                }
            }

            xdescribe("tapping on the organize text") {
                it("should open the organize page in safari") {
                    expect(urlOpener.lastOpenedURL).to(equal(NSURL(string: "https://example.com/events")))
                }

                it("should log an event via the analytics service") {
                    expect(analyticsService.lastContentViewID) == "https://example.com/events"
                    expect(analyticsService.lastContentViewName) == "Create Events Form"
                    expect(analyticsService.lastContentViewType) == AnalyticsServiceContentType.Event
                }
            }
        }
    }
}

private class EventsNoResultsFakeTheme: FakeTheme {
    override func eventsInformationTextColor() -> UIColor {
        return UIColor.blueColor()
    }

    override func eventsNoResultsFont() -> UIFont {
        return UIFont.italicSystemFontOfSize(888)
    }

    override func eventsCreateEventCTAFont() -> UIFont {
        return UIFont.italicSystemFontOfSize(777)
    }

    override func defaultBackgroundColor() -> UIColor {
        return UIColor(rgba: "#462462")
    }
}

private class EventsNoResultsFakeURLProvider: FakeURLProvider {

}
