import Quick
import Nimble

@testable import Movement

class ZipCodeValidatorSpec: QuickSpec {
    override func spec() {
        describe("StockZipCodeValidator") {
            var subject: ZipCodeValidator!

            beforeEach { subject = StockZipCodeValidator() }

            describe("validating a zip code") {
                context("that is give numeric characters") {
                    it("returns true") { expect(subject.validate("12345")).to(beTrue()) }
                }

                context("that is give numeric characters with a leading zero") {
                    it("returns true") { expect(subject.validate("01234")).to(beTrue()) }
                }

                context("that is an empty string") {
                    it("returns false") { expect(subject.validate("")).to(beFalse()) }
                }

                context("that contains non-numeric characters") {
                    it("returns false") { expect(subject.validate("123@5")).to(beFalse()) }
                }

                context("that is less than five numeric characters") {
                    it("returns false") { expect(subject.validate("1235")).to(beFalse()) }
                }

                context("this is more than five numeric characters") {
                    it("returns false") { expect(subject.validate("012345")).to(beFalse()) }
                }
            }
        }
    }
}
