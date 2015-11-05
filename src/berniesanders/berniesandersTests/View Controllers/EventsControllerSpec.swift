import UIKit
import Quick
import Nimble
import CoreLocation

@testable import berniesanders
import QuartzCore

class EventsFakeTheme : FakeTheme {
    override func tabBarActiveTextColor() -> UIColor {
        return UIColor.purpleColor()
    }

    override func tabBarInactiveTextColor() -> UIColor {
        return UIColor.magentaColor()
    }

    override func tabBarFont() -> UIFont {
        return UIFont.systemFontOfSize(123)
    }

    override func eventsListNameFont() -> UIFont {
        return UIFont.italicSystemFontOfSize(333)
    }

    override func eventsListNameColor() -> UIColor {
        return UIColor.yellowColor()
    }

    override func eventsListDistanceColor() -> UIColor {
        return UIColor.lightGrayColor()
    }

    override func eventsListDistanceFont() -> UIFont {
        return UIFont.italicSystemFontOfSize(444)
    }

    override func eventsListDateColor() -> UIColor {
        return UIColor.darkGrayColor()
    }

    override func eventsListDateFont() -> UIFont {
        return UIFont.italicSystemFontOfSize(777)
    }

    override func eventsInputAccessoryBackgroundColor() -> UIColor {
        return UIColor.greenColor()
    }

    override func eventsZipCodeTextColor() -> UIColor {
        return UIColor.redColor()
    }

    override func eventsZipCodeBackgroundColor() -> UIColor {
        return UIColor.brownColor()
    }

    override func eventsZipCodeBorderColor() -> UIColor {
        return UIColor.orangeColor()
    }

    override func eventsZipCodeFont() -> UIFont {
        return UIFont.boldSystemFontOfSize(4444)
    }

    override func eventsZipCodeCornerRadius() -> CGFloat {
        return 100.0
    }

    override func eventsZipCodeBorderWidth() -> CGFloat {
        return 200.0
    }

    override func eventsZipCodeTextOffset() -> CATransform3D {
        return CATransform3DMakeTranslation(4, 5, 6);
    }

    override func eventsGoButtonCornerRadius() -> CGFloat {
        return 300
    }

    override func eventsNoResultsFont() -> UIFont {
        return UIFont.italicSystemFontOfSize(888)
    }

    override func eventsNoResultsTextColor() -> UIColor {
        return UIColor.blueColor()
    }

    override func defaultSpinnerColor() -> UIColor {
        return UIColor.blackColor()
    }

    override func eventsInstructionsFont() -> UIFont {
        return UIFont.italicSystemFontOfSize(666)
    }

    override func eventsInstructionsTextColor() -> UIColor {
        return UIColor.whiteColor()
    }
}

class FakeEventRepository : EventRepository {
    var lastReceivedZipCode : NSString?
    var lastReceivedRadiusMiles : Float?
    var lastCompletionBlock: ((EventSearchResult) -> Void)?
    var lastErrorBlock: ((NSError) -> Void)?

    func fetchEventsWithZipCode(zipCode: String, radiusMiles: Float, completion: (EventSearchResult) -> Void, error: (NSError) -> Void) {
        self.lastReceivedZipCode = zipCode
        self.lastReceivedRadiusMiles = radiusMiles
        self.lastCompletionBlock = completion
        self.lastErrorBlock = error
    }
}

class FakeEventControllerProvider : berniesanders.EventControllerProvider {
    let controller = EventController(
        event: TestUtils.eventWithName("some event"),
        eventPresenter: FakeEventPresenter(sameTimeZoneDateFormatter: FakeDateFormatter(), differentTimeZoneDateFormatter: FakeDateFormatter()),
        eventRSVPControllerProvider: FakeEventRSVPControllerProvider(),
        urlProvider: FakeURLProvider(),
        urlOpener: FakeURLOpener(),
        analyticsService: FakeAnalyticsService(),
        theme: FakeTheme())
    var lastEvent: Event?

    init() {}

    func provideInstanceWithEvent(event: Event) -> EventController {
        self.lastEvent = event
        return self.controller
    }
}

class FakeEventSearchResult: EventSearchResult {
    var uniqueDays: [NSDate] = []
    var eventsForAGivenDay: [Event] = []

    override func uniqueDaysInLocalTimeZone() -> [NSDate] {
        return self.uniqueDays
    }

    override func eventsWithDayIndex(dayIndex: Int) -> [Event] {
        return self.eventsForAGivenDay
    }
}

class FakeEventSectionHeaderPresenter: EventSectionHeaderPresenter {
    var lastPresentedDate: NSDate!

    init() {
        super.init(currentWeekDateFormatter: FakeDateFormatter(),
            nonCurrentWeekDateFormatter: FakeDateFormatter(),
            dateProvider: FakeDateProvider())
    }

    override func headerForDate(date: NSDate) -> String {
        self.lastPresentedDate = date
        return "Section header"
    }
}

class EventsControllerSpec : QuickSpec {
    var subject : EventsController!
    var window : UIWindow!
    var eventRepository : FakeEventRepository!
    var eventPresenter : FakeEventPresenter!
    var eventControllerProvider : FakeEventControllerProvider!
    var analyticsService: FakeAnalyticsService!
    var tabBarItemStylist: FakeTabBarItemStylist!
    var navigationController: UINavigationController!
    var eventSectionHeaderPresenter: FakeEventSectionHeaderPresenter!

    override func spec() {
        describe("EventsController") {
            beforeEach {
                self.eventRepository = FakeEventRepository()
                self.eventPresenter = FakeEventPresenter(sameTimeZoneDateFormatter: FakeDateFormatter(), differentTimeZoneDateFormatter: FakeDateFormatter())
                self.eventControllerProvider = FakeEventControllerProvider()
                self.tabBarItemStylist = FakeTabBarItemStylist()
                self.analyticsService = FakeAnalyticsService()
                self.eventSectionHeaderPresenter = FakeEventSectionHeaderPresenter()

                self.window = UIWindow()

                self.subject = EventsController(
                    eventRepository: self.eventRepository,
                    eventPresenter: self.eventPresenter,
                    eventControllerProvider: self.eventControllerProvider,
                    eventSectionHeaderPresenter: self.eventSectionHeaderPresenter,
                    analyticsService: self.analyticsService,
                    tabBarItemStylist: self.tabBarItemStylist,
                    theme: EventsFakeTheme()
                )

                self.navigationController = UINavigationController()
                self.navigationController.pushViewController(self.subject, animated: false)

                self.window.addSubview(self.subject.view)
                self.window.makeKeyAndVisible()

                self.subject.view.layoutSubviews()
            }

            afterEach {
                self.window = nil
            }

            it("has the correct tab bar title") {
                expect(self.subject.title).to(equal("Events"))
            }

            it("has the correct navigation item title") {
                expect(self.subject.navigationItem.title).to(equal("Events Near Me"))
            }

            it("should set the back bar button item title correctly") {
                expect(self.subject.navigationItem.backBarButtonItem?.title).to(equal("Back"))
            }

            it("uses the tab bar item stylist to style its tab bar item") {
                expect(self.tabBarItemStylist.lastReceivedTabBarItem).to(beIdenticalTo(self.subject.tabBarItem))

                expect(self.tabBarItemStylist.lastReceivedTabBarImage).to(equal(UIImage(named: "eventsTabBarIconInactive")))
                expect(self.tabBarItemStylist.lastReceivedTabBarSelectedImage).to(equal(UIImage(named: "eventsTabBarIcon")))
            }

            it("should add its view components as subviews") {
                let subViews = self.subject.view.subviews

                expect(subViews.contains(self.subject.zipCodeTextField)).to(beTrue())
                expect(subViews.contains(self.subject.instructionsLabel)).to(beTrue())
                expect(subViews.contains(self.subject.noResultsLabel)).to(beTrue())
                expect(subViews.contains(self.subject.resultsTableView)).to(beTrue())
                expect(subViews.contains(self.subject.loadingActivityIndicatorView)).to(beTrue())
            }

            it("should hide the results table view by default") {
                expect(self.subject.resultsTableView.hidden).to(beTrue())
            }

            it("should hide the no results label by default") {
                expect(self.subject.noResultsLabel.hidden).to(beTrue())
            }

            it("should hide the spinner by default") {
                expect(self.subject.loadingActivityIndicatorView.isAnimating()).to(beFalse())
            }

            it("should show the instructions by default") {
                expect(self.subject.instructionsLabel.hidden).to(beFalse())
                expect(self.subject.instructionsLabel.text).to(equal("Enter your ZIP code above to find Bernie events near you!"))
            }

            it("configures the keyboard to be a number pad") {
                expect(self.subject.zipCodeTextField.keyboardType).to(equal(UIKeyboardType.NumberPad))
            }

            it("styles the page components with the theme") {
                expect(self.subject.zipCodeTextField.backgroundColor).to(equal(UIColor.brownColor()))
                expect(self.subject.zipCodeTextField.font).to(equal(UIFont.boldSystemFontOfSize(4444)))
                expect(self.subject.zipCodeTextField.textColor).to(equal(UIColor.redColor()))
                expect(self.subject.zipCodeTextField.layer.cornerRadius).to(equal(100.0))
                expect(self.subject.zipCodeTextField.layer.borderWidth).to(equal(200.0))


                // TODO: Figure out how to test this.
                //                expect(self.subject.zipCodeTextField.layer.sublayerTransform).to(equal(CATransform3DMakeTranslation(4, 5, 6)))


                // TODO: why does this not compile?
                //                var a = self.subject.zipCodeTextField.layer.borderColor
                //                var b = UIColor.orangeColor().CGColor
                //                expect(a).to(equal(b))

                expect(self.subject.instructionsLabel.textColor).to(equal(UIColor.whiteColor()))
                expect(self.subject.instructionsLabel.font).to(equal(UIFont.italicSystemFontOfSize(666)))

                expect(self.subject.noResultsLabel.font).to(equal(UIFont.italicSystemFontOfSize(888)))
                expect(self.subject.noResultsLabel.textColor).to(equal(UIColor.blueColor()))

                expect(self.subject.loadingActivityIndicatorView.color).to(equal(UIColor.blackColor()))
            }

            it("has an input accessory view for the zip code entry field") {
                let inputToolbar = self.subject.zipCodeTextField.inputAccessoryView as! UIToolbar
                let doneButton = inputToolbar.items![1]
                let cancelButton = inputToolbar.items![2]

                expect(doneButton.title).to(equal("Search"))
                expect(cancelButton.title).to(equal("Cancel"))
            }

            context("when entering a valid zip code") {
                beforeEach {
                    self.subject.zipCodeTextField.becomeFirstResponder()

                    expect(self.subject.zipCodeTextField.isFirstResponder()).to(beTrue())

                    self.subject.zipCodeTextField.text = "90210"
                }

                xit("should log an event via the analytics service") {
                    // TODO: test is failing on Travis, so marking as pending for now.
                    expect(self.analyticsService.lastCustomEventName).to(equal("Tapped on ZIP Code text field on Events"))
                    expect(self.analyticsService.lastCustomEventAttributes).to(beNil())
                }

                describe("aborting a search") {
                    beforeEach {
                        let inputToolbar = self.subject.zipCodeTextField.inputAccessoryView as! UIToolbar
                        let cancelButton = inputToolbar.items![2]
                        cancelButton.tap()
                    }

                    it("should resign first responder") {
                        expect(self.subject.zipCodeTextField.isFirstResponder()).to(beFalse())
                    }

                    xit("should log an event via the analytics service") {
                        // TODO: test is failing on Travis, so marking as pending for now.
                        expect(self.analyticsService.lastCustomEventName).to(equal("Cancelled ZIP Code search on Events"))
                        expect(self.analyticsService.lastCustomEventAttributes).to(beNil())
                    }
                }

                describe("and then tapping search") {
                    beforeEach {
                        let inputToolbar = self.subject.zipCodeTextField.inputAccessoryView as! UIToolbar
                        let doneButton = inputToolbar.items![1]
                        doneButton.tap()
                    }

                    it("should resign first responder") {
                        expect(self.subject.zipCodeTextField.isFirstResponder()).to(beFalse())
                    }

                    it("should show the spinner") {
                        expect(self.subject.loadingActivityIndicatorView.isAnimating()).to(beTrue())
                    }

                    it("should hide the instructions") {
                        expect(self.subject.instructionsLabel.hidden).to(beTrue())
                    }

                    it("should ask the events repository for events within 50 miles") {
                        expect(self.eventRepository.lastReceivedZipCode).to(equal("90210"))
                        expect(self.eventRepository.lastReceivedRadiusMiles).to(equal(50.0))
                    }

                    it("should log an event via the analytics service") {
                        expect(self.analyticsService.lastSearchQuery).to(equal("90210"))
                        expect(self.analyticsService.lastSearchContext).to(equal(AnalyticsSearchContext.Events))
                    }

                    context("when the search results in an error") {
                        let expectedError = NSError(domain: "someerror", code: 0, userInfo: nil)
                        beforeEach {
                            self.eventRepository.lastErrorBlock!(expectedError)
                        }

                        it("should hide the spinner") {
                            expect(self.subject.loadingActivityIndicatorView.isAnimating()).to(beFalse())
                        }

                        it("should log an event via the analytics service") {
                            expect(self.analyticsService.lastError).to(beIdenticalTo(expectedError))
                            expect(self.analyticsService.lastErrorContext).to(equal("Events"))
                        }

                        it("should display a no results message") {
                            expect(self.subject.noResultsLabel.hidden).to(beFalse())
                            expect(self.subject.noResultsLabel.text).to(equal("No events match your search"))
                        }

                        it("should leave the table view hidden") {
                            expect(self.subject.resultsTableView.hidden).to(beTrue())
                        }

                        describe("making a subsequent search") {
                            beforeEach {
                                self.subject.zipCodeTextField.text = "11111"

                                let inputToolbar = self.subject.zipCodeTextField.inputAccessoryView as! UIToolbar
                                let doneButton = inputToolbar.items![1]
                                doneButton.tap()
                            }

                            it("should hide the no results message") {
                                expect(self.subject.noResultsLabel.hidden).to(beTrue())
                            }

                            it("should show the spinner") {
                                expect(self.subject.loadingActivityIndicatorView.isAnimating()).to(beTrue())
                            }

                            it("should ask the events repository for events within 50 miles") {
                                expect(self.eventRepository.lastReceivedZipCode).to(equal("11111"))
                                expect(self.eventRepository.lastReceivedRadiusMiles).to(equal(50.0))
                            }
                        }
                    }

                    context("when the search completes succesfully") {
                        context("with no results") {
                            let expectedSearchCentroid = CLLocation(latitude: 37.8271868, longitude: -122.4240794)

                            beforeEach {
                                let eventSearchResult = EventSearchResult(searchCentroid: expectedSearchCentroid, events: [])
                                self.eventRepository.lastCompletionBlock!(eventSearchResult)
                            }

                            it("should hide the spinner") {
                                expect(self.subject.loadingActivityIndicatorView.isAnimating()).to(beFalse())
                            }

                            it("should display a no results message") {
                                expect(self.subject.noResultsLabel.hidden).to(beFalse())
                                expect(self.subject.noResultsLabel.text).to(equal("No events match your search"))
                            }

                            it("should leave the table view hidden") {
                                expect(self.subject.resultsTableView.hidden).to(beTrue())
                            }

                            describe("making a subsequent search") {
                                beforeEach {
                                    self.subject.zipCodeTextField.text = "11111"

                                    let inputToolbar = self.subject.zipCodeTextField.inputAccessoryView as! UIToolbar
                                    let doneButton = inputToolbar.items![1]
                                    doneButton.tap()
                                }

                                it("should hide the no results message") {
                                    expect(self.subject.noResultsLabel.hidden).to(beTrue())
                                }

                                it("should show the spinner by default") {
                                    expect(self.subject.loadingActivityIndicatorView.isAnimating()).to(beTrue())
                                }

                                it("should ask the events repository for events within 50 miles") {
                                    expect(self.eventRepository.lastReceivedZipCode).to(equal("11111"))
                                    expect(self.eventRepository.lastReceivedRadiusMiles).to(equal(50.0))
                                }
                            }
                        }

                        context("with some results") {
                            let eventA = TestUtils.eventWithName("Bigtime Bernie BBQ")
                            let eventB = TestUtils.eventWithName("Slammin' Sanders Salsa Serenade")
                            let expectedSearchCentroid = CLLocation(latitude: 37.8271868, longitude: -122.4240794)
                            let events : Array<Event> = [eventA, eventB]
                            let eventSearchResult = FakeEventSearchResult(searchCentroid: expectedSearchCentroid, events: events)

                            beforeEach {
                                self.eventRepository.lastCompletionBlock!(eventSearchResult)
                            }

                            it("should hide the spinner") {
                                expect(self.subject.loadingActivityIndicatorView.isAnimating()).to(beFalse())
                            }

                            it("should leave the no results message hidden") {
                                expect(self.subject.noResultsLabel.hidden).to(beTrue())
                            }

                            it("should show the results table") {
                                expect(self.subject.resultsTableView.hidden).to(beFalse())
                            }


                            describe("the results table") {
                                it("has a section per unique day in the search results") {
                                    eventSearchResult.uniqueDays = [NSDate(), NSDate()]
                                    self.subject.resultsTableView.reloadData()
                                    expect(self.subject.resultsTableView.numberOfSections).to(equal(2))
                                    eventSearchResult.uniqueDays = [NSDate()]
                                    self.subject.resultsTableView.reloadData()
                                    expect(self.subject.resultsTableView.numberOfSections).to(equal(1))
                                }

                                it("uses the events section header presenter for the header title") {
                                    let dateForSection = NSDate()
                                    eventSearchResult.uniqueDays = [NSDate(), dateForSection]
                                    self.subject.resultsTableView.reloadData()

                                    let header = self.subject.tableView(self.subject.resultsTableView, titleForHeaderInSection: 1)
                                    expect(header).to(equal("Section header"))
                                    expect(self.eventSectionHeaderPresenter.lastPresentedDate).to(beIdenticalTo(dateForSection))
                                }

                                it("displays a cell per event in each day section") {
                                    eventSearchResult.eventsForAGivenDay = events
                                    self.subject.resultsTableView.reloadData()

                                    expect(self.subject.resultsTableView.numberOfRowsInSection(0)).to(equal(2))

                                    eventSearchResult.eventsForAGivenDay = [eventA]
                                    self.subject.resultsTableView.reloadData()

                                    expect(self.subject.resultsTableView.numberOfRowsInSection(0)).to(equal(1))
                                }

                                it("uses the presenter to set up the returned cells from the search results") {
                                    eventSearchResult.eventsForAGivenDay = events
                                    self.subject.resultsTableView.reloadData()

                                    let cellA = self.subject.resultsTableView.dataSource!.tableView(self.subject.resultsTableView, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) as! EventListTableViewCell

                                    expect(self.eventPresenter.lastReceivedEvent).to(beIdenticalTo(eventA))
                                    expect(self.eventPresenter.lastSearchCentroid).to(beIdenticalTo(expectedSearchCentroid))
                                    expect(self.eventPresenter.lastReceivedCell).to(beIdenticalTo(cellA))

                                    let cellB = self.subject.resultsTableView.dataSource!.tableView(self.subject.resultsTableView, cellForRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 0)) as! EventListTableViewCell

                                    expect(self.eventPresenter.lastReceivedEvent).to(beIdenticalTo(eventB))
                                    expect(self.eventPresenter.lastSearchCentroid).to(beIdenticalTo(expectedSearchCentroid))
                                    expect(self.eventPresenter.lastReceivedCell).to(beIdenticalTo(cellB))
                                }

                                it("styles the cells from the theme") {
                                    let cell = self.subject.resultsTableView.dataSource!.tableView(self.subject.resultsTableView, cellForRowAtIndexPath:NSIndexPath(forRow: 0, inSection: 0)) as! EventListTableViewCell

                                    expect(cell.nameLabel.font).to(equal(UIFont.italicSystemFontOfSize(333)))
                                    expect(cell.nameLabel.textColor).to(equal(UIColor.yellowColor()))
                                    expect(cell.distanceLabel.font).to(equal(UIFont.italicSystemFontOfSize(444)))
                                    expect(cell.distanceLabel.textColor).to(equal(UIColor.lightGrayColor()))
                                    expect(cell.dateLabel.font).to(equal(UIFont.italicSystemFontOfSize(777)))
                                    expect(cell.dateLabel.textColor).to(equal(UIColor.darkGrayColor()))
                                }

                                describe("tapping on an event") {
                                    beforeEach {
                                        let tableView = self.subject.resultsTableView
                                        tableView.delegate!.tableView!(tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 0))
                                    }

                                    it("should push a correctly configured news item view controller onto the nav stack") {
                                        expect(self.eventControllerProvider.lastEvent).to(beIdenticalTo(eventB))
                                        expect(self.subject.navigationController!.topViewController).to(beIdenticalTo(self.eventControllerProvider.controller))
                                    }

                                    it("tracks the content view with the analytics service") {
                                        expect(self.analyticsService.lastContentViewName).to(equal(eventB.name))
                                        expect(self.analyticsService.lastContentViewType).to(equal(AnalyticsServiceContentType.Event))
                                        expect(self.analyticsService.lastContentViewID).to(equal(eventB.url.absoluteString))
                                    }

                                    describe("and the view is shown again") {
                                        it("deselects the selected table row") {
                                            self.subject.resultsTableView.selectRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), animated: false, scrollPosition: .Middle)
                                            self.subject.viewWillAppear(false)

                                            expect(self.subject.resultsTableView.indexPathForSelectedRow).to(beNil())
                                        }
                                    }
                                }
                            }

                            describe("making a subsequent search") {
                                beforeEach {
                                    self.subject.zipCodeTextField.text = "11111"

                                    let inputToolbar = self.subject.zipCodeTextField.inputAccessoryView as! UIToolbar
                                    let doneButton = inputToolbar.items![1]
                                    doneButton.tap()
                                }

                                it("should hide the results table view") {
                                    expect(self.subject.resultsTableView.hidden).to(beTrue())
                                }


                                it("should show the spinner") {
                                    expect(self.subject.loadingActivityIndicatorView.isAnimating()).to(beTrue())
                                }

                                it("should ask the events repository for events within 50 miles") {
                                    expect(self.eventRepository.lastReceivedZipCode).to(equal("11111"))
                                    expect(self.eventRepository.lastReceivedRadiusMiles).to(equal(50.0))
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

