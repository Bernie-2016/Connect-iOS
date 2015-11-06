import Quick
import Nimble

@testable import berniesanders

private class FakeEventCellTheme: FakeTheme {
    override func eventsListNameFont() -> UIFont {
        return UIFont.italicSystemFontOfSize(333)
    }

    override func eventsListNameColor() -> UIColor {
        return UIColor.yellowColor()
    }

    override func eventsListDistanceColor() -> UIColor {
        return UIColor.lightGrayColor()
    }

    override func eventsListDistanceTodayColor() -> UIColor {
        return UIColor.greenColor()
    }

    override func eventsListDistanceFont() -> UIFont {
        return UIFont.italicSystemFontOfSize(444)
    }

    override func eventsListDateColor() -> UIColor {
        return UIColor.darkGrayColor()
    }

    override func eventsListDateTodayColor() -> UIColor {
        return UIColor.redColor()
    }

    override func eventsListDateFont() -> UIFont {
        return UIFont.italicSystemFontOfSize(777)
    }

    override func defaultDisclosureColor() -> UIColor {
        return UIColor.whiteColor()
    }

    override func highlightDisclosureColor() -> UIColor {
        return UIColor.purpleColor()
    }
}

class ConcreteEventListTableViewCellStylistSpec: QuickSpec {
    var subject: ConcreteEventListTableViewCellStylist!
    var dateProvider: FakeDateProvider!
    private let theme = FakeEventCellTheme()

    override func spec() {
        describe("ConcreteEventListTableViewCellStylistSpec") {
            beforeEach {
                self.dateProvider = FakeDateProvider()
                self.subject = ConcreteEventListTableViewCellStylist(dateProvider: self.dateProvider, theme: self.theme)
            }

            describe("styling cells") {
                context("when the event is 'today', irrespective of timezone") {
                    it("styles the cell with the theme") {
                        let cell = EventListTableViewCell()
                        let today = NSDate()
                        let eventA = TestUtils.eventWithStartDate(today, timeZone:
                            NSTimeZone.localTimeZone().abbreviation!)

                        let calendar = NSCalendar.currentCalendar()
                        let todayComponents = calendar.components(NSCalendarUnit([.Year, .Month, .Day]), fromDate: today)
                        calendar.timeZone = NSTimeZone(abbreviation: "GMT")!
                        let nonLocalToday = calendar.dateFromComponents(todayComponents)!

                        let eventB = TestUtils.eventWithStartDate(nonLocalToday, timeZone: "GMT")

                        self.dateProvider.currentDate = today

                        self.subject.styleCell(cell, event: eventA)

                        expect(cell.nameLabel.font).to(equal(UIFont.italicSystemFontOfSize(333)))
                        expect(cell.nameLabel.textColor).to(equal(UIColor.yellowColor()))
                        expect(cell.distanceLabel.font).to(equal(UIFont.italicSystemFontOfSize(444)))

                        expect(cell.distanceLabel.textColor).to(equal(UIColor.greenColor()))
                        expect(cell.dateLabel.font).to(equal(UIFont.italicSystemFontOfSize(777)))
                        expect(cell.dateLabel.textColor).to(equal(UIColor.redColor()))
                        expect(cell.disclosureView.color).to(equal(UIColor.purpleColor()))

                        self.subject.styleCell(cell, event: eventB)

                        expect(cell.distanceLabel.textColor).to(equal(UIColor.greenColor()))
                        expect(cell.dateLabel.textColor).to(equal(UIColor.redColor()))
                        expect(cell.disclosureView.color).to(equal(UIColor.purpleColor()))
                    }
                }

                context("when the event is not today") {
                    it("styles the cell with the theme") {
                        self.dateProvider.currentDate = NSDate()
                        let event = TestUtils.eventWithStartDate(NSDate(timeIntervalSince1970: 0), timeZone:
                        "PST")
                        let cell = EventListTableViewCell()
                        self.subject.styleCell(cell, event: event)

                        expect(cell.nameLabel.font).to(equal(UIFont.italicSystemFontOfSize(333)))
                        expect(cell.nameLabel.textColor).to(equal(UIColor.yellowColor()))
                        expect(cell.distanceLabel.font).to(equal(UIFont.italicSystemFontOfSize(444)))
                        expect(cell.distanceLabel.textColor).to(equal(UIColor.lightGrayColor()))
                        expect(cell.dateLabel.font).to(equal(UIFont.italicSystemFontOfSize(777)))
                        expect(cell.dateLabel.textColor).to(equal(UIColor.darkGrayColor()))
                        expect(cell.disclosureView.color).to(equal(UIColor.whiteColor()))
                    }
                }
            }
        }
    }
}
