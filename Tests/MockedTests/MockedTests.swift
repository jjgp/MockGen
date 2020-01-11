import XCTest
@testable import Mocked

protocol Protocol {
    
    var foo: Any { get }
    var bar: Any { get set }
    
    func someFunction() -> Int
    func someFunction(_ arg: Int) -> Int
    func someThrowingFunction() throws
    
}

struct ProtocolMocked: Protocol, Mocked {
    
    enum CalleeKeys: String, CalleeKey {
        
        case someFunction = "someFunction()"
        case someFunctionWithArg = "someFunction(_:)"
        case someThrowingFunction = "someThrowingFunction()"
        
    }
    
    var foo: Any = 1
    var bar: Any = 2
    let mock = Mock<CalleeKeys>()
    
    func someFunction() -> Int {
        return try! mocked()
    }
    
    func someFunction(_ arg: Int) -> Int {
        return try! mocked(arguments: arg)
    }
    
    func someThrowingFunction() throws {
        try mocked()
    }
    
}

struct ProtocolNicelyMocked: Protocol, NicelyMocked {
    
    enum CalleeKeys: String, CalleeKey {
        
        case someFunction = "someFunction()"
        case someFunctionWithArg = "someFunction(_:)"
        
    }
    
    var foo: Any = 1
    var bar: Any = 2
    let mock = Mock<CalleeKeys>()
    
    func someFunction() -> Int {
        return try! mocked()
    }
    
    func someFunction(_ arg: Int) -> Int {
        return try! mocked(arguments: arg)
    }
    
    func someThrowingFunction() throws {
        try mocked()
    }
    
}

struct AnError: Error {}

extension ProtocolNicelyMocked {
    
    func returnValue(for call: MockCall) -> Any! {
        let (callee, _) = call
        switch callee {
        case .someFunction:
            return 42
        case .someFunctionWithArg:
            return 420
        }
    }
    
}

final class MockedTests: XCTestCase {
    
    func testProtocolMocked() {
        let protocolMocked = ProtocolMocked()
        protocolMocked.stub(.someFunction, returning: 42)
        XCTAssertEqual(protocolMocked.someFunction(), 42)
        protocolMocked.stub(.someFunctionWithArg, returning: 420)
        XCTAssertEqual(protocolMocked.someFunction(420), 420)
        protocolMocked.stub(.someThrowingFunction, throwing: AnError())
        XCTAssertThrowsError(try protocolMocked.someThrowingFunction())
    }
    
    func testProtocolNicelyMocked() {
        let protocolMocked = ProtocolNicelyMocked()
        XCTAssertEqual(protocolMocked.someFunction(), 42)
        XCTAssertEqual(protocolMocked.someFunction(420), 420)
    }
    
}

extension MockedTests {
    
    static var allTests = [
        ("testProtocolMocked", testProtocolMocked),
        ("testProtocolNicelyMocked", testProtocolNicelyMocked)
    ]
    
}
