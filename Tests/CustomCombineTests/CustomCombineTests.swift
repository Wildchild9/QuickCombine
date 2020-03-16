import XCTest
@testable import CustomCombine

final class CustomCombineTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(CustomCombine().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
