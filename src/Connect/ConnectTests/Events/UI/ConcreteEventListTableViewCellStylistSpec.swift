import Quick
import Nimble

@testable import Connect

class ConcreteEventListTableViewCellStylistSpec: QuickSpec {
    override func spec() {
        describe("ConcreteEventListTableViewCellStylistSpec") {
            var subject: ConcreteEventListTableViewCellStylist!
            var dateProvider: FakeDateProvider!
            let theme = FakeEventCellTheme()

            beforeEach {
                dateProvider = FakeDateProvider()
                subject = ConcreteEventListTableViewCellStylist(dateProvider: dateProvider, theme: theme)
            }

            describe("styling cells") {
                it("styles the cell with the theme") {
                    dateProvider.currentDate = NSDate()
                    let event = TestUtils.eventWithStartDate(NSDate(timeIntervalSince1970: 0), timeZone:
                        "PST")
                    let cell = EventListTableViewCell()
                    subject.styleCell(cell, event: event)

                    expect(cell.nameLabel.font).to(equal(UIFont.italicSystemFontOfSize(333)))
                    expect(cell.nameLabel.textColor).to(equal(UIColor.yellowColor()))
                    expect(cell.dateLabel.font).to(equal(UIFont.italicSystemFontOfSize(777)))
                    expect(cell.dateLabel.textColor).to(equal(UIColor.darkGrayColor()))
                    expect(cell.disclosureView.color).to(equal(UIColor.whiteColor()))
                    expect(cell.backgroundColor).to(equal(UIColor(rgba: "#777777")))
                }
            }
        }
    }
}

private class FakeEventCellTheme: FakeTheme {
    override func eventsListNameFont() -> UIFont {
        return UIFont.italicSystemFontOfSize(333)
    }

    override func eventsListNameColor() -> UIColor {
        return UIColor.yellowColor()
    }

    override func eventsListDateColor() -> UIColor {
        return UIColor.darkGrayColor()
    }

    override func eventsListDateFont() -> UIFont {
        return UIFont.italicSystemFontOfSize(777)
    }

    override func defaultDisclosureColor() -> UIColor {
        return UIColor.whiteColor()
    }

    override func defaultTableCellBackgroundColor() -> UIColor {
        return UIColor(rgba: "#777777")
    }
}
