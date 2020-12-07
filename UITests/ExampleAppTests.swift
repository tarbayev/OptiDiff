import XCTest

class ExampleAppTests: XCTestCase {

  override func setUpWithError() throws {
    continueAfterFailure = false
    let app = XCUIApplication()
    app.launchArguments.append(contentsOf: ["-AnimationSpeed", "5"])
    app.launch()
  }

  func testExample() throws {
    let app = XCUIApplication()
    XCTAssertTrue(app.otherElements.containing(.any, identifier: "Done").element.waitForExistence(timeout: 5))
  }
}
