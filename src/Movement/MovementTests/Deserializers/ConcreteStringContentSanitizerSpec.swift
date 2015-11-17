import Foundation
import Quick
import Nimble
@testable import Movement

class ConcreteStringContentSanitizerSpec: QuickSpec {
    var subject: ConcreteStringContentSanitizer!
    override func spec() {
        describe("ConcreteStringContentSanitizer") {
            beforeEach {
                self.subject = ConcreteStringContentSanitizer()
            }

            describe("Sanitizing string content") {
                it("decodes html entities") {
                    expect(self.subject.sanitizeString("&#8217;quote&#8217;\n")).to(equal("’quote’\n"))
                    expect(self.subject.sanitizeString("&#8220;quote&#8221;")).to(equal("“quote”"))
                }

                it("strips text telling the user to read the rest at") {
                    let inputString = "Foo bar. Baz.\nBat.\n Read the rest at Bob's News. Bees!\nBar!"
                    let expectedString = "Foo bar. Baz.\nBat.\n  Bees!\nBar!"
                    expect(self.subject.sanitizeString(inputString)).to(equal(expectedString))
                }

                it("strips text telling the user to 'clickhere'") {
                    let inputString = "Foo bar. To do, `’some` 'stuff'  clickhere. And that!"
                    let expectedString = "Foo bar. And that!"

                    expect(self.subject.sanitizeString(inputString)).to(equal(expectedString))
                }

                it("strips text telling the user 'ishere'") {
                    let inputString = "Foo bar. To do, `’some` 'stuff'  ishere. (And other stuff ishere.) And that!"
                    let expectedString = "Foo bar.  And that!"

                    expect(self.subject.sanitizeString(inputString)).to(equal(expectedString))
                }

                it("strips text telling the user to read the 'resthere'") {
                    let inputString = "Foo bar. To do, `’some` 'stuff' resthere. (And other stuff resthere.) And that!"
                    let expectedString = "Foo bar.  And that!"

                    expect(self.subject.sanitizeString(inputString)).to(equal(expectedString))
                }

                it("strips text telling the user to read the entire 'articlehere'") {
                    let inputString = "Foo bar. To do, `’some` 'stuff' articlehere. (And other stuff articlehere.) And that!"
                    let expectedString = "Foo bar.  And that!"

                    expect(self.subject.sanitizeString(inputString)).to(equal(expectedString))
                }

                it("strips text telling the user to read the entire 'op-edhere'") {
                    let inputString = "Foo bar. To do, `’some` 'stuff' op-edhere. (And other stuff op-edhere.) And that!"
                    let expectedString = "Foo bar.  And that!"

                    expect(self.subject.sanitizeString(inputString)).to(equal(expectedString))
                }

                it("strips text telling the user to watch the event 'here:'") {
                    let inputString = "Foo bar. Avast, here: be dragons. However here:\nNo Dragons. And stuff here:"
                    let expectedString = "Foo bar. Avast, here: be dragons.No Dragons."

                    expect(self.subject.sanitizeString(inputString)).to(equal(expectedString))
                }
            }
        }
    }
}
