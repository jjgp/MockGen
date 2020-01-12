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
        _ = protocolMocked.someFunction(41)
        _ = protocolMocked.someFunction(42)
        _ = protocolMocked.someFunction()
        
        protocolMocked.verify { calls in
            let callees = calls?.map { $0.callee }
            XCTAssertEqual(callees, [
                .someFunction,
                .someFunctionWithArg,
                .someFunctionWithArg,
                .someFunction
            ])
        }
        protocolMocked.verify(.someFunction)
        protocolMocked.verify(.someFunctionWithArg)
        protocolMocked.verify(missing: .someThrowingFunction)
        protocolMocked.verify(.someFunction, times: 2)
        protocolMocked.verify(.someFunctionWithArg, times: 2)
        protocolMocked.verify(.someThrowingFunction, times: 0)
        protocolMocked.verify(.someFunctionWithArg) { invocations in
            guard invocations?.count == 2 else {
                XCTFail()
                return
            }
            
            XCTAssertEqual(invocations?[0].at(0), 41)
            XCTAssertEqual(invocations?[1].at(0), 42)
        }
        protocolMocked.verify(numberOfCalls: 4)
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
