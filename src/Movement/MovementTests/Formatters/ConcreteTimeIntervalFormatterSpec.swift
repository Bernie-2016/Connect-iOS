import Quick
import Nimble
@testable import Movement

class FakeDateProvider: DateProvider {
    var currentDate: NSDate?

    func now() -> NSDate {
        return self.currentDate!
    }
}

class ConcreteTimeIntervalFormatterSpec: QuickSpec {
    override func spec() {
        describe("TimeIntervalFormatter") {
            var subject: TimeIntervalFormatter!
            var dateProvider: FakeDateProvider!

            beforeEach {
                dateProvider = FakeDateProvider()

                subject = ConcreteTimeIntervalFormatter(
                    dateProvider: dateProvider
                )
            }

            describe("human representation of a date relative to the current date") {
                it("returns the correct text when the interval is within the current day") {
                    var now = NSDate()
                    dateProvider.currentDate = now

                    expect(subject.humanDaysSinceDate(now)).to(equal("Today"))

                    now = NSDate(timeIntervalSince1970: 60 * 60 * 24)
                    dateProvider.currentDate = now

                    var relativeDate = NSDate(timeIntervalSince1970: (60 * 60 * 23))
                    expect(subject.humanDaysSinceDate(relativeDate)).to(equal("Today"))

                    relativeDate = NSDate(timeIntervalSince1970: 1)
                    expect(subject.humanDaysSinceDate(relativeDate)).to(equal("Today"))

                }

                it("returns the correct text when the interval is within the previous day") {
                    let now = NSDate(timeIntervalSince1970: 60 * 60 * 24 * 2)
                    dateProvider.currentDate = now

                    var relativeDate = NSDate(timeIntervalSince1970: (60 * 60 * 24) - 1)
                    expect(subject.humanDaysSinceDate(relativeDate)).to(equal("Yesterday"))

                    relativeDate = NSDate(timeIntervalSince1970: 1)
                    expect(subject.humanDaysSinceDate(relativeDate)).to(equal("Yesterday"))
                }

                it("returns the correct text when the interval is more than 1 day") {
                    let now = NSDate(timeIntervalSince1970: 60 * 60 * 24 * 3)
                    dateProvider.currentDate = now

                    var relativeDate = NSDate(timeIntervalSince1970: 60 * 60 * 24)
                    expect(subject.humanDaysSinceDate(relativeDate)).to(equal("2 days ago"))

                    relativeDate = NSDate(timeIntervalSince1970: 0)
                    expect(subject.humanDaysSinceDate(relativeDate)).to(equal("3 days ago"))
                }
            }


            describe("the number of days passed since a given date until the current date") {
                it("returns the correct number of days") {
                    let now = NSDate(timeIntervalSince1970: 60 * 60 * 24 * 3)
                    dateProvider.currentDate = now

                    var relativeDate = NSDate(timeIntervalSince1970: 60 * 60 * 24 * 3)
                    expect(subject.numberOfDaysSinceDate(relativeDate)).to(equal(0))

                    relativeDate = NSDate(timeIntervalSince1970: 60 * 60 * 24 * 2)
                    expect(subject.numberOfDaysSinceDate(relativeDate)).to(equal(1))

                    relativeDate = NSDate(timeIntervalSince1970: 60 * 60 * 24)
                    expect(subject.numberOfDaysSinceDate(relativeDate)).to(equal(2))

                    relativeDate = NSDate(timeIntervalSince1970: 0)
                    expect(subject.numberOfDaysSinceDate(relativeDate)).to(equal(3))
                }
            }
        }
    }
}
