import Quick
import Nimble

@testable import Connect

class EventsResultsControllerSpec: QuickSpec {
    override func spec() {
        describe("EventsResultsController") {
            var subject: EventsResultsController!
            var nearbyEventsUseCase: MockNearbyEventsUseCase!
            var eventsNearAddressUseCase: MockEventsNearAddressUseCase!
            var eventControllerProvider: FakeEventControllerProvider!
            var eventPresenter: FakeEventPresenter!
            var eventSectionHeaderPresenter: FakeEventSectionHeaderPresenter!
            var eventListTableViewCellStylist: FakeEventListTableViewCellStylist!
            var resultQueue: FakeOperationQueue!
            var analyticsService: FakeAnalyticsService!
            let theme = EventsResultsFakeTheme()

            var navigationController: UINavigationController!

            beforeEach {
                nearbyEventsUseCase = MockNearbyEventsUseCase()
                eventsNearAddressUseCase = MockEventsNearAddressUseCase()
                eventControllerProvider = FakeEventControllerProvider()
                eventPresenter = FakeEventPresenter()
                eventSectionHeaderPresenter = FakeEventSectionHeaderPresenter()
                eventListTableViewCellStylist = FakeEventListTableViewCellStylist()
                resultQueue = FakeOperationQueue()
                analyticsService = FakeAnalyticsService()

                subject = EventsResultsController(
                    nearbyEventsUseCase: nearbyEventsUseCase,
                    eventsNearAddressUseCase: eventsNearAddressUseCase,
                    eventControllerProvider: eventControllerProvider,
                    eventPresenter: eventPresenter,
                    eventSectionHeaderPresenter: eventSectionHeaderPresenter,
                    eventListTableViewCellStylist: eventListTableViewCellStylist,
                    resultQueue: resultQueue,
                    analyticsService: analyticsService,
                    theme: theme
                )

                navigationController = UINavigationController(rootViewController: subject)
            }

            it("adds itself as an observer of the nearby events use case") {
                expect(nearbyEventsUseCase.observers.first as? EventsResultsController) === subject
            }

            it("adds itself as an observer of the events near address use case") {
                expect(eventsNearAddressUseCase.observers.first as? EventsResultsController) === subject
            }

            describe("when the view loads") {
                it("adds its views as subviews") {
                    subject.view.layoutSubviews()

                    expect(subject.view.subviews.count) == 1
                    expect(subject.view.subviews).to(contain(subject.tableView))
                }
            }

            describe("as a nearby events use case observer") {
                beforeEach {
                    subject.view.layoutSubviews()
                }

                context("when the use case reports that events have been found") {
                    let eventA = TestUtils.eventWithName("Bigtime Bernie BBQ")
                    let eventB = TestUtils.eventWithName("Slammin' Sanders Salsa Serenade")
                    let events : Array<Event> = [eventA, eventB]
                    let eventSearchResult = FakeEventSearchResult(events: events)

                    it("has a section per unique day in the search results, on the result queue") {
                        eventSearchResult.eventsByDay = [[eventA],[eventB]]
                        eventSearchResult.uniqueDays = [NSDate(), NSDate()]

                        nearbyEventsUseCase.simulateFindingEvents(eventSearchResult)
                        resultQueue.lastReceivedBlock()

                        expect(subject.tableView.numberOfSections) == 2

                        eventSearchResult.eventsByDay = [[eventA]]
                        eventSearchResult.uniqueDays = [NSDate()]

                        nearbyEventsUseCase.simulateFindingEvents(eventSearchResult)
                        resultQueue.lastReceivedBlock()

                        expect(subject.tableView.numberOfSections) == 1
                    }

                    it("uses the events section header presenter for the header title, on the result queue") {
                        let tableView = subject.tableView
                        let dateForSection = NSDate()

                        eventSearchResult.uniqueDays = [NSDate(), dateForSection]
                        eventSearchResult.eventsByDay = [[eventA], [eventB]]

                        nearbyEventsUseCase.simulateFindingEvents(eventSearchResult)
                        resultQueue.lastReceivedBlock()

                        let header = subject.tableView.delegate?.tableView!(tableView, viewForHeaderInSection: 0) as? EventsSectionHeaderView

                        expect(header?.textLabel?.text) == "Section header"
                        expect(Int(eventSectionHeaderPresenter.lastPresentedDate.timeIntervalSinceReferenceDate)) == Int(dateForSection.timeIntervalSinceReferenceDate)
                    }

                    it("displays a cell per event in each day section, on the result queue") {
                        eventSearchResult.uniqueDays = [NSDate()]

                        eventSearchResult.eventsByDay = [events]
                        nearbyEventsUseCase.simulateFindingEvents(eventSearchResult)
                        resultQueue.lastReceivedBlock()

                        expect(subject.tableView.dataSource?.tableView(subject.tableView, numberOfRowsInSection: 0)) == 2

                        eventSearchResult.eventsByDay = [[eventA]]
                        nearbyEventsUseCase.simulateFindingEvents(eventSearchResult)
                        resultQueue.lastReceivedBlock()

                        expect(subject.tableView.dataSource?.tableView(subject.tableView, numberOfRowsInSection: 0)) == 1
                    }

                    describe("tapping on an event") {
                        beforeEach {
                            eventSearchResult.uniqueDays = [NSDate()]
                            eventSearchResult.eventsByDay = [[eventB]]
                            nearbyEventsUseCase.simulateFindingEvents(eventSearchResult)
                            resultQueue.lastReceivedBlock()

                            let tableView = subject.tableView
                            tableView.delegate!.tableView!(tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
                        }

                        it("should push a correctly configured news item view controller onto the nav stack") {
                            expect(eventControllerProvider.lastEvent) == eventB
                            expect(navigationController!.topViewController).to(beIdenticalTo(eventControllerProvider.controller))
                        }

                        it("tracks the content view with the analytics service") {
                            expect(analyticsService.lastContentViewName).to(equal(eventB.name))
                            expect(analyticsService.lastContentViewType).to(equal(AnalyticsServiceContentType.Event))
                            expect(analyticsService.lastContentViewID).to(equal(eventB.url.absoluteString))
                        }

                        describe("and the view is shown again") {
                            it("deselects the selected table row") {
                                subject.tableView.reloadData()

                                subject.tableView.selectRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), animated: false, scrollPosition: .Middle)
                                subject.viewWillAppear(false)

                                expect(subject.tableView.indexPathForSelectedRow).to(beNil())
                            }
                        }
                    }
                }

                context("when the use case notifies it that no events have been found") {
                    beforeEach {
                        let eventSearchResult = FakeEventSearchResult(events: [])
                        eventSearchResult.eventsByDay = [[TestUtils.eventWithName("A")], [TestUtils.eventWithName("B")]]
                        eventSearchResult.uniqueDays = [NSDate(), NSDate()]

                        nearbyEventsUseCase.simulateFindingEvents(eventSearchResult)
                    }

                    it("has one section") {
                        nearbyEventsUseCase.simulateFindingNoEvents()
                        resultQueue.lastReceivedBlock()

                        expect(subject.tableView.numberOfSections) == 1
                    }

                    it("returns nil for the header view") {
                        nearbyEventsUseCase.simulateFindingNoEvents()
                        resultQueue.lastReceivedBlock()

                        let header = subject.tableView.delegate?.tableView!(subject.tableView, viewForHeaderInSection: 0) as? EventsSectionHeaderView

                        expect(header).to(beNil())
                    }


                    it("displays zero cells") {
                        nearbyEventsUseCase.simulateFindingNoEvents()
                        resultQueue.lastReceivedBlock()

                        expect(subject.tableView.dataSource?.tableView(subject.tableView, numberOfRowsInSection: 0)) == 0
                    }
                }

                context("when the use case notifies it that it failed when fetching events") {
                    beforeEach {
                        let eventSearchResult = FakeEventSearchResult(events: [])
                        eventSearchResult.eventsByDay = [[TestUtils.eventWithName("A")], [TestUtils.eventWithName("B")]]
                        eventSearchResult.uniqueDays = [NSDate(), NSDate()]

                        nearbyEventsUseCase.simulateFindingEvents(eventSearchResult)
                        resultQueue.lastReceivedBlock()

                    }

                    it("has one section") {
                        nearbyEventsUseCase.simulateFailingToFindEvents(.FindingLocationError(.PermissionsError))
                        resultQueue.lastReceivedBlock()

                        expect(subject.tableView.numberOfSections) == 1
                    }

                    it("returns nil for the header view") {
                        nearbyEventsUseCase.simulateFailingToFindEvents(.FindingLocationError(.PermissionsError))
                        resultQueue.lastReceivedBlock()

                        let header = subject.tableView.delegate?.tableView!(subject.tableView, viewForHeaderInSection: 0) as? EventsSectionHeaderView

                        expect(header).to(beNil())
                    }


                    it("displays zero cells") {
                        nearbyEventsUseCase.simulateFailingToFindEvents(.FindingLocationError(.PermissionsError))
                        resultQueue.lastReceivedBlock()

                        expect(subject.tableView.dataSource?.tableView(subject.tableView, numberOfRowsInSection: 0)) == 0
                    }
                }
            }

            describe("as an events near address use case observer") {
                beforeEach {
                    subject.view.layoutSubviews()
                }

                context("when the use case reports that events have been found") {
                    let eventA = TestUtils.eventWithName("Bigtime Bernie BBQ")
                    let eventB = TestUtils.eventWithName("Slammin' Sanders Salsa Serenade")
                    let events : Array<Event> = [eventA, eventB]
                    let eventSearchResult = FakeEventSearchResult(events: events)

                    it("has a section per unique day in the search results") {
                        eventSearchResult.eventsByDay = [[eventA],[eventB]]
                        eventSearchResult.uniqueDays = [NSDate(), NSDate()]

                        eventsNearAddressUseCase.simulateFindingEvents(eventSearchResult)
                        resultQueue.lastReceivedBlock()

                        expect(subject.tableView.numberOfSections) == 2

                        eventSearchResult.eventsByDay = [[eventA]]
                        eventSearchResult.uniqueDays = [NSDate()]

                        eventsNearAddressUseCase.simulateFindingEvents(eventSearchResult)
                        resultQueue.lastReceivedBlock()

                        expect(subject.tableView.numberOfSections) == 1
                    }

                    it("uses the events section header presenter for the header title") {
                        let tableView = subject.tableView
                        let dateForSection = NSDate()

                        eventSearchResult.uniqueDays = [NSDate(), dateForSection]
                        eventSearchResult.eventsByDay = [[eventA], [eventB]]

                        eventsNearAddressUseCase.simulateFindingEvents(eventSearchResult)
                        resultQueue.lastReceivedBlock()

                        let header = subject.tableView.delegate?.tableView!(tableView, viewForHeaderInSection: 0) as? EventsSectionHeaderView

                        expect(header?.textLabel?.text) == "Section header"
                        expect(Int(eventSectionHeaderPresenter.lastPresentedDate.timeIntervalSinceReferenceDate)) == Int(dateForSection.timeIntervalSinceReferenceDate)
                    }

                    it("displays a cell per event in each day section") {
                        eventSearchResult.uniqueDays = [NSDate()]

                        eventSearchResult.eventsByDay = [events]
                        eventsNearAddressUseCase.simulateFindingEvents(eventSearchResult)
                        resultQueue.lastReceivedBlock()

                        expect(subject.tableView.dataSource?.tableView(subject.tableView, numberOfRowsInSection: 0)) == 2

                        eventSearchResult.eventsByDay = [[eventA]]
                        eventsNearAddressUseCase.simulateFindingEvents(eventSearchResult)
                        resultQueue.lastReceivedBlock()

                        expect(subject.tableView.dataSource?.tableView(subject.tableView, numberOfRowsInSection: 0)) == 1
                    }

                    describe("tapping on an event") {
                        beforeEach {
                            eventSearchResult.uniqueDays = [NSDate()]
                            eventSearchResult.eventsByDay = [[eventB]]
                            eventsNearAddressUseCase.simulateFindingEvents(eventSearchResult)
                            resultQueue.lastReceivedBlock()

                            let tableView = subject.tableView
                            tableView.delegate!.tableView!(tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
                        }

                        it("should push a correctly configured news item view controller onto the nav stack") {
                            expect(eventControllerProvider.lastEvent) == eventB
                            expect(navigationController!.topViewController).to(beIdenticalTo(eventControllerProvider.controller))
                        }

                        it("tracks the content view with the analytics service") {
                            expect(analyticsService.lastContentViewName).to(equal(eventB.name))
                            expect(analyticsService.lastContentViewType).to(equal(AnalyticsServiceContentType.Event))
                            expect(analyticsService.lastContentViewID).to(equal(eventB.url.absoluteString))
                        }

                        describe("and the view is shown again") {
                            it("deselects the selected table row") {
                                subject.tableView.reloadData()

                                subject.tableView.selectRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), animated: false, scrollPosition: .Middle)
                                subject.viewWillAppear(false)

                                expect(subject.tableView.indexPathForSelectedRow).to(beNil())
                            }
                        }
                    }
                }

                context("when the use case notifies it that no events have been found") {
                    beforeEach {
                        let eventSearchResult = FakeEventSearchResult(events: [])
                        eventSearchResult.eventsByDay = [[TestUtils.eventWithName("A")], [TestUtils.eventWithName("B")]]
                        eventSearchResult.uniqueDays = [NSDate(), NSDate()]

                        eventsNearAddressUseCase.simulateFindingEvents(eventSearchResult)
                        resultQueue.lastReceivedBlock()
                    }

                    it("has one section") {
                        eventsNearAddressUseCase.simulateFindingNoEvents()
                        resultQueue.lastReceivedBlock()

                        expect(subject.tableView.numberOfSections) == 1
                    }

                    it("returns nil for the header view") {
                        eventsNearAddressUseCase.simulateFindingNoEvents()
                        resultQueue.lastReceivedBlock()

                        let header = subject.tableView.delegate?.tableView!(subject.tableView, viewForHeaderInSection: 0) as? EventsSectionHeaderView

                        expect(header).to(beNil())
                    }


                    it("displays zero cells") {
                        eventsNearAddressUseCase.simulateFindingNoEvents()
                        resultQueue.lastReceivedBlock()

                        expect(subject.tableView.dataSource?.tableView(subject.tableView, numberOfRowsInSection: 0)) == 0
                    }
                }

                context("when the use case notifies it that it failed when fetching events") {
                    beforeEach {
                        let eventSearchResult = FakeEventSearchResult(events: [])
                        eventSearchResult.eventsByDay = [[TestUtils.eventWithName("A")], [TestUtils.eventWithName("B")]]
                        eventSearchResult.uniqueDays = [NSDate(), NSDate()]

                        eventsNearAddressUseCase.simulateFindingEvents(eventSearchResult)
                        resultQueue.lastReceivedBlock()
                    }

                    it("has one section") {
                        eventsNearAddressUseCase.simulateFailingToFindEvents(.FetchingEventsError(.InvalidJSONError(jsonObject: [])))
                        resultQueue.lastReceivedBlock()

                        expect(subject.tableView.numberOfSections) == 1
                    }

                    it("returns nil for the header view") {
                        eventsNearAddressUseCase.simulateFailingToFindEvents(.FetchingEventsError(.InvalidJSONError(jsonObject: [])))
                        resultQueue.lastReceivedBlock()

                        let header = subject.tableView.delegate?.tableView!(subject.tableView, viewForHeaderInSection: 0) as? EventsSectionHeaderView

                        expect(header).to(beNil())
                    }


                    it("displays zero cells") {
                        eventsNearAddressUseCase.simulateFailingToFindEvents(.FetchingEventsError(.InvalidJSONError(jsonObject: [])))
                        resultQueue.lastReceivedBlock()

                        expect(subject.tableView.dataSource?.tableView(subject.tableView, numberOfRowsInSection: 0)) == 0
                    }
                }
            }
        }
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

private class EventsResultsFakeTheme : FakeTheme {
    private override func defaultTableSectionHeaderBackgroundColor() -> UIColor {
        return UIColor.darkGrayColor()
    }

    private override func defaultTableSectionHeaderTextColor() -> UIColor {
        return UIColor.lightGrayColor()
    }

    private override func defaultTableSectionHeaderFont() -> UIFont {
        return UIFont.italicSystemFontOfSize(999)
    }
}

private class FakeEventControllerProvider: EventControllerProvider {
    let controller = EventController(
        event: TestUtils.eventWithName("some event"),
        eventPresenter: FakeEventPresenter(
            sameTimeZoneDateFormatter: FakeDateFormatter(),
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
