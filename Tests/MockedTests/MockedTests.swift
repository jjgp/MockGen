import XCTest
@testable import Mocked

final class MockedTests: XCTestCase {
    
    func testProtocolMockedStub() {
        let protocolMocked = ProtocolMocked()
        protocolMocked.stub(.someFunction, returning: 42)
        XCTAssertEqual(protocolMocked.someFunction(), 42)
        protocolMocked.stub(.someFunctionWithArg, returning: 420)
        XCTAssertEqual(protocolMocked.someFunction(420), 420)
        protocolMocked.stub(.someThrowingFunction, throwing: AnError())
        XCTAssertThrowsError(try protocolMocked.someThrowingFunction())
    }
    
    func testProtocolNicelyMockedReturnValue() {
        let protocolMocked = ProtocolNicelyMocked()
        XCTAssertEqual(protocolMocked.someFunction(), 42)
        XCTAssertEqual(protocolMocked.someFunction(420), 420)
    }
    
    func testProtocolNicelyMockedVerify() {
        let protocolMocked = ProtocolNicelyMocked()
        _ = protocolMocked.someFunction()
        _ = protocolMocked.someFunction(42)
        _ = protocolMocked.someFunction(42)
        _ = protocolMocked.someFunction()
        
        XCTAssertTrue(
            protocolMocked.verify(order: [
                .someFunction,
                .someFunctionWithArg,
                .someFunctionWithArg,
                .someFunction
            ])
        )
        
        XCTAssertTrue(protocolMocked.verify(.someFunction))
        XCTAssertTrue(protocolMocked.verify(.someFunctionWithArg))
        XCTAssertFalse(protocolMocked.verify(.someThrowingFunction))
        
        XCTAssertTrue(protocolMocked.verify(.someFunction, times: 2))
        XCTAssertTrue(protocolMocked.verify(.someFunctionWithArg, times: 2))
        XCTAssertTrue(protocolMocked.verify(.someThrowingFunction, times: 0))
        
        protocolMocked.verify(.someFunctionWithArg) { arguments in
            XCTAssertTrue(arguments?[0] == 42)
        }
        
        XCTAssertTrue(protocolMocked.verify(missing: .someThrowingFunction))
        XCTAssertFalse(protocolMocked.verify(missing: .someFunction))
        XCTAssertFalse(protocolMocked.verify(missing: .someFunctionWithArg))
        
        XCTAssertTrue(protocolMocked.verify(numberOfCalls: 4))
    }
    
}

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

struct AnError: Error {}

extension ProtocolNicelyMocked {
    
    func returnValue(for call: Call) -> Any! {
        let (callee, _) = call
        switch callee {
        case .someFunction:
            return 42
        case .someFunctionWithArg:
            return 420
        default:
            return nil
        }
    }
    
}

extension MockedTests {
    
    static var allTests = [
        ("testProtocolMockedStub", testProtocolMockedStub),
        ("testProtocolNicelyMockedReturnValue", testProtocolNicelyMockedReturnValue),
        ("testProtocolNicelyMockedVerify", testProtocolNicelyMockedVerify),
    ]
    
}
