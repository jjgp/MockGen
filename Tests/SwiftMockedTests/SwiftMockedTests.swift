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
        
        let calls = protocolMocked.calls()
        calls.total() == 5
        calls.total() >= 5
        calls.total() <= 5
        calls.total() < 6
        calls.total() > 4
        
        let callees = Verify.callees(in: calls)
        callees.inspect() == .someOtherFunction
        callees.inspect(1) == .someFunction
        callees.inspect(2) == .someFunctionWithArg
        callees.inspect(3) == .someFunctionWithArg
        callees.inspect(4) == .someFunction
        callees.last(3) == [.someOtherFunction, .someFunction, .someFunctionWithArg]
        callees.first(3) == [.someFunction, .someFunctionWithArg, .someFunctionWithArg]
        
        var invocations = Verify.invocations(in: calls, to: .someFunction)
        invocations.total() == 2
        invocations.total() >= 2
        invocations.total() <= 2
        invocations.total() < 3
        invocations.total() > 1
        
        invocations = Verify.invocations(in: calls, to: .someFunctionWithArg)
        invocations.inspect().argument() == 42
        invocations.inspect(1).argument() == 41
        
        protocolMocked.calls(missing: .someThrowingFunction)
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
    
    var foo: Any {
        get {
            try! mocked() as Any
        }
    }
    var bar: Any {
        get {
            try! mocked() as Any
        }
        set {
            try! mocked()
        }
    }
    let mock = Mock<CalleeKeys>()
    
    func someFunction() -> Int {
        return try! mocked()
    }
    
    func someFunction(_ arg: Int) -> Int {
        return try! mocked(arguments: arg)
    }
    
    func someOtherFunction() {
        try! mocked()
    }
    
    func someThrowingFunction() throws {
        try mocked()
    }
    
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
