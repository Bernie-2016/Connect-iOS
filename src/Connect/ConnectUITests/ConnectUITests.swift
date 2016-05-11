import XCTest
import Quick
import Nimble

class ConnectUISpec: QuickSpec {
    override func spec() {
        beforeEach {
            // Put setup code here. This method is called before the invocation of each test method in the class.

            // In UI tests it is usually best to stop immediately when a failure occurs.            
            // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
            XCUIApplication().launch()

            // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
            let app = XCUIApplication()

            if app.buttons["GET STARTED"].exists {
                app.buttons["GET STARTED"].tap()
            }
        }

        it("has the correct tab bar") {
            let app = XCUIApplication()

            expect(app.tabBars.buttons["Share This"].exists) == true
            expect(app.tabBars.buttons["News"].exists) == true
            expect(app.tabBars.buttons["Events"].exists) == true
            expect(app.tabBars.buttons["Register"].exists) == true

            expect(app.tabBars.buttons.count) == 4
            
            expect(app.tabBars.buttons["Register"]) == true
        }
    }
}
