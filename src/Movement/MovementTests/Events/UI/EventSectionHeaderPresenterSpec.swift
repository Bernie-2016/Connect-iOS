import Quick
import Nimble
@testable import Movement

class EventSectionHeaderPresenterSpec: QuickSpec {
    var subject: EventSectionHeaderPresenter!
    var dateProvider: FakeDateProvider!
    var currentWeekDateFormatter: FakeDateFormatter!
    var nonCurrentWeekDateFormatter: FakeDateFormatter!

    override func spec() {
        describe("EventSectionHeaderPresenter") {
            beforeEach {
                self.dateProvider = FakeDateProvider()
                self.dateProvider.currentDate = NSDate(timeIntervalSince1970: 1446694192)

                self.currentWeekDateFormatter = FakeDateFormatter()
                self.nonCurrentWeekDateFormatter = FakeDateFormatter()

                self.subject = EventSectionHeaderPresenter(
                    currentWeekDateFormatter: self.currentWeekDateFormatter,
                    nonCurrentWeekDateFormatter: self.nonCurrentWeekDateFormatter,
                    dateProvider: self.dateProvider
                )
            }

            describe("presenting the section header date") {
                it("returns today for today's date") {
                    expect(self.subject.headerForDate(NSDate(timeIntervalSince1970: 1446694292))).to(equal("TODAY"))
                }

                it("uses the current week formatter for dates in the current week") {
                    var expectedDate = NSDate(timeIntervalSince1970: 1446796800)
                    expect(self.subject.headerForDate(expectedDate)).to(equal("THIS IS THE DATE!"))
                    expect(self.currentWeekDateFormatter.lastReceivedDate).to(beIdenticalTo(expectedDate))
                    expect(self.nonCurrentWeekDateFormatter.lastReceivedDate).to(beNil())

                    expectedDate = NSDate(timeIntervalSince1970: 1447126192)
                    expect(self.subject.headerForDate(expectedDate)).to(equal("THIS IS THE DATE!"))
                    expect(self.currentWeekDateFormatter.lastReceivedDate).to(beIdenticalTo(expectedDate))
                    expect(self.nonCurrentWeekDateFormatter.lastReceivedDate).to(beNil())
                }

                it("uses the non-current week formatter for all other dates") {
                    let expectedDate = NSDate(timeIntervalSince1970: 1449718192)
                    expect(self.subject.headerForDate(expectedDate)).to(equal("THIS IS THE DATE!"))
                    expect(self.currentWeekDateFormatter.lastReceivedDate).to(beNil())
                    expect(self.nonCurrentWeekDateFormatter.lastReceivedDate).to(beIdenticalTo(expectedDate))
                }
            }
        }
    }
}
