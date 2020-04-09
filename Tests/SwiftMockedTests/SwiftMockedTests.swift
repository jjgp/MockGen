import Nimble
import XCTest
@testable import SwiftMocked

final class SwiftMockedTests: XCTestCase {
    
    func testProtocolMockedReturnValue() {
        let protocolMocked = ProtocolMocked()
        XCTAssertEqual(protocolMocked.foo as? Double, 4.2)
        XCTAssertEqual(protocolMocked.bar as? Int, 4200)
        XCTAssertEqual(protocolMocked.someFunction(), 42)
        XCTAssertEqual(protocolMocked.someFunction(420), 420)
    }
    
    func testProtocolMockedStubs() {
        let protocolMocked = ProtocolMocked()
        protocolMocked.stub(.foo, returning: 42000)
        XCTAssertEqual(protocolMocked.foo as? Int, 42000)
        
        protocolMocked.stub(.someFunctionWithArg) {
            ($0.arguments.argument(0) ?? 0) * 100
        }
        XCTAssertEqual(protocolMocked.someFunction(420), 42000)
        
        var call: ProtocolMocked.Call?
        protocolMocked.stub(.someOtherFunction) {
            call = $0
        }
        protocolMocked.someOtherFunction()
        XCTAssertNotNil(call)
    }
    
    func testVerifyProtocolMocked() {
        let protocolMocked = ProtocolMocked()
        _ = protocolMocked.someFunction()
        _ = protocolMocked.someFunction(41)
        _ = protocolMocked.someFunction(42)
        _ = protocolMocked.someFunction()
        protocolMocked.someOtherFunction()
        
        let calls = protocolMocked.calls
        XCTAssertEqual(calls.count, 5)
        expect(calls.inspect()?.callee) == .someOtherFunction
        expect(calls.inspect(2)?.arguments.argument()) == 42
        
        XCTAssertTrue(protocolMocked.calls(missing: .someThrowingFunction))
        
        var invocations = protocolMocked.calls(to: .someFunction)
        XCTAssertEqual(invocations.count, 2)
        
        invocations = protocolMocked.calls(to: .someFunctionWithArg)
        expect(invocations.inspect()?.argument()) == 42
        expect(invocations.inspect(1)?.argument()) == 41
        
        let callees = protocolMocked.callees
        XCTAssertEqual(callees.inspect(), .someOtherFunction)
        expect(callees.inspect(1)) == .someFunction
        XCTAssertTrue(callees.inspect(2) == .someFunctionWithArg)
        expect(callees.inspect(3)) == .someFunctionWithArg
        expect(callees.inspect(4)) == .someFunction
        expect(callees.last(3)) == [.someOtherFunction, .someFunction, .someFunctionWithArg]
        expect(callees.first(3)) == [.someFunction, .someFunctionWithArg, .someFunctionWithArg]
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
        case foo = "foo"
        case bar = "bar"
        case someFunction = "someFunction()"
        case someFunctionWithArg = "someFunction(_:)"
        case someOtherFunction = "someOtherFunction()"
        case someThrowingFunction = "someThrowingFunction()"
    }
    var foo: Any { get { try! mocked() as Any } }
    var bar: Any { get { try! mocked() as Any } set { try! mocked() } }
    let mock = Mock<CalleeKeys>()
    func someFunction() -> Int { return try! mocked() }
    func someFunction(_ arg: Int) -> Int { return try! mocked(arguments: arg) }
    func someOtherFunction() { try! mocked() }
    func someThrowingFunction() throws { try mocked() }
}

extension ProtocolMocked {
    func defaultStub() -> Stub? {
        return { call in
            switch call.callee {
            case .foo:
                return 4.2
            case .bar:
                return 4200
            case .someFunction:
                return 42
            case .someFunctionWithArg:
                return 420
            default:
                return nil
            }
        }
    }
}

struct AnError: Error {}

extension SwiftMockedTests {
    
    static var allTests = [
        ("testProtocolMockedReturnValue", testProtocolMockedReturnValue),
        ("testVerifyProtocolMocked", testVerifyProtocolMocked)
    ]
    
}
