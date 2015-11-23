import UIKit
import Quick
import Nimble
import CoreLocation

@testable import Movement
import QuartzCore

private class EventsFakeTheme : FakeTheme {
    override func tabBarActiveTextColor() -> UIColor {
        return UIColor.purpleColor()
    }

    override func tabBarInactiveTextColor() -> UIColor {
        return UIColor.magentaColor()
    }

    override func tabBarFont() -> UIFont {
        return UIFont.systemFontOfSize(123)
    }

    override func eventsSearchBarBackgroundColor() -> UIColor {
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

    override func eventsSearchBarFont() -> UIFont {
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

    override func eventsListSectionHeaderBackgroundColor() -> UIColor {
        return UIColor.darkGrayColor()
    }

    override func eventsListSectionHeaderTextColor() -> UIColor {
        return UIColor.lightGrayColor()
    }

    override func eventsListSectionHeaderFont() -> UIFont {
        return UIFont.italicSystemFontOfSize(999)
    }
}

private class FakeEventRepository : EventRepository {
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

private class FakeEventControllerProvider : Movement.EventControllerProvider {
    let controller = EventController(
        event: TestUtils.eventWithName("some event"),
        eventPresenter: FakeEventPresenter(                    sameTimeZoneDateFormatter: FakeDateFormatter(),
            differentTimeZoneDateFormatter: FakeDateFormatter(),
            sameTimeZoneFullDateFormatter: FakeDateFormatter(),
            differentTimeZoneFullDateFormatter: FakeDateFormatter()),
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

private class FakeEventSearchResult: EventSearchResult {
    var uniqueDays: [NSDate] = []
    var eventsByDay: [[Event]] = []

    override func uniqueDaysInLocalTimeZone() -> [NSDate] {
        return self.uniqueDays
    }

    override func eventsWithDayIndex(dayIndex: Int) -> [Event] {
        return self.eventsByDay[dayIndex]
    }
}

private class FakeEventSectionHeaderPresenter: EventSectionHeaderPresenter {
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

private class FakeEventListTableViewCellStylist: EventListTableViewCellStylist {
    var lastStyledCell: EventListTableViewCell!
    var lastReceivedEvent: Event!

    private func styleCell(cell: EventListTableViewCell, event: Event) {
        self.lastStyledCell = cell
        self.lastReceivedEvent = event
    }
}

class EventsControllerSpec : QuickSpec {
    private var subject : EventsController!
    private var window : UIWindow!
    private var eventRepository : FakeEventRepository!
    private var eventPresenter : FakeEventPresenter!
    private var eventControllerProvider : FakeEventControllerProvider!
    private var analyticsService: FakeAnalyticsService!
    private var tabBarItemStylist: FakeTabBarItemStylist!
    private var navigationController: UINavigationController!
    private var eventSectionHeaderPresenter: FakeEventSectionHeaderPresenter!
    private var eventListTableViewCellStylist: FakeEventListTableViewCellStylist!

    override func spec() {
        describe("EventsController") {
            beforeEach {
                self.eventRepository = FakeEventRepository()
                self.eventPresenter = FakeEventPresenter(                    sameTimeZoneDateFormatter: FakeDateFormatter(),
                    differentTimeZoneDateFormatter: FakeDateFormatter(),
                    sameTimeZoneFullDateFormatter: FakeDateFormatter(),
                    differentTimeZoneFullDateFormatter: FakeDateFormatter())
                self.eventControllerProvider = FakeEventControllerProvider()
                self.eventSectionHeaderPresenter = FakeEventSectionHeaderPresenter()
                self.analyticsService = FakeAnalyticsService()
                self.tabBarItemStylist = FakeTabBarItemStylist()
                self.eventListTableViewCellStylist = FakeEventListTableViewCellStylist()

                self.window = UIWindow()

                self.subject = EventsController(
                    eventRepository: self.eventRepository,
                    eventPresenter: self.eventPresenter,
                    eventControllerProvider: self.eventControllerProvider,
                    eventSectionHeaderPresenter: self.eventSectionHeaderPresenter,
                    analyticsService: self.analyticsService,
                    tabBarItemStylist: self.tabBarItemStylist,
                    eventListTableViewCellStylist: self.eventListTableViewCellStylist,
                    theme: EventsFakeTheme()
                )

                self.navigationController = UINavigationController()
                self.navigationController.pushViewController(self.subject, animated: false)

                self.window.addSubview(self.subject.view)
                self.window.makeKeyAndVisible()

                self.subject.view.layoutSubviews()
                self.subject.viewDidAppear(false)
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
                expect(self.subject.navigationItem.backBarButtonItem?.title).to(equal("Events"))
            }

            it("uses the tab bar item stylist to style its tab bar item") {
                expect(self.tabBarItemStylist.lastReceivedTabBarItem).to(beIdenticalTo(self.subject.tabBarItem))

                expect(self.tabBarItemStylist.lastReceivedTabBarImage).to(equal(UIImage(named: "eventsTabBarIconInactive")))
                expect(self.tabBarItemStylist.lastReceivedTabBarSelectedImage).to(equal(UIImage(named: "eventsTabBarIcon")))
            }

            it("should add its view components as subviews") {
                let subViews = self.subject.view.subviews

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

            it("should hide the search button by default") {
                expect(self.subject.searchButton.hidden).to(beTrue())
            }

            it("should hide the cancel button by default") {
                expect(self.subject.cancelButton.hidden).to(beTrue())
            }

            it("should hide the filter button by default") {
                expect(self.subject.filterButton.hidden).to(beTrue())
            }

            it("should show the instructions by default") {
                expect(self.subject.instructionsLabel.hidden).to(beFalse())
                expect(self.subject.instructionsLabel.text).to(equal("Enter your ZIP code above to find Bernie events near you!"))
            }

            it("configures the zip code keyboard to be a number pad") {
                expect(self.subject.zipCodeTextField.keyboardType).to(equal(UIKeyboardType.NumberPad))
            }

            it("styles the page components with the theme") {
                expect(self.subject.searchBar.backgroundColor).to(equal(UIColor.greenColor()))
                expect(self.subject.zipCodeTextField.backgroundColor).to(equal(UIColor.brownColor()))
                expect(self.subject.zipCodeTextField.font).to(equal(UIFont.boldSystemFontOfSize(4444)))
                expect(self.subject.zipCodeTextField.textColor).to(equal(UIColor.redColor()))
                expect(self.subject.zipCodeTextField.layer.cornerRadius).to(equal(100.0))
                expect(self.subject.zipCodeTextField.layer.borderWidth).to(equal(200.0))

                expect(self.subject.zipCodeTextField.layer.sublayerTransform.m41).to(equal(4))
                expect(self.subject.zipCodeTextField.layer.sublayerTransform.m42).to(equal(5))
                expect(self.subject.zipCodeTextField.layer.sublayerTransform.m43).to(equal(6))

                expect(self.subject.searchButton.titleLabel!.font).to(equal(UIFont.boldSystemFontOfSize(4444)))
                expect(self.subject.cancelButton.titleLabel!.font).to(equal(UIFont.boldSystemFontOfSize(4444)))

                let borderColor = UIColor(CGColor: self.subject.zipCodeTextField.layer.borderColor!)
                expect(borderColor).to(equal(UIColor.orangeColor()))

                expect(self.subject.instructionsLabel.textColor).to(equal(UIColor.whiteColor()))
                expect(self.subject.instructionsLabel.font).to(equal(UIFont.italicSystemFontOfSize(666)))

                expect(self.subject.noResultsLabel.font).to(equal(UIFont.italicSystemFontOfSize(888)))
                expect(self.subject.noResultsLabel.textColor).to(equal(UIColor.blueColor()))

                expect(self.subject.loadingActivityIndicatorView.color).to(equal(UIColor.blackColor()))
            }

            it("has the correct text for the search button for the zip code entry field") {
                expect(self.subject.searchButton.titleForState(.Normal)).to(equal("Search"))
            }

            it("has the correct text for the cancel button") {
                expect(self.subject.cancelButton.titleForState(.Normal)).to(equal("Cancel"))
            }

            it("sets the radius button's input view to be the radius picker") {
                expect(self.subject.filterButton.inputView).to(beIdenticalTo(self.subject.radiusPickerView))
            }

            it("sets the image of the filter button") {
                let image = self.subject.filterButton.imageForState(.Normal)!
                let expectedImage = UIImage(named: "filterIcon")!
                expect(image).to(equal(expectedImage))
            }

            it("selects the correct default radius in the picker") {
                let picker = self.subject.radiusPickerView

                let selectedRow = picker.selectedRowInComponent(0)
                let title = picker.delegate!.pickerView!(picker, titleForRow: selectedRow, forComponent: 0)

                expect(title).to(equal("10 Miles"))
            }

            context("when selecting a search radius") {
                it("has the correct set of search radii") {
                    expect(self.subject.radiusPickerView.dataSource?.numberOfComponentsInPickerView(self.subject.radiusPickerView)).to(equal(1))
                    expect(self.subject.radiusPickerView.dataSource?.pickerView(self.subject.radiusPickerView, numberOfRowsInComponent: 0)).to(equal(6))

                    expect(self.subject.radiusPickerView.delegate?.pickerView!(self.subject.radiusPickerView, titleForRow: 0, forComponent: 0)).to(equal("5 Miles"))
                    expect(self.subject.radiusPickerView.delegate?.pickerView!(self.subject.radiusPickerView, titleForRow: 1, forComponent: 0)).to(equal("10 Miles"))
                    expect(self.subject.radiusPickerView.delegate?.pickerView!(self.subject.radiusPickerView, titleForRow: 2, forComponent: 0)).to(equal("20 Miles"))
                    expect(self.subject.radiusPickerView.delegate?.pickerView!(self.subject.radiusPickerView, titleForRow: 3, forComponent: 0)).to(equal("50 Miles"))
                    expect(self.subject.radiusPickerView.delegate?.pickerView!(self.subject.radiusPickerView, titleForRow: 4, forComponent: 0)).to(equal("100 Miles"))
                    expect(self.subject.radiusPickerView.delegate?.pickerView!(self.subject.radiusPickerView, titleForRow: 5, forComponent: 0)).to(equal("250 Miles"))
                }
            }

            context("when entering a zip code") {
                beforeEach {
                    self.subject.zipCodeTextField.tap()
                    self.subject.zipCodeTextField.becomeFirstResponder()

                    expect(self.subject.zipCodeTextField.isFirstResponder()).to(beTrue())

                    self.subject.zipCodeTextField.text = "90210"
                }

                it("should show the search button") {
                    expect(self.subject.searchButton.hidden).to(beFalse())
                }

                it("should show the cancel button") {
                    expect(self.subject.cancelButton.hidden).to(beFalse())
                }

                xit("should log an event via the analytics service") {
                    // TODO: test is failing on Travis, so marking as pending for now.
                    expect(self.analyticsService.lastCustomEventName).to(equal("Tapped on ZIP Code text field on Events"))
                    expect(self.analyticsService.lastCustomEventAttributes).to(beNil())
                }

                describe("aborting a search") {
                    beforeEach {
                        self.subject.cancelButton.tap()
                    }

                    it("should resign first responder") {
                        expect(self.subject.zipCodeTextField.isFirstResponder()).to(beFalse())
                    }

                    xit("should log an event via the analytics service") {
                        // TODO: test is failing on Travis, so marking as pending for now.
                        expect(self.analyticsService.lastCustomEventName).to(equal("Cancelled ZIP Code search on Events"))
                        expect(self.analyticsService.lastCustomEventAttributes).to(beNil())
                    }

                    it("should hide the search button") {
                        expect(self.subject.searchButton.hidden).to(beTrue())
                    }

                    it("should hide the cancel button") {
                        expect(self.subject.cancelButton.hidden).to(beTrue())
                    }
                }

                describe("and then tapping search") {
                    beforeEach {
                        self.subject.searchButton.tap()
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

                    it("should ask the events repository for events with the default search radius") {
                        expect(self.eventRepository.lastReceivedZipCode).to(equal("90210"))
                        expect(self.eventRepository.lastReceivedRadiusMiles).to(equal(10.0))
                    }

                    it("should log an event via the analytics service") {
                        expect(self.analyticsService.lastSearchQuery).to(equal("90210"))
                        expect(self.analyticsService.lastSearchContext).to(equal(AnalyticsSearchContext.Events))
                    }

                    it("should hide the search button") {
                        expect(self.subject.searchButton.hidden).to(beTrue())
                    }

                    it("should hide the cancel button") {
                        expect(self.subject.cancelButton.hidden).to(beTrue())
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
                                self.subject.zipCodeTextField.tap()
                                self.subject.zipCodeTextField.becomeFirstResponder()

                                self.subject.zipCodeTextField.text = "11111"

                                self.subject.searchButton.tap()
                            }

                            it("should hide the no results message") {
                                expect(self.subject.noResultsLabel.hidden).to(beTrue())
                            }

                            it("should show the spinner") {
                                expect(self.subject.loadingActivityIndicatorView.isAnimating()).to(beTrue())
                            }

                            it("should ask the events repository for events within the configured search radius") {
                                expect(self.eventRepository.lastReceivedZipCode).to(equal("11111"))
                                expect(self.eventRepository.lastReceivedRadiusMiles).to(equal(10.0))
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

                            it("should show the filter button") {
                                expect(self.subject.filterButton.hidden).to(beFalse())
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
                                    self.subject.zipCodeTextField.tap()
                                    self.subject.zipCodeTextField.becomeFirstResponder()

                                    self.subject.zipCodeTextField.text = "11111"
                                }

                                it("should hide the filter button") {
                                    expect(self.subject.filterButton.hidden).to(beTrue())
                                }

                                it("should show the search button") {
                                    expect(self.subject.searchButton.hidden).to(beFalse())
                                }

                                it("should show the cancel button") {
                                    expect(self.subject.cancelButton.hidden).to(beFalse())
                                }

                                describe("and then tapping done") {
                                    beforeEach {
                                        self.subject.searchButton.tap()
                                    }

                                    it("should hide the no results message") {
                                        expect(self.subject.noResultsLabel.hidden).to(beTrue())
                                    }

                                    it("should show the spinner by default") {
                                        expect(self.subject.loadingActivityIndicatorView.isAnimating()).to(beTrue())
                                    }

                                    it("should ask the events repository for events within the configured search radius") {
                                        expect(self.eventRepository.lastReceivedZipCode).to(equal("11111"))
                                        expect(self.eventRepository.lastReceivedRadiusMiles).to(equal(10.0))
                                    }
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
                                eventSearchResult.uniqueDays = [NSDate()]
                                eventSearchResult.eventsByDay = [events]

                                self.eventRepository.lastCompletionBlock!(eventSearchResult)
                            }

                            it("should hide the spinner") {
                                expect(self.subject.loadingActivityIndicatorView.isAnimating()).to(beFalse())
                            }

                            it("should show the filter button") {
                                expect(self.subject.filterButton.hidden).to(beFalse())
                            }

                            it("should leave the no results message hidden") {
                                expect(self.subject.noResultsLabel.hidden).to(beTrue())
                            }

                            it("should show the results table") {
                                expect(self.subject.resultsTableView.hidden).to(beFalse())
                            }

                            describe("the results table") {
                                it("has a section per unique day in the search results") {
                                    eventSearchResult.eventsByDay = [[eventA],[eventB]]
                                    eventSearchResult.uniqueDays = [NSDate(), NSDate()]
                                    self.subject.resultsTableView.reloadData()
                                    expect(self.subject.resultsTableView.numberOfSections).to(equal(2))
                                    eventSearchResult.eventsByDay = [[eventA]]
                                    eventSearchResult.uniqueDays = [NSDate()]
                                    self.subject.resultsTableView.reloadData()
                                    expect(self.subject.resultsTableView.numberOfSections).to(equal(1))
                                }

                                it("uses the events section header presenter for the header title") {
                                    let dateForSection = NSDate()
                                    eventSearchResult.uniqueDays = [NSDate(), dateForSection]
                                    eventSearchResult.eventsByDay = [[eventA], [eventB]]
                                    self.subject.resultsTableView.reloadData()

                                    let header = self.subject.tableView(self.subject.resultsTableView, titleForHeaderInSection: 1)
                                    expect(header).to(equal("Section header"))
                                    expect(self.eventSectionHeaderPresenter.lastPresentedDate).to(beIdenticalTo(dateForSection))
                                }

                                it("displays a cell per event in each day section") {
                                    eventSearchResult.eventsByDay = [events]

                                    expect(self.subject.resultsTableView.dataSource!.tableView(self.subject.resultsTableView, numberOfRowsInSection: 0)).to(equal(2))

                                    eventSearchResult.eventsByDay = [[eventA]]

                                    expect(self.subject.resultsTableView.dataSource!.tableView(self.subject.resultsTableView, numberOfRowsInSection: 0)).to(equal(1))
                                }

                                it("uses the presenter to set up the returned cells from the search results") {
                                    eventSearchResult.eventsByDay = [events]
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

                                it("styles the cells with the stylist") {
                                    let cell = self.subject.resultsTableView.dataSource!.tableView(self.subject.resultsTableView, cellForRowAtIndexPath:NSIndexPath(forRow: 0, inSection: 0)) as! EventListTableViewCell

                                    expect(self.eventListTableViewCellStylist.lastStyledCell).to(beIdenticalTo(cell))
                                    expect(self.eventListTableViewCellStylist.lastReceivedEvent).to(beIdenticalTo(eventA))
                                }

                                it("styles the section headers with the theme") {
                                    let sectionHeader = UITableViewHeaderFooterView()

                                    self.subject.resultsTableView.delegate?.tableView!(self.subject.resultsTableView, willDisplayHeaderView: sectionHeader, forSection: 0)

                                    expect(sectionHeader.contentView.backgroundColor).to(equal(UIColor.darkGrayColor()))
                                    expect(sectionHeader.textLabel!.textColor).to(equal(UIColor.lightGrayColor()))
                                    expect(sectionHeader.textLabel!.font).to(equal(UIFont.italicSystemFontOfSize(999)))
                                }

                                describe("tapping on an event") {
                                    beforeEach {
                                        eventSearchResult.uniqueDays = [NSDate()]
                                        eventSearchResult.eventsByDay = [[eventB]]

                                        let tableView = self.subject.resultsTableView
                                        tableView.delegate!.tableView!(tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
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
                                            self.subject.resultsTableView.reloadData()

                                            self.subject.resultsTableView.selectRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), animated: false, scrollPosition: .Middle)
                                            self.subject.viewWillAppear(false)

                                            expect(self.subject.resultsTableView.indexPathForSelectedRow).to(beNil())
                                        }
                                    }
                                }
                            }

                            describe("tapping on the filter button") {
                                beforeEach {
                                    self.subject.filterButton.tap()
                                }

                                it("becomes first responder") {
                                    expect(self.subject.filterButton.isFirstResponder()).to(beTrue())
                                }

                                it("should hide the filter button") {
                                    expect(self.subject.filterButton.hidden).to(beTrue())
                                }

                                it("should show the search button") {
                                    expect(self.subject.searchButton.hidden).to(beFalse())
                                }

                                it("should show the cancel button") {
                                    expect(self.subject.cancelButton.hidden).to(beFalse())
                                }

                                it("should hide the zip code text field") {
                                    expect(self.subject.zipCodeTextField.hidden).to(beTrue())
                                }

                                describe("and then tapping search after selecting a radius") {
                                    beforeEach {
                                        let picker = self.subject.radiusPickerView
                                        picker.delegate!.pickerView!(picker, didSelectRow: 5, inComponent: 0)

                                        self.subject.searchButton.tap()
                                    }

                                    it("resigns first responder") {
                                        expect(self.subject.filterButton.isFirstResponder()).to(beFalse())
                                    }

                                    it("should show the zip code text field") {
                                        expect(self.subject.zipCodeTextField.hidden).to(beFalse())
                                    }

                                    it("should ask the events repository for events with the updated radius") {
                                        expect(self.eventRepository.lastReceivedZipCode).to(equal("90210"))
                                        expect(self.eventRepository.lastReceivedRadiusMiles).to(equal(250.0))
                                    }
                                }

                                describe("and then tapping cancel") {
                                    beforeEach {
                                        let picker = self.subject.radiusPickerView
                                        picker.selectRow(5, inComponent: 0, animated: false)
                                        picker.delegate!.pickerView!(picker, didSelectRow: 5, inComponent: 0)

                                        self.subject.cancelButton.tap()
                                    }

                                    it("resigns first responder") {
                                        expect(self.subject.filterButton.isFirstResponder()).to(beFalse())
                                    }


                                    it("should show the zip code text field") {
                                        expect(self.subject.zipCodeTextField.hidden).to(beFalse())
                                    }

                                    it("should show the filter button") {
                                        expect(self.subject.filterButton.hidden).to(beFalse())
                                    }

                                    describe("making a subsequent search") {
                                        beforeEach {
                                            self.subject.zipCodeTextField.tap()
                                            self.subject.zipCodeTextField.becomeFirstResponder()

                                            self.subject.searchButton.tap()
                                        }

                                        it("should ask the events repository for events with the unchanged, previously configured radius") {
                                            expect(self.eventRepository.lastReceivedRadiusMiles).to(equal(10.0))
                                        }

                                        it("reverts the selected radius in the picker") {
                                            let picker = self.subject.radiusPickerView

                                            let selectedRow = picker.selectedRowInComponent(0)
                                            let title = picker.delegate!.pickerView!(picker, titleForRow: selectedRow, forComponent: 0)

                                            expect(title).to(equal("10 Miles"))
                                        }
                                    }
                                }
                            }

                            describe("making a subsequent search") {
                                beforeEach {
                                    self.subject.zipCodeTextField.tap()
                                    self.subject.zipCodeTextField.becomeFirstResponder()

                                    self.subject.zipCodeTextField.text = "11111"

                                    self.subject.searchButton.tap()
                                }

                                it("should hide the results table view") {
                                    expect(self.subject.resultsTableView.hidden).to(beTrue())
                                }

                                it("should show the spinner") {
                                    expect(self.subject.loadingActivityIndicatorView.isAnimating()).to(beTrue())
                                }

                                it("should ask the events repository for events within the configured radius") {
                                    expect(self.eventRepository.lastReceivedZipCode).to(equal("11111"))
                                    expect(self.eventRepository.lastReceivedRadiusMiles).to(equal(10.0))
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

