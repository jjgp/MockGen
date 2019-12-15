import XCTest
@testable import Mocked

protocol Protocol {

    var foo: Any { get }

    var bar: Any { get set }

    func someFunction() -> Int

}

struct ProtocolMocked: Protocol, Mocked {
    
    var foo: Any = 1
    var bar: Any = 2
    let mock = Mock()
    
    func someFunction() -> Int {
        return mocked(args: nil)
    }
    
}

final class MockedTests: XCTestCase {
    func testExample() {
        let protocolMocked = ProtocolMocked()
        protocolMocked.stub(callee: "someFunction()", returning: 42)
        XCTAssertEqual(protocolMocked.someFunction(), 42)
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
