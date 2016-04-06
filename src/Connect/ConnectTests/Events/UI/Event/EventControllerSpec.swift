import UIKit
import Quick
import Nimble
import CoreLocation
import MapKit

@testable import Connect

class EventControllerSpec: QuickSpec {
    override func spec() {
        describe("EventController") {
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

            beforeEach {
                urlOpener = FakeURLOpener()
                urlProvider = EventControllerFakeURLProvider()

                eventPresenter = FakeEventPresenter(
                    sameTimeZoneDateFormatter: FakeDateFormatter(),
                    differentTimeZoneDateFormatter: FakeDateFormatter(),
                    sameTimeZoneFullDateFormatter: FakeDateFormatter(),
                    differentTimeZoneFullDateFormatter: FakeDateFormatter())
                eventRSVPControllerProvider = FakeEventRSVPControllerProvider()
                analyticsService = FakeAnalyticsService()

                subject = EventController(
                    event: event,
                    eventPresenter: eventPresenter,
                    eventRSVPControllerProvider: eventRSVPControllerProvider,
                    urlProvider: urlProvider,
                    urlOpener: urlOpener,
                    analyticsService: analyticsService,
                    theme: theme)

                navigationController = UINavigationController()
                navigationController.pushViewController(subject, animated: false)
            }

            it("should hide the tab bar when pushed") {
                expect(subject.hidesBottomBarWhenPushed).to(beTrue())
            }

            it("tracks taps on the back button with the analytics service") {
                subject.didMoveToParentViewController(nil)

                expect(analyticsService.lastBackButtonTapScreen).to(equal("Event"))
                let expectedAttributes = [ AnalyticsServiceConstants.contentIDKey: event.url.absoluteString]
                expect(analyticsService.lastBackButtonTapAttributes! as? [String: String]).to(equal(expectedAttributes))
            }

            describe("when the view loads") {
                beforeEach {
                    subject.view.layoutSubviews()
                }

                it("sets navigation item title to the event type") {
                    expect(subject.navigationItem.title) == "Big Time Bernie Fun"
                }

                it("should set the back bar button item title correctly") {
                    expect(subject.navigationItem.backBarButtonItem?.title) == ""
                }

                it("has a share button on the navigation item") {
                    let shareBarButtonItem = subject.navigationItem.rightBarButtonItem!

                    expect(shareBarButtonItem.image!) == UIImage(named: "navBarShareButton")
                }

                describe("tapping on the share button") {
                    beforeEach {
                        subject.navigationItem.rightBarButtonItem!.tap()
                    }

                    it("should present an activity view controller for sharing the story URL") {
                        let activityViewControler = subject.presentedViewController as! UIActivityViewController
                        let activityItems = activityViewControler.activityItems()

                        expect(activityItems.count).to(equal(1))
                        expect(activityItems.first as? NSURL).to(beIdenticalTo(event.url))
                    }

                    it("logs that the user tapped share") {
                        expect(analyticsService.lastCustomEventName).to(equal("Began Share"))
                        let expectedAttributes = [
                            AnalyticsServiceConstants.contentIDKey: event.url.absoluteString,
                            AnalyticsServiceConstants.contentNameKey: "limited event",
                            AnalyticsServiceConstants.contentTypeKey: "Event"
                        ]
                        expect(analyticsService.lastCustomEventAttributes! as? [String: String]).to(equal(expectedAttributes))
                    }

                    context("and the user completes the share succesfully") {
                        it("tracks the share via the analytics service") {
                            let activityViewControler = subject.presentedViewController as! UIActivityViewController
                            activityViewControler.completionWithItemsHandler!("Some activity", true, nil, nil)

                            expect(analyticsService.lastShareActivityType).to(equal("Some activity"))
                            expect(analyticsService.lastShareContentName).to(equal(event.name))
                            expect(analyticsService.lastShareContentType).to(equal(AnalyticsServiceContentType.Event))
                            expect(analyticsService.lastShareID).to(equal(event.url.absoluteString))
                        }
                    }

                    context("and the user cancels the share") {
                        it("tracks the share cancellation via the analytics service") {
                            let activityViewControler = subject.presentedViewController as! UIActivityViewController
                            activityViewControler.completionWithItemsHandler!(nil, false, nil, nil)

                            expect(analyticsService.lastCustomEventName).to(equal("Cancelled Share"))
                            let expectedAttributes = [
                                AnalyticsServiceConstants.contentIDKey: event.url.absoluteString,
                                AnalyticsServiceConstants.contentNameKey: "limited event",
                                AnalyticsServiceConstants.contentTypeKey: "Event"
                            ]
                            expect(analyticsService.lastCustomEventAttributes! as? [String: String]).to(equal(expectedAttributes))
                        }
                    }

                    context("and there is an error when sharing") {
                        it("tracks the error via the analytics service") {
                            let expectedError = NSError(domain: "a", code: 0, userInfo: nil)
                            let activityViewControler = subject.presentedViewController as! UIActivityViewController
                            activityViewControler.completionWithItemsHandler!("asdf", true, nil, expectedError)

                            expect(analyticsService.lastError as NSError).to(equal(expectedError))
                            expect(analyticsService.lastErrorContext).to(equal("Failed to share Event"))
                        }
                    }
                }

                it("has a scroll view containing all the UI elements aside from the RSVP button") {
                    expect(subject.view.subviews.count).to(equal(2))
                    let scrollView = subject.view.subviews.first as! UIScrollView
                    expect(scrollView).to(beAnInstanceOf(UIScrollView.self))
                    expect(scrollView.subviews.count).to(equal(1))

                    let rsvpButton = subject.view.subviews.last
                    expect(rsvpButton).to(beIdenticalTo(subject.rsvpButton))

                    let containerView = scrollView.subviews.first!

                    expect(containerView.subviews.count).to(equal(9))

                    let containerViewSubViews = containerView.subviews

                    expect(containerViewSubViews.contains(subject.mapView)).to(beTrue())
                    expect(containerViewSubViews.contains(subject.dateLabel)).to(beTrue())
                    expect(containerViewSubViews.contains(subject.nameLabel)).to(beTrue())

                    expect(containerViewSubViews.contains(subject.directionsButton)).to(beTrue())
                    expect(containerViewSubViews.contains(subject.descriptionHeadingLabel)).to(beTrue())
                    expect(containerViewSubViews.contains(subject.descriptionLabel)).to(beTrue())
                    expect(containerViewSubViews.contains(subject.rsvpButton)).to(beFalse())
                }

                xit("centers the map around the event") {
                    // TODO: for some reason, the region's center is coming back as NaN under test
                    // We should also test the region bounds

                    let region = subject.mapView.region
                                       expect(region.center.latitude).to(equal(event.location.coordinate.latitude))
                    expect(region.center.longitude).to(equal(event.location.coordinate.longitude))
                }

                it("adds a pin to the map for the event") {
                    expect(subject.mapView.annotations.count).to(equal(1))
                    let pin = subject.mapView.annotations.first!

                    expect(pin.coordinate.latitude).to(equal(event.location.coordinate.latitude))
                    expect(pin.coordinate.longitude).to(equal(event.location.coordinate.longitude))
                }

                it("uses the presenter to display the start date/time") {
                    expect(eventPresenter.lastEventWithPresentedDateTime) == event
                    expect(subject.dateLabel.text).to(equal("PRESENTED DATETIME!"))
                }

                it("displays the title") {
                    expect(subject.nameLabel.text).to(equal("limited event"))
                }

                it("displays the event description") {
                    expect(subject.descriptionLabel.text).to(equal("Words about the event"))
                }

                it("has a heading for the description") {
                    expect(subject.descriptionHeadingLabel.text).to(equal("Description"))
                }

                it("has an RSVP button with text from the presenter") {
                    expect(eventPresenter.lastEventWithPresentedRSVPText) == event
                    expect(subject.rsvpButton.titleForState(.Normal)).to(equal("LOTS OF PEOPLE!"))
                }

                describe("tapping on the rsvp button") {
                    beforeEach {
                        subject.rsvpButton.tap()
                    }

                    it("pushes an rsvp controller") {
                        expect(eventRSVPControllerProvider.lastReceivedEvent) == event
                        expect(subject.navigationController!.topViewController).to(beAKindOf(EventRSVPController.self))
                    }

                    it("logs that the user tapped to rsvp") {
                        expect(analyticsService.lastCustomEventName).to(equal("Tapped 'RSVP' on Event"))
                        let expectedAttributes = [ AnalyticsServiceConstants.contentIDKey: event.url.absoluteString]
                        expect(analyticsService.lastCustomEventAttributes! as? [String: String]).to(equal(expectedAttributes))
                    }
                }

                it("has a directions button with the correct title and subtitle") {
                    expect(subject.directionsButton.title.text).to(equal("Get Directions"))
                    expect(eventPresenter.lastEventWithPresentedAddress) == event
                    expect(subject.directionsButton.subTitle.text).to(equal("SOME COOL ADDRESS!"))
                }

                describe("tapping on the directions button") {
                    beforeEach {
                        subject.directionsButton.tap()
                    }

                    it("opens maps with the correct arugments") {
                        expect(urlProvider.lastReceivedEvent) == event
                        expect(urlOpener.lastOpenedURL).to(equal(NSURL(string: "http://example.com/mapz")))
                    }

                    it("logs that the user tapped to open directions") {
                        expect(analyticsService.lastCustomEventName).to(equal("Tapped 'Directions' on Event"))
                        let expectedAttributes = [ AnalyticsServiceConstants.contentIDKey: event.url.absoluteString]
                        expect(analyticsService.lastCustomEventAttributes! as? [String: String]).to(equal(expectedAttributes))
                    }
                }

                it("styles the screen according to the theme") {
                    expect(subject.dateLabel.font).to(equal(UIFont.systemFontOfSize(222)))
                    expect(subject.dateLabel.textColor).to(equal(UIColor.yellowColor()))

                    expect(subject.nameLabel.font).to(equal(UIFont.systemFontOfSize(111)))
                    expect(subject.nameLabel.textColor).to(equal(UIColor.purpleColor()))

                    expect(subject.directionsButton.backgroundColor).to(equal(UIColor.lightGrayColor()))
                    expect(subject.directionsButton.title.textColor).to(equal(UIColor.darkGrayColor()))
                    expect(subject.directionsButton.title.font).to(equal(UIFont.italicSystemFontOfSize(777)))
                    expect(subject.directionsButton.subTitle.font).to(equal(UIFont.systemFontOfSize(444)))
                    expect(subject.directionsButton.subTitle.textColor).to(equal(UIColor.blueColor()))
                    expect(subject.directionsButton.disclosureView.color).to(equal(UIColor.redColor()))

                    expect(subject.descriptionHeadingLabel.font).to(equal(UIFont.systemFontOfSize(555)))
                    expect(subject.descriptionHeadingLabel.textColor).to(equal(UIColor.brownColor()))

                    expect(subject.descriptionLabel.font).to(equal(UIFont.systemFontOfSize(666)))
                    expect(subject.descriptionLabel.textColor).to(equal(UIColor.magentaColor()))

                    expect(subject.rsvpButton.backgroundColor).to(equal(UIColor.whiteColor()))
                    expect(subject.rsvpButton.titleColorForState(.Normal)).to(equal(UIColor.blackColor()))
                    expect(subject.rsvpButton.titleLabel!.font).to(equal(UIFont.systemFontOfSize(888)))
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
    override func fullWidthButtonBackgroundColor() -> UIColor { return UIColor.whiteColor() }
    override func fullWidthRSVPButtonTextColor() -> UIColor { return UIColor.blackColor() }
    override func fullWidthRSVPButtonFont() -> UIFont { return UIFont.systemFontOfSize(888) }
    override func defaultDisclosureColor() -> UIColor { return UIColor.redColor() }
    override func eventBackgroundColor() -> UIColor { return UIColor.darkTextColor() }
}

class EventControllerFakeURLProvider : FakeURLProvider {
    var lastReceivedEvent : Event!

    override func mapsURLForEvent(event: Event) -> NSURL {
        lastReceivedEvent = event
        return NSURL(string: "http://example.com/mapz")!
    }
}
