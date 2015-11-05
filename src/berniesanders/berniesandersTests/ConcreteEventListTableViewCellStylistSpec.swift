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

    override func eventsListDistanceFont() -> UIFont {
        return UIFont.italicSystemFontOfSize(444)
    }

    override func eventsListDateColor() -> UIColor {
        return UIColor.darkGrayColor()
    }

    override func eventsListDateFont() -> UIFont {
        return UIFont.italicSystemFontOfSize(777)
    }
}

class ConcreteEventListTableViewCellStylistSpec: QuickSpec {
    var subject: ConcreteEventListTableViewCellStylist!
    private let theme = FakeEventCellTheme()

    override func spec() {
        describe("ConcreteEventListTableViewCellStylistSpec") {
            beforeEach {
                self.subject = ConcreteEventListTableViewCellStylist(theme: self.theme)
            }

            describe("styling cells") {
                it("styles the cell with the theme") {
                    let cell = EventListTableViewCell()
                    self.subject.styleCell(cell)

                    expect(cell.nameLabel.font).to(equal(UIFont.italicSystemFontOfSize(333)))
                    expect(cell.nameLabel.textColor).to(equal(UIColor.yellowColor()))
                    expect(cell.distanceLabel.font).to(equal(UIFont.italicSystemFontOfSize(444)))
                    expect(cell.distanceLabel.textColor).to(equal(UIColor.lightGrayColor()))
                    expect(cell.dateLabel.font).to(equal(UIFont.italicSystemFontOfSize(777)))
                    expect(cell.dateLabel.textColor).to(equal(UIColor.darkGrayColor()))
                }
            }
        }
    }
}
