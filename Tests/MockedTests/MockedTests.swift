import XCTest
@testable import Mocked

protocol Protocol {
    
    var foo: Any { get }
    var bar: Any { get set }
    
    func someFunction() -> Int
    func someFunction(_ arg: Int) -> Int
    
}

struct ProtocolMocked: Protocol, Mocked {
    
    enum CalleeKeys: String, CalleeKey {
        
        case someFunction = "someFunction()"
        case someFunctionWithArg = "someFunction(_:)"
        
    }
    
    var foo: Any = 1
    var bar: Any = 2
    let mock = Mock<CalleeKeys>()
    
    func someFunction() -> Int {
        return mocked()
    }
    
    func someFunction(_ arg: Int) -> Int {
        return mocked(args: arg)
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
        return mocked()
    }
    
    func someFunction(_ arg: Int) -> Int {
        return mocked(args: arg)
    }
    
}

extension ProtocolNicelyMocked {
    
    func returnValue(for callee: CalleeKeys) -> Any! {
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
        protocolMocked.stub(.someFunctionWithArg, returning: 420)
        XCTAssertEqual(protocolMocked.someFunction(), 42)
        XCTAssertEqual(protocolMocked.someFunction(420), 420)
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
