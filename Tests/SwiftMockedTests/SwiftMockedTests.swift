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
        
        protocolMocked.stub(.someFunctionWithFoo) { ($0[argument: 0] ?? 0) * 100 }
        XCTAssertEqual(protocolMocked.someFunction(420), 42000)
        
        var call: ProtocolMocked.Call?
        protocolMocked.stub(.someOtherFunction) { call = $0 }
        protocolMocked.someOtherFunction()
        XCTAssertNotNil(call)
    }
    
    func testVerifyProtocolMocked() {
        let mocked = ProtocolMocked()
        _ = mocked.someFunction()
        _ = mocked.someFunction(41)
        _ = mocked.someFunction(42)
        _ = mocked.someFunction(bar: 43)
        _ = mocked.someFunction()
        _ = mocked.someFunction(42, bar: 43)
        mocked.someOtherFunction()
        
        XCTAssertEqual(mocked.calls.count, 7)
        expect(mocked.calls.last?.key) == .someOtherFunction
        expect(mocked.calls[afterFirst: 2]?[argument: 0]) == 42
        
        XCTAssertEqual(mocked.calls[to: .someFunction].count, 2)

        let calls = mocked.calls[to: .someFunctionWithFoo]
        expect(calls.count) == 2
        expect(calls.first?[argument: 0]) == 41
        expect(calls[afterFirst: 0]?[argument: 0]) == 41
        expect(calls[beforeLast: 1]?[argument: 0]) == 41
        expect(calls.last?[argument: 0]) == 42
        expect(calls[afterFirst: 1]?[argument: 0]) == 42
        expect(calls[beforeLast: 0]?[argument: 0]) == 42

        expect(mocked.calls[head: 3].keys.contains(.someFunction)).to(beTrue())
        expect(mocked.calls[head: 3].keys) == [.someFunction, .someFunctionWithFoo, .someFunctionWithFoo]
        expect(mocked.calls[head: 5].keys) == [
            .someFunction, .someFunctionWithFoo, .someFunctionWithFoo, .someFunctionWithBar, .someFunction
        ]
        expect(mocked.calls[head: 6].keys) == [
            .someFunction, .someFunctionWithFoo, .someFunctionWithFoo, .someFunctionWithBar, .someFunction,
            .someFunctionWithFooAndBar
        ]
        expect(mocked.calls[tail: 3].keys) == [.someFunction, .someFunctionWithFooAndBar, .someOtherFunction]
        expect(mocked.calls[tail: 5].keys) == [
            .someFunctionWithFoo, .someFunctionWithBar, .someFunction, .someFunctionWithFooAndBar, .someOtherFunction
        ]
        expect(mocked.calls[tail: 6].keys) == [
            .someFunctionWithFoo, .someFunctionWithFoo, .someFunctionWithBar, .someFunction, .someFunctionWithFooAndBar,
            .someOtherFunction
        ]
        expect(mocked.calls.keys) == [
            .someFunction, .someFunctionWithFoo, .someFunctionWithFoo, .someFunctionWithBar, .someFunction,
            .someFunctionWithFooAndBar, .someOtherFunction
        ]
    }
    
}

protocol Protocol {
    var foo: Any { get }
    var bar: Any { get set }
    
    func someFunction() -> Int
    func someFunction(_ foo: Int) -> Int
    func someFunction(bar: UInt) -> Int
    func someFunction(_ foo: Int, bar: UInt) -> Int
    func someOtherFunction()
    func someThrowingFunction() throws
}

struct ProtocolMocked: Protocol, Mocked {
    enum CalleeKeys: String, CalleeKey {
        case foo = "foo"
        case bar = "bar"
        case someFunction = "someFunction()"
        case someFunctionWithFoo = "someFunction(_:)"
        case someFunctionWithBar = "someFunction(bar:)"
        case someFunctionWithFooAndBar = "someFunction(_:bar:)"
        case someOtherFunction = "someOtherFunction()"
        case someThrowingFunction = "someThrowingFunction()"
    }
    var foo: Any { get { try! mocked() as Any } }
    var bar: Any { get { try! mocked() as Any } set { try! mocked() } }
    let mock = Mock<CalleeKeys>()
    func someFunction() -> Int { return try! mocked() }
    func someFunction(_ foo: Int) -> Int { return try! mocked(arguments: foo) }
    func someFunction(bar: UInt) -> Int { return try! mocked(arguments: bar) }
    func someFunction(_ foo: Int, bar: UInt) -> Int { return try! mocked(arguments: foo, bar) }
    func someOtherFunction() { try! mocked() }
    func someThrowingFunction() throws { try mocked() }
}

extension ProtocolMocked {
    func defaultStub() -> Stub? {
        return { call in
            switch call.key {
            case .foo:
                return 4.2
            case .bar:
                return 4200
            case .someFunction:
                return 42
            case .someFunctionWithFoo:
                return 420
            case .someFunctionWithBar:
                return 43
            case .someFunctionWithFooAndBar:
                return 43
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
