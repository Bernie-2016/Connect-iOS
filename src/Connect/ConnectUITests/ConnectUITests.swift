import XCTest
import Quick
import Nimble

class ConnectUISpec: QuickSpec {
    override func spec() {
        describe("The Tab Bar") {
            var app: XCUIApplication!
            
            beforeEach {
                XCUIApplication().launch()
                
                app = XCUIApplication()
                
                if app.buttons["GET STARTED"].exists {
                    app.buttons["GET STARTED"].tap()
                }
            }
            
            it("has the correct tab bar") {
                expect(app.tabBars.buttons["Share This"].exists) == true
                expect(app.tabBars.buttons["News"].exists) == true
                expect(app.tabBars.buttons["Events"].exists) == true
                expect(app.tabBars.buttons["Register"].exists) == true
                
                expect(app.tabBars.buttons.count) == 4
            }
        }
    }
}
