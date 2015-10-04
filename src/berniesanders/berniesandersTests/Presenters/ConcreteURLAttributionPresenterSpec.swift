import Foundation
import Quick
import Nimble
import berniesanders

class ConcreteURLAttributionPresenterSpec: QuickSpec {
    var subject: ConcreteURLAttributionPresenter!
    override func spec() {
        describe("ConcreteURLAttributionPresenter") {
            beforeEach {
                self.subject = ConcreteURLAttributionPresenter()
            }
            
            describe("presenting attribution for a URL") {
                it("returns the correct attribution text") {
                    let url = NSURL(string: "https://foobar.co.uk/article/whatevs/123")!
                    expect(self.subject.attributionTextForURL(url)).to(equal("This content is a reformatted version of the original from foobar.co.uk, and is reproduced for educational use only."))
                }
            }
        }
    }
}
