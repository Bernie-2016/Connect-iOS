import Quick
import Nimble

@testable import Connect

class EventsResultsControllerSpec: QuickSpec {
    override func spec() {
        describe("EventsResultsController") {
            var subject: EventsResultsController!
            var nearbyEventsUseCase: MockNearbyEventsUseCase!
            var eventPresenter: FakeEventPresenter!
            var eventSectionHeaderPresenter: FakeEventSectionHeaderPresenter!
            var eventListTableViewCellStylist: FakeEventListTableViewCellStylist!
            let theme = EventsResultsFakeTheme()

            beforeEach {
                nearbyEventsUseCase = MockNearbyEventsUseCase()
                eventPresenter = FakeEventPresenter()
                eventSectionHeaderPresenter = FakeEventSectionHeaderPresenter()
                eventListTableViewCellStylist = FakeEventListTableViewCellStylist()
                subject = EventsResultsController(
                    nearbyEventsUseCase: nearbyEventsUseCase,
                    eventPresenter: eventPresenter,
                    eventSectionHeaderPresenter: eventSectionHeaderPresenter,
                    eventListTableViewCellStylist: eventListTableViewCellStylist,
                    theme: theme
                )
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

                    it("has a section per unique day in the search results") {
                        eventSearchResult.eventsByDay = [[eventA],[eventB]]
                        eventSearchResult.uniqueDays = [NSDate(), NSDate()]

                        nearbyEventsUseCase.simulateFindingEvents(eventSearchResult)

                        expect(subject.tableView.numberOfSections) == 2

                        eventSearchResult.eventsByDay = [[eventA]]
                        eventSearchResult.uniqueDays = [NSDate()]

                        nearbyEventsUseCase.simulateFindingEvents(eventSearchResult)

                        expect(subject.tableView.numberOfSections) == 1
                    }

                    pending("uses the events section header presenter for the header title") {
                        let tableView = subject.tableView
                        let dateForSection = NSDate()

                        eventSearchResult.uniqueDays = [NSDate(), dateForSection]
                        eventSearchResult.eventsByDay = [[eventA], [eventB]]

                        nearbyEventsUseCase.simulateFindingEvents(eventSearchResult)

                        let header = subject.tableView.delegate?.tableView!(tableView, viewForHeaderInSection: 0) as? EventsSectionHeaderView
                        expect(header!.textLabel!.text) == "Section header"
                        expect(Int(eventSectionHeaderPresenter.lastPresentedDate.timeIntervalSinceReferenceDate)) == Int(dateForSection.timeIntervalSinceReferenceDate)
                    }

                    it("displays a cell per event in each day section") {
                        eventSearchResult.eventsByDay = [events]
                        nearbyEventsUseCase.simulateFindingEvents(eventSearchResult)

                        expect(subject.tableView.dataSource?.tableView(subject.tableView, numberOfRowsInSection: 0)) == 2

                        eventSearchResult.eventsByDay = [[eventA]]
                        nearbyEventsUseCase.simulateFindingEvents(eventSearchResult)

                        expect(subject.tableView.dataSource?.tableView(subject.tableView, numberOfRowsInSection: 0)) == 1
                    }

                    it("uses the presenter to set up the returned cells from the search results") {
                        eventSearchResult.eventsByDay = [events]
                        nearbyEventsUseCase.simulateFindingEvents(eventSearchResult)

                        let cellA = subject.tableView.dataSource?.tableView(subject.tableView, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) as? EventListTableViewCell

                        expect(eventPresenter.lastReceivedEvent) == eventA
                        expect(eventPresenter.lastReceivedCell) === cellA

                        let cellB = subject.tableView.dataSource?.tableView(subject.tableView, cellForRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 0)) as? EventListTableViewCell

                        expect(eventPresenter.lastReceivedEvent) == eventB
                        expect(eventPresenter.lastReceivedCell) == cellB
                    }

                    it("styles the cells with the stylist") {
                        nearbyEventsUseCase.simulateFindingEvents(eventSearchResult)

                        let cell = subject.tableView.dataSource?.tableView(subject.tableView, cellForRowAtIndexPath:NSIndexPath(forRow: 0, inSection: 0)) as? EventListTableViewCell

                        expect(eventListTableViewCellStylist.lastStyledCell) === cell
                        expect(eventListTableViewCellStylist.lastReceivedEvent) == eventA
                    }

                    it("styles the section headers with the theme") {
                        nearbyEventsUseCase.simulateFindingEvents(eventSearchResult)
                        let sectionHeader = UITableViewHeaderFooterView()

                        subject.tableView.delegate?.tableView!(subject.tableView, willDisplayHeaderView: sectionHeader, forSection: 0)

                        expect(sectionHeader.contentView.backgroundColor) == UIColor.darkGrayColor()
                        expect(sectionHeader.textLabel!.textColor) == UIColor.lightGrayColor()
                        expect(sectionHeader.textLabel!.font) == UIFont.italicSystemFontOfSize(999)
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
