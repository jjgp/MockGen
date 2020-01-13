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
    
    func testProtocolMockedVerify() {
        let protocolMocked = ProtocolMocked()
        _ = protocolMocked.someFunction()
        _ = protocolMocked.someFunction(41)
        _ = protocolMocked.someFunction(42)
        _ = protocolMocked.someFunction()
        protocolMocked.someOtherFunction()
        
        protocolMocked.verify { calls in
            let callees = calls?.map { $0.callee }
            XCTAssertEqual(callees, [
                .someFunction,
                .someFunctionWithArg,
                .someFunctionWithArg,
                .someFunction,
                .someOtherFunction
            ])
        }
        protocolMocked.verify(.someFunction)
        protocolMocked.verify(.someFunctionWithArg)
        protocolMocked.verify(.someOtherFunction)
        protocolMocked.verify(missing: .someThrowingFunction)
        protocolMocked.verify(.someFunction, times: 2)
        protocolMocked.verify(.someFunctionWithArg, times: 2)
        protocolMocked.verify(.someOtherFunction, times: 1)
        protocolMocked.verify(.someThrowingFunction, times: 0)
        protocolMocked.verify(.someFunctionWithArg) { invocations in
            guard invocations?.count == 2 else {
                XCTFail()
                return
            }
            
            XCTAssertEqual(invocations?[0].at(0), 41)
            XCTAssertEqual(invocations?[1].at(0), 42)
        }
        protocolMocked.verify(numberOfCalls: 5)
    }
    
    func testVerifyProtocolMocked() {
        let protocolMocked = ProtocolMocked()
        _ = protocolMocked.someFunction()
        _ = protocolMocked.someFunction(41)
        _ = protocolMocked.someFunction(42)
        _ = protocolMocked.someFunction()
        protocolMocked.someOtherFunction()
        
        let verify = Verify(protocolMocked)
        verify.calls(to: .someFunction)
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
    let returnValue: ((Call) -> Any?)? = Self.returnedValue
    
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
    
    static var returnedValue: ((Call) -> Any?)? {
        return { call in
            let (callee, _) = call
            switch callee {
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
        ("testProtocolMockedVerify", testProtocolMockedVerify)
    ]
    
}
