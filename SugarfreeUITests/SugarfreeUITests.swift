import XCTest

final class SugarfreeUITests: XCTestCase {
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }

    func testTabBarExists() throws {
        XCTAssertTrue(app.tabBars.buttons["Dashboard"].exists)
        XCTAssertTrue(app.tabBars.buttons["Scan"].exists)
        XCTAssertTrue(app.tabBars.buttons["Log"].exists)
        XCTAssertTrue(app.tabBars.buttons["Goals"].exists)
    }

    func testNavigationBetweenTabs() throws {
        app.tabBars.buttons["Goals"].tap()
        XCTAssertTrue(app.navigationBars["Goals"].exists)

        app.tabBars.buttons["Dashboard"].tap()
        XCTAssertTrue(app.navigationBars["Sugarfree"].exists)
    }
}
