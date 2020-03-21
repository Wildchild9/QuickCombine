import XCTest
import Combine
@testable import CustomCombine

final class CustomCombineTests: XCTestCase {
    func testReplaceNilWithError() {
        let nilString: String? = nil
        let presentString: String? = "Some string"

        let expectation1 = XCTestExpectation()
        let expectation2 = XCTestExpectation()

        Just(nilString)
            .setFailureType(to: Error.self)
            .replaceNil(with: CustomError("Value is nil"))
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    if let customError = error as? CustomError {
                        XCTAssert(customError.message == "Value is nil")
                    } else {
                        XCTFail("Error type invalid")
                    }
                } else {
                    XCTFail("Must complete with failure.")
                }
                expectation1.fulfill()
            }) { _ in }
            .cancel()
        
        Just(presentString)
            .setFailureType(to: Error.self)
            .replaceNil(with: CustomError())
            .sink(receiveCompletion: { completion in
                if case .failure = completion {
                    XCTFail("Value is present")
                }
                expectation2.fulfill()
            }) { value in
                XCTAssertEqual(value, "Some string")
            }
            .cancel()
        
        wait(for: [expectation1, expectation2], timeout: 5)
    }
    
    func testIgnoreFailure() {
        let expectation1 = XCTestExpectation()
        let expectation2 = XCTestExpectation()
        let expectation3 = XCTestExpectation()

        Just("")
            .tryMap { _ -> String in throw CustomError() }
            .ignoreFailure()
            .handleEvents(receiveCompletion: { completion in
                if case .failure = completion {
                    XCTFail()
                }
                expectation1.fulfill()
            })
            .sink { _ in
                XCTFail()
            }
            .cancel()
        
        Just("")
            .tryMap { str in
                if str.isEmpty {
                    throw CustomError("Some error")
                }
                return str
            }
            .mapError { $0 as! CustomError }
            .ignoreFailure { error in
                XCTAssertEqual(error.message, "Some error")
                expectation2.fulfill()
            }
            .handleEvents(receiveCompletion: { completion in
                if case .failure = completion {
                    XCTFail()
                }
                expectation3.fulfill()
            })
            .eraseToAnyPublisher()
            .sink { str in
                XCTAssertEqual("Hello, World!", str)
            }
            .cancel()
        
        wait(for: [expectation1, expectation2, expectation3], timeout: 5)
    }
    
    func testAsync() {
        let expectation = XCTestExpectation()
        
        expectation.assertForOverFulfill = true
        expectation.expectedFulfillmentCount = 5
        Async<String> { promise in
            promise("a")
            promise("b")
            promise("c")
            promise("d")
            promise("e")
        }
            .sink { _ in
                expectation.fulfill()
            }
            .cancel()
        
        wait(for: [expectation], timeout: 2)
    }
    
    
    func testTryAsync() {
        let expectation1 = XCTestExpectation()
        let expectation2 = XCTestExpectation()
        
        expectation1.expectedFulfillmentCount = 2
        expectation2.expectedFulfillmentCount = 3
        
        TryAsync<String, CustomError> { promise in
            promise(.success("a"))
            promise(.failure(CustomError()))
            promise(.success("b"))
            promise(.failure(CustomError()))
            promise(.success("c"))
        }
            .sink(receiveCompletion: { completion in
                if case .failure = completion {
                    expectation1.fulfill()
                }
            }) { _ in
                expectation2.fulfill()
            }
            .cancel()
        
        wait(for: [expectation1, expectation2], timeout: 2)
    }
    
    
    static var allTests = [
        ("testReplaceNilWithError", testReplaceNilWithError),
        ("testIgnoreFailure", testIgnoreFailure),
        ("testAsync", testAsync),
        ("testTryAsync", testTryAsync),
    ]
}


fileprivate struct CustomError: Error {
    var message: String
    var file: String
    var line: UInt
    
    init(_ message: String = "An error has occurred", file: String = #file, line: UInt = #line) {
        self.message = message
        self.file = file
        self.line = line
    }
    
    var localizedDescription: String {
        return "Error: \(message): file \(file), line \(line)"
    }
}
