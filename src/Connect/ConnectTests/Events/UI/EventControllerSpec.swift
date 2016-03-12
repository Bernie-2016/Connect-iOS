import UIKit
import Quick
import Nimble
import CoreLocation
import MapKit

@testable import Connect

class EventControllerSpec: QuickSpec {
    var subject: EventController!
    var eventPresenter : FakeEventPresenter!
    var urlOpener : FakeURLOpener!
    var urlProvider: EventControllerFakeURLProvider!
    var eventRSVPControllerProvider: FakeEventRSVPControllerProvider!
    var analyticsService: FakeAnalyticsService!

    var navigationController: UINavigationController!

    let theme = EventFakeTheme()
    let event = Event(name: "limited event", startDate: NSDate(timeIntervalSince1970: 1433565000), timeZone: NSTimeZone(abbreviation: "PST")!,
        attendeeCapacity: 10, attendeeCount: 2,
        streetAddress: "1 Post Street", city: "San Francisco", state: "CA", zip: "94117", location: CLLocation(latitude: 12.34, longitude: 23.45),
        description: "Words about the event", url: NSURL(string: "https://example.com")!, eventTypeName: "Big Time Bernie Fun")

    override func spec() {
        describe("EventController") {
            beforeEach {
                self.urlOpener = FakeURLOpener()
                self.urlProvider = EventControllerFakeURLProvider()

                self.eventPresenter = FakeEventPresenter(
                    sameTimeZoneDateFormatter: FakeDateFormatter(),
                    differentTimeZoneDateFormatter: FakeDateFormatter(),
                    sameTimeZoneFullDateFormatter: FakeDateFormatter(),
                    differentTimeZoneFullDateFormatter: FakeDateFormatter())
                self.eventRSVPControllerProvider = FakeEventRSVPControllerProvider()
                self.analyticsService = FakeAnalyticsService()

                self.subject = EventController(
                    event: self.event,
                    eventPresenter: self.eventPresenter,
                    eventRSVPControllerProvider: self.eventRSVPControllerProvider,
                    urlProvider: self.urlProvider,
                    urlOpener: self.urlOpener,
                    analyticsService: self.analyticsService,
                    theme: self.theme)

                self.navigationController = UINavigationController()
                self.navigationController.pushViewController(self.subject, animated: false)
            }

            it("should hide the tab bar when pushed") {
                expect(self.subject.hidesBottomBarWhenPushed).to(beTrue())
            }


            it("tracks taps on the back button with the analytics service") {
                self.subject.didMoveToParentViewController(nil)

                expect(self.analyticsService.lastBackButtonTapScreen).to(equal("Event"))
                let expectedAttributes = [ AnalyticsServiceConstants.contentIDKey: self.event.url.absoluteString]
                expect(self.analyticsService.lastBackButtonTapAttributes! as? [String: String]).to(equal(expectedAttributes))
            }

            describe("when the view loads") {
                beforeEach {
                    self.subject.view.layoutSubviews()
                }

                it("has the correct navigation item title") {
                    expect(self.subject.navigationItem.title).to(equal("Event Details"))
                }

                it("has a share button on the navigation item") {
                    let shareBarButtonItem = self.subject.navigationItem.rightBarButtonItem!

                    expect(shareBarButtonItem.image!) == UIImage(named: "navBarShareButton")
                }

                describe("tapping on the share button") {
                    beforeEach {
                        self.subject.navigationItem.rightBarButtonItem!.tap()
                    }

                    it("should present an activity view controller for sharing the story URL") {
                        let activityViewControler = self.subject.presentedViewController as! UIActivityViewController
                        let activityItems = activityViewControler.activityItems()

                        expect(activityItems.count).to(equal(1))
                        expect(activityItems.first as? NSURL).to(beIdenticalTo(self.event.url))
                    }

                    it("logs that the user tapped share") {
                        expect(self.analyticsService.lastCustomEventName).to(equal("Began Share"))
                        let expectedAttributes = [
                            AnalyticsServiceConstants.contentIDKey: self.event.url.absoluteString,
                            AnalyticsServiceConstants.contentNameKey: "limited event",
                            AnalyticsServiceConstants.contentTypeKey: "Event"
                        ]
                        expect(self.analyticsService.lastCustomEventAttributes! as? [String: String]).to(equal(expectedAttributes))
                    }

                    context("and the user completes the share succesfully") {
                        it("tracks the share via the analytics service") {
                            let activityViewControler = self.subject.presentedViewController as! UIActivityViewController
                            activityViewControler.completionWithItemsHandler!("Some activity", true, nil, nil)

                            expect(self.analyticsService.lastShareActivityType).to(equal("Some activity"))
                            expect(self.analyticsService.lastShareContentName).to(equal(self.event.name))
                            expect(self.analyticsService.lastShareContentType).to(equal(AnalyticsServiceContentType.Event))
                            expect(self.analyticsService.lastShareID).to(equal(self.event.url.absoluteString))
                        }
                    }

                    context("and the user cancels the share") {
                        it("tracks the share cancellation via the analytics service") {
                            let activityViewControler = self.subject.presentedViewController as! UIActivityViewController
                            activityViewControler.completionWithItemsHandler!(nil, false, nil, nil)

                            expect(self.analyticsService.lastCustomEventName).to(equal("Cancelled Share"))
                            let expectedAttributes = [
                                AnalyticsServiceConstants.contentIDKey: self.event.url.absoluteString,
                                AnalyticsServiceConstants.contentNameKey: "limited event",
                                AnalyticsServiceConstants.contentTypeKey: "Event"
                            ]
                            expect(self.analyticsService.lastCustomEventAttributes! as? [String: String]).to(equal(expectedAttributes))
                        }
                    }

                    context("and there is an error when sharing") {
                        it("tracks the error via the analytics service") {
                            let expectedError = NSError(domain: "a", code: 0, userInfo: nil)
                            let activityViewControler = self.subject.presentedViewController as! UIActivityViewController
                            activityViewControler.completionWithItemsHandler!("asdf", true, nil, expectedError)

                            expect(self.analyticsService.lastError as NSError).to(equal(expectedError))
                            expect(self.analyticsService.lastErrorContext).to(equal("Failed to share Event"))
                        }
                    }
                }

                it("has a scroll view containing all the UI elements aside from the RSVP button") {
                    expect(self.subject.view.subviews.count).to(equal(2))
                    let scrollView = self.subject.view.subviews.first as! UIScrollView
                    expect(scrollView).to(beAnInstanceOf(UIScrollView.self))
                    expect(scrollView.subviews.count).to(equal(1))

                    let rsvpButton = self.subject.view.subviews.last
                    expect(rsvpButton).to(beIdenticalTo(self.subject.rsvpButton))

                    let containerView = scrollView.subviews.first!

                    expect(containerView.subviews.count).to(equal(10))

                    let containerViewSubViews = containerView.subviews

                    expect(containerViewSubViews.contains(self.subject.mapView)).to(beTrue())
                    expect(containerViewSubViews.contains(self.subject.dateLabel)).to(beTrue())
                    expect(containerViewSubViews.contains(self.subject.nameLabel)).to(beTrue())
                    expect(containerViewSubViews.contains(self.subject.eventTypeLabel)).to(beTrue())
                    expect(containerViewSubViews.contains(self.subject.directionsButton)).to(beTrue())
                    expect(containerViewSubViews.contains(self.subject.descriptionHeadingLabel)).to(beTrue())
                    expect(containerViewSubViews.contains(self.subject.descriptionLabel)).to(beTrue())
                    expect(containerViewSubViews.contains(self.subject.rsvpButton)).to(beFalse())
                }

                xit("centers the map around the event") {
                    // TODO: for some reason, the region's center is coming back as NaN under test
                    // We should also test the region bounds

                    let region = self.subject.mapView.region
                                       expect(region.center.latitude).to(equal(self.event.location.coordinate.latitude))
                    expect(region.center.longitude).to(equal(self.event.location.coordinate.longitude))
                }

                it("adds a pin to the map for the event") {
                    expect(self.subject.mapView.annotations.count).to(equal(1))
                    let pin = self.subject.mapView.annotations.first!

                    expect(pin.coordinate.latitude).to(equal(self.event.location.coordinate.latitude))
                    expect(pin.coordinate.longitude).to(equal(self.event.location.coordinate.longitude))
                }

                it("uses the presenter to display the start date/time") {
                    expect(self.eventPresenter.lastEventWithPresentedDateTime) == self.event
                    expect(self.subject.dateLabel.text).to(equal("PRESENTED DATETIME!"))
                }

                it("displays the title") {
                    expect(self.subject.nameLabel.text).to(equal("limited event"))
                }

                it("displays the event type") {
                    expect(self.subject.eventTypeLabel.text).to(equal("Big Time Bernie Fun"))
                }

                it("displays the event description") {
                    expect(self.subject.descriptionLabel.text).to(equal("Words about the event"))
                }

                it("has a heading for the description") {
                    expect(self.subject.descriptionHeadingLabel.text).to(equal("Description"))
                }

                it("has an RSVP button with text from the presenter") {
                    expect(self.eventPresenter.lastEventWithPresentedRSVPText) == self.event
                    expect(self.subject.rsvpButton.titleForState(.Normal)).to(equal("LOTS OF PEOPLE!"))
                }

                describe("tapping on the rsvp button") {
                    beforeEach {
                        self.subject.rsvpButton.tap()
                    }

                    it("pushes an rsvp controller") {
                        expect(self.eventRSVPControllerProvider.lastReceivedEvent) == self.event
                        expect(self.subject.navigationController!.topViewController).to(beAKindOf(EventRSVPController.self))
                    }

                    it("logs that the user tapped to rsvp") {
                        expect(self.analyticsService.lastCustomEventName).to(equal("Tapped 'RSVP' on Event"))
                        let expectedAttributes = [ AnalyticsServiceConstants.contentIDKey: self.event.url.absoluteString]
                        expect(self.analyticsService.lastCustomEventAttributes! as? [String: String]).to(equal(expectedAttributes))
                    }
                }

                it("has a directions button with the correct title and subtitle") {
                    expect(self.subject.directionsButton.title.text).to(equal("Get Directions"))
                    expect(self.eventPresenter.lastEventWithPresentedAddress) == self.event
                    expect(self.subject.directionsButton.subTitle.text).to(equal("SOME COOL ADDRESS!"))
                }

                describe("tapping on the directions button") {
                    beforeEach {
                        self.subject.directionsButton.tap()
                    }

                    it("opens maps with the correct arugments") {
                        expect(self.urlProvider.lastReceivedEvent) == self.event
                        expect(self.urlOpener.lastOpenedURL).to(equal(NSURL(string: "http://example.com/mapz")))
                    }

                    it("logs that the user tapped to open directions") {
                        expect(self.analyticsService.lastCustomEventName).to(equal("Tapped 'Directions' on Event"))
                        let expectedAttributes = [ AnalyticsServiceConstants.contentIDKey: self.event.url.absoluteString]
                        expect(self.analyticsService.lastCustomEventAttributes! as? [String: String]).to(equal(expectedAttributes))
                    }
                }

                it("styles the screen according to the theme") {
                    expect(self.subject.dateLabel.font).to(equal(UIFont.systemFontOfSize(222)))
                    expect(self.subject.dateLabel.textColor).to(equal(UIColor.yellowColor()))

                    expect(self.subject.nameLabel.font).to(equal(UIFont.systemFontOfSize(111)))
                    expect(self.subject.nameLabel.textColor).to(equal(UIColor.purpleColor()))

                    expect(self.subject.eventTypeLabel.font).to(equal(UIFont.systemFontOfSize(999)))
                    expect(self.subject.eventTypeLabel.textColor).to(equal(UIColor(rgba: "#aaaaaa")))

                    expect(self.subject.directionsButton.backgroundColor).to(equal(UIColor.lightGrayColor()))
                    expect(self.subject.directionsButton.title.textColor).to(equal(UIColor.darkGrayColor()))
                    expect(self.subject.directionsButton.title.font).to(equal(UIFont.italicSystemFontOfSize(777)))
                    expect(self.subject.directionsButton.subTitle.font).to(equal(UIFont.systemFontOfSize(444)))
                    expect(self.subject.directionsButton.subTitle.textColor).to(equal(UIColor.blueColor()))
                    expect(self.subject.directionsButton.disclosureView.color).to(equal(UIColor.redColor()))

                    expect(self.subject.descriptionHeadingLabel.font).to(equal(UIFont.systemFontOfSize(555)))
                    expect(self.subject.descriptionHeadingLabel.textColor).to(equal(UIColor.brownColor()))

                    expect(self.subject.descriptionLabel.font).to(equal(UIFont.systemFontOfSize(666)))
                    expect(self.subject.descriptionLabel.textColor).to(equal(UIColor.magentaColor()))

                    expect(self.subject.rsvpButton.backgroundColor).to(equal(UIColor.whiteColor()))
                    expect(self.subject.rsvpButton.titleColorForState(.Normal)).to(equal(UIColor.blackColor()))
                    expect(self.subject.rsvpButton.titleLabel!.font).to(equal(UIFont.systemFontOfSize(888)))
                }
            }
        }
    }
}

class EventFakeTheme : FakeTheme {
    override func defaultBackgroundColor() -> UIColor { return UIColor.orangeColor() }
    override func eventNameFont() -> UIFont { return UIFont.systemFontOfSize(111) }
    override func eventNameColor() -> UIColor { return UIColor.purpleColor() }
    override func eventStartDateFont() -> UIFont { return UIFont.systemFontOfSize(222)  }
    override func eventStartDateColor() -> UIColor { return UIColor.yellowColor() }
    override func eventAttendeesFont() -> UIFont { return UIFont.systemFontOfSize(333) }
    override func eventAttendeesColor() -> UIColor { return UIColor.greenColor() }
    override func eventAddressFont() -> UIFont { return UIFont.systemFontOfSize(444) }
    override func eventAddressColor() -> UIColor { return UIColor.blueColor() }
    override func eventDescriptionHeadingFont() -> UIFont { return UIFont.systemFontOfSize(555) }
    override func eventDescriptionHeadingColor() -> UIColor { return UIColor.brownColor() }
    override func eventDescriptionFont() -> UIFont { return UIFont.systemFontOfSize(666) }
    override func eventDescriptionColor() -> UIColor { return UIColor.magentaColor() }
    override func eventDirectionsButtonBackgroundColor() -> UIColor { return UIColor.lightGrayColor() }
    override func eventDirectionsButtonTextColor() -> UIColor { return UIColor.darkGrayColor() }
    override func eventDirectionsButtonFont() -> UIFont { return UIFont.italicSystemFontOfSize(777) }
    override func eventRSVPButtonBackgroundColor() -> UIColor { return UIColor.whiteColor() }
    override func eventRSVPButtonTextColor() -> UIColor { return UIColor.blackColor() }
    override func eventRSVPButtonFont() -> UIFont { return UIFont.systemFontOfSize(888) }
    override func defaultDisclosureColor() -> UIColor { return UIColor.redColor() }
    override func eventBackgroundColor() -> UIColor { return UIColor.darkTextColor() }
    override func eventTypeColor() -> UIColor { return UIColor(rgba: "#aaaaaa") }
    override func eventTypeFont() -> UIFont { return UIFont.systemFontOfSize(999) }
}

class EventControllerFakeURLProvider : FakeURLProvider {
    var lastReceivedEvent : Event!

    override func mapsURLForEvent(event: Event) -> NSURL {
        self.lastReceivedEvent = event
        return NSURL(string: "http://example.com/mapz")!
    }
}
