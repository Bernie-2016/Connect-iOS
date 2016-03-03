import Quick
import Nimble
@testable import Connect

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
