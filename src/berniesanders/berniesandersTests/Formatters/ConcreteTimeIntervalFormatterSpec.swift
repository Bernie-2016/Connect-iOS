import Quick
import Nimble
@testable import berniesanders

class FakeDateProvider: DateProvider {
    var currentDate: NSDate?

    func now() -> NSDate {
        return self.currentDate!
    }
}

class ConcreteTimeIntervalFormatterSpec: QuickSpec {
    var subject: TimeIntervalFormatter!
    var dateProvider: FakeDateProvider!

    override func spec() {
        describe("TimeIntervalFormatter") {
            beforeEach {
                self.dateProvider = FakeDateProvider()

                self.subject = ConcreteTimeIntervalFormatter(
                    dateProvider: self.dateProvider
                )
            }

            describe("human representation of a date relative to the current date") {
                it("returns the correct text when the interval is within the current day") {
                    var now = NSDate()
                    self.dateProvider.currentDate = now

                    expect(self.subject.humanDaysSinceDate(now)).to(equal("Today"))

                    now = NSDate(timeIntervalSince1970: 60 * 60 * 24)
                    self.dateProvider.currentDate = now

                    var relativeDate = NSDate(timeIntervalSince1970: (60 * 60 * 23))
                    expect(self.subject.humanDaysSinceDate(relativeDate)).to(equal("Today"))

                    relativeDate = NSDate(timeIntervalSince1970: 1)
                    expect(self.subject.humanDaysSinceDate(relativeDate)).to(equal("Today"))

                }

                it("returns the correct text when the interval is within the previous day") {
                    let now = NSDate(timeIntervalSince1970: 60 * 60 * 24 * 2)
                    self.dateProvider.currentDate = now

                    var relativeDate = NSDate(timeIntervalSince1970: (60 * 60 * 24) - 1)
                    expect(self.subject.humanDaysSinceDate(relativeDate)).to(equal("Yesterday"))

                    relativeDate = NSDate(timeIntervalSince1970: 1)
                    expect(self.subject.humanDaysSinceDate(relativeDate)).to(equal("Yesterday"))
                }

                it("returns the correct text when the interval is more than 1 day") {
                    let now = NSDate(timeIntervalSince1970: 60 * 60 * 24 * 3)
                    self.dateProvider.currentDate = now

                    var relativeDate = NSDate(timeIntervalSince1970: 60 * 60 * 24)
                    expect(self.subject.humanDaysSinceDate(relativeDate)).to(equal("2 days ago"))

                    relativeDate = NSDate(timeIntervalSince1970: 0)
                    expect(self.subject.humanDaysSinceDate(relativeDate)).to(equal("3 days ago"))
                }
            }

            describe("abbreviated human representation of a date relative to the current date") {
                it("returns the correct text when the interval is within the current day") {
                    var now = NSDate()
                    self.dateProvider.currentDate = now

                    expect(self.subject.abbreviatedHumanDaysSinceDate(now)).to(equal("now"))

                    now = NSDate(timeIntervalSince1970: 60 * 60 * 24)
                    self.dateProvider.currentDate = now

                    var relativeDate = NSDate(timeIntervalSince1970: (60 * 60 * 23))
                    expect(self.subject.abbreviatedHumanDaysSinceDate(relativeDate)).to(equal("now"))

                    relativeDate = NSDate(timeIntervalSince1970: 1)
                    expect(self.subject.abbreviatedHumanDaysSinceDate(relativeDate)).to(equal("now"))

                }

                it("returns the correct text when the interval is within the previous day") {
                    let now = NSDate(timeIntervalSince1970: 60 * 60 * 24 * 2)
                    self.dateProvider.currentDate = now

                    var relativeDate = NSDate(timeIntervalSince1970: (60 * 60 * 24) - 1)
                    expect(self.subject.abbreviatedHumanDaysSinceDate(relativeDate)).to(equal("1d"))

                    relativeDate = NSDate(timeIntervalSince1970: 1)
                    expect(self.subject.abbreviatedHumanDaysSinceDate(relativeDate)).to(equal("1d"))
                }

                it("returns the correct text when the interval is more than 1 day") {
                    let now = NSDate(timeIntervalSince1970: 60 * 60 * 24 * 3)
                    self.dateProvider.currentDate = now

                    var relativeDate = NSDate(timeIntervalSince1970: 60 * 60 * 24)
                    expect(self.subject.abbreviatedHumanDaysSinceDate(relativeDate)).to(equal("2d"))

                    relativeDate = NSDate(timeIntervalSince1970: 0)
                    expect(self.subject.abbreviatedHumanDaysSinceDate(relativeDate)).to(equal("3d"))
                }
            }
        }

        describe("the number of days passed since a given date until the current date") {
            it("returns the correct number of days") {
                let now = NSDate(timeIntervalSince1970: 60 * 60 * 24 * 3)
                self.dateProvider.currentDate = now

                var relativeDate = NSDate(timeIntervalSince1970: 60 * 60 * 24 * 3)
                expect(self.subject.numberOfDaysSinceDate(relativeDate)).to(equal(0))

                relativeDate = NSDate(timeIntervalSince1970: 60 * 60 * 24 * 2)
                expect(self.subject.numberOfDaysSinceDate(relativeDate)).to(equal(1))

                relativeDate = NSDate(timeIntervalSince1970: 60 * 60 * 24)
                expect(self.subject.numberOfDaysSinceDate(relativeDate)).to(equal(2))

                relativeDate = NSDate(timeIntervalSince1970: 0)
                expect(self.subject.numberOfDaysSinceDate(relativeDate)).to(equal(3))
            }
        }
    }
}
