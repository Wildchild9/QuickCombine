import XCTest
import Combine
import SwiftUI
@testable import QuickCombine

final class QuickCombineTests: XCTestCase {
    func testReplaceNilWithError() {
        let nilString: String? = nil
        let presentString: String? = "Some string"

        let expectation = XCTestExpectation()
        expectation.expectedFulfillmentCount = 3

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
                expectation.fulfill()
            }) { _ in }
            .cancel()
        
        Just(presentString)
            .setFailureType(to: Error.self)
            .replaceNil(with: CustomError())
            .sink(receiveCompletion: { completion in
                if case .failure = completion {
                    XCTFail("Value is present")
                }
                expectation.fulfill()
            }) { value in
                XCTAssertEqual(value, "Some string")
            }
            .cancel()
        
        enum Foo: Error {
            case error
        }
        func staticType<T>(of _: T) -> String {
            return "\(T.self)"
        }
        
        Just(nilString)
            .replaceNil(with: Foo.error)
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    XCTAssertEqual(staticType(of: error), "Foo")
                    print("Error Type ▿")
                    print("  Static:", staticType(of: error))
                    print("  Dynamic:", type(of: error))
                }
                expectation.fulfill()
            }, receiveValue: { _ in })
        
        wait(for: [expectation], timeout: 5)
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
    
    func testAsyncMap() {
        let expectation = XCTestExpectation()
        Just("hello")
            .asyncMap { (value, promise: (String) -> Void) in
                promise("a")
                promise("bc")
            }
            .collect(2)
            .sink { value in
                let str = value.joined()
                XCTAssertEqual(str, "abc")
                expectation.fulfill()
            }
            .cancel()

        wait(for: [expectation], timeout: 2)
    }
    
    func testTryAsyncMap() {
        let expectation1 = XCTestExpectation()
        let expectation2 = XCTestExpectation()

        expectation1.expectedFulfillmentCount = 1
        expectation1.assertForOverFulfill = true
        expectation2.expectedFulfillmentCount = 3
        expectation2.assertForOverFulfill = true

        Just("a")
            .setFailureType(to: CustomError.self)
            .tryAsyncMap { (value, promise: (Result<String, CustomError>) -> Void) in
                promise(.success(value + "bc"))
                promise(.success("abc"))
                promise(.failure(CustomError()))
                promise(.success("abc"))
            }
            .catch { error -> Empty<String, Never> in
                expectation1.fulfill()
                return Empty()
            }
            .sink { value in
                XCTAssertEqual(value, "abc")
                expectation2.fulfill()
            }
            .cancel()

        wait(for: [expectation1, expectation2], timeout: 2)
    }
    
    func testFutureMap() {
        let expectation = XCTestExpectation()
        expectation.assertForOverFulfill = true
        
        Just("Hello")
            .futureMap { (value, promise: (String) -> Void) in
                promise(value + ", World!")
                promise("Cannot reach")
            }
            .sink { _ in
                expectation.fulfill()
            }
            .cancel()
        
        wait(for: [expectation], timeout: 2)
    }
    
    func testTryFutureMap() {
        let expectation1 = XCTestExpectation()
        let expectation2 = XCTestExpectation()
        let expectation3 = XCTestExpectation()

        expectation1.assertForOverFulfill = true
        
        Just("Hello")
            .tryFutureMap { value, promise in
                promise(.success(value + ", World!"))
                promise(.success("Cannot reach"))
            }
            .catch { _ in Empty<String, Never>() }
            .sink { _ in
                expectation1.fulfill()
            }
            .cancel()
        
        Just("")
            .setFailureType(to: Error.self)
            .tryFutureMap { (value, promise: (Result<String, Error>) -> Void) in
                if value.isEmpty {
                    throw CustomError()
                } else {
                    promise(.success("It is not empty!"))
                }
            }
            .sink(receiveCompletion: { completion in
                guard case .failure = completion else {
                    XCTFail()
                    return
                }
                expectation2.fulfill()
            }, receiveValue: { _ in
                XCTFail()
            })
            .cancel()
        
        Just("")
            .setFailureType(to: CustomError.self)
            .tryFutureMap { (value, promise: (Result<String, CustomError>) -> Void) in
                if value.isEmpty {
                    promise(.failure(CustomError()))
                } else {
                    promise(.success("It is not empty!"))
                }
            }
            .sink(receiveCompletion: { completion in
                guard case .failure = completion else {
                    XCTFail()
                    return
                }
                expectation3.fulfill()
            }, receiveValue: { _ in
                XCTFail()
            })
            .cancel()
        
        wait(for: [expectation1, expectation2, expectation3], timeout: 2)
    }
    
    func testCompactMap() {
        let expectation = XCTestExpectation()

        Just("Hello, World!")
            .compactMap(\.first)
            .sink { value in
                XCTAssertEqual(value, "H")
                expectation.fulfill()
            }
            .cancel()
        
        Just("")
            .compactMap(\.last)
            .sink { value in
                XCTFail()
            }
            .cancel()
        
        wait(for: [expectation], timeout: 2)
    }
    
    func testEraseToAnyError() {
        let expectation = XCTestExpectation()
        
        expectation.expectedFulfillmentCount = 2
        
        Future<String, CustomError> { promise in
            promise(.failure(CustomError()))
        }
            .handleEvents(receiveCompletion: { completion in
                if case .failure = completion {
                    expectation.fulfill()
                }
            })
            .eraseToAnyError()
            .sink(receiveCompletion: { completion in
                if case .failure = completion {
                    expectation.fulfill()
                }
            }) { _ in }
            .cancel()
        
        wait(for: [expectation], timeout: 2)
    }
    
    func testPassthrough() {
        let expectation = XCTestExpectation()
        
        Just(1)
            .passthrough { XCTAssertEqual($0, 1) }
            .map { value in value * 10 }
            .passthrough { XCTAssertEqual($0, 10) }
            .tryMap { value throws -> Int in
                if value == 10 {
                    throw CustomError()
                } else {
                    return value
                }
            }
            .passthrough { value in
                XCTFail()
            }
            .sink(receiveCompletion: { completion in
                guard case .failure = completion else {
                    XCTFail()
                    return
                }
                expectation.fulfill()
            }) { _ in }
            .cancel()
        
        wait(for: [expectation], timeout: 2)
    }

    func testAssign() {
        class Foo {
            var a = ""
            init() { }
        }
        
        let foo = Foo()
        
        Just(123)
            .assign(\.description, to: \.a, on: foo)
            .cancel()
        
        XCTAssertEqual(foo.a, "123")
        
        var bar = 7
        
        Just(123)
            .assign(to: Binding(get: { bar }, set: { bar = $0 }))
            .cancel()
       
        XCTAssertEqual(bar, 123)
        
        var baz = 4

        Just("Hello, World!")
            .assign(\.count, to: Binding(get: { baz }, set: { baz = $0 }))
            .cancel()
        
        XCTAssertEqual(baz, "Hello, World!".count)
    }
    
    func testPassthroughAssign() {
        let expectation = XCTestExpectation()
        class Foo {
            var a = ""
            init() { }
        }
        
        let foo = Foo()
        var bar = 7
        var baz = ""
        
        Just("abcde")
            .passthroughAssign(\.count.description, to: \.a, on: foo)
            .handleEvents(receiveOutput: { _ in XCTAssertEqual(foo.a, "5") })
            .map { $0 + "fghij" }
            .passthroughAssign(to: \.a, on: foo)
            .handleEvents(receiveOutput: { _ in XCTAssertEqual(foo.a, "abcdefghij") })
            .map(\.count)
            .passthroughAssign(to: Binding(get: { bar }, set: { bar = $0 }))
            .handleEvents(receiveOutput: { _ in XCTAssertEqual(bar, 10) })
            .map { "\($0)0abc" }
            .passthroughAssign(\.description, to: Binding(get: { baz }, set: { baz = $0 }))
            .handleEvents(receiveOutput: { _ in XCTAssertEqual(baz, "100abc") })
            .map { $0.prefix(3) }
            .compactMap { Int($0) }
            .sink { value in
                XCTAssertEqual(value, 100)
                expectation.fulfill()
            }
            .cancel()
        
        wait(for: [expectation], timeout: 2)
    }
    
    static var allTests = [
        ("testReplaceNilWithError", testReplaceNilWithError),
        ("testIgnoreFailure", testIgnoreFailure),
        ("testAsync", testAsync),
        ("testTryAsync", testTryAsync),
        ("testAsyncMap", testAsyncMap),
        ("testTryAsyncMap", testTryAsyncMap),
        ("testFutureMap", testFutureMap),
        ("testTryFutureMap", testTryFutureMap),
        ("testCompactMap", testCompactMap),
        ("testEraseToAnyError", testEraseToAnyError),
        ("testPassthrough", testPassthrough),
        ("testAssign", testAssign),
        ("testPassthroughAssign", testPassthroughAssign),
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
