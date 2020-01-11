import XCTest
@testable import Mocked

protocol Protocol {

    var foo: Any { get }
    var bar: Any { get set }

    func someFunction() -> Int

}

struct ProtocolMocked: Protocol, Mocked {
    
    enum CalleeKeys: String, CalleeKey {
        
        case someFunction = "someFunction()"
        case someFunctionWithArg = "someFunction(_:)"
        
    }
    
    var foo: Any = 1
    var bar: Any = 2
    let mock = Mock()
    
    func someFunction() -> Int {
        return mocked(args: nil)
    }
    
    func someFunction(_ arg: Int) -> Int {
        return mocked(args: arg)
    }
    
}

final class MockedTests: XCTestCase {
    func testExample() {
        let protocolMocked = ProtocolMocked()
        protocolMocked.stub(callee: .someFunction, returning: 42)
        protocolMocked.stub(callee: .someFunctionWithArg, returning: 420)
        XCTAssertEqual(protocolMocked.someFunction(), 42)
        XCTAssertEqual(protocolMocked.someFunction(420), 420)
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
