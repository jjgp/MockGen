public protocol Mocked {
    
    associatedtype CalleeKeys: CalleeKey
    
    var mock: Mock<CalleeKeys> { get }
    
    func mocked(callee stringValue: String, arguments: Any?...) throws
    func mocked<T>(callee stringValue: String, arguments: Any?...) throws -> T!
    func stub(_ callee: CalleeKeys, doing: @escaping Mock<CalleeKeys>.Stub)
    func stub(_ callee: CalleeKeys, returning value: Any?)
    func stub(_ callee: CalleeKeys, throwing value: Error)
    
}

public extension Mocked {
    
    typealias Call = Mock<CalleeKeys>.Call
    typealias Stub = Mock<CalleeKeys>.Stub
    
}

public extension Mocked {
    
    func mocked(callee stringValue: String = #function, arguments: Any?...) throws {
        _ = try mock.stubs[stringValue]?(recorded(stringValue, arguments))
    }
    
    func mocked<T>(callee stringValue: String = #function, arguments: Any?...) throws -> T! {
        return try mock.stubs[stringValue]?(recorded(stringValue, arguments)) as? T
    }
    
}

extension Mocked {
    
    func recorded(_ stringValue: String = #function, _ arguments: [Any?]) -> Call {
        let callee = CalleeKeys(stringValue: stringValue)!
        let call = Call(callee: callee, arguments: .init(arguments))
        mock.calls.append(call)
        return call
    }
    
}

public extension Mocked {
    
    func stub(_ callee: CalleeKeys, doing: @escaping Stub) {
        mock.stubs[callee.stringValue] = doing
    }
    
    func stub(_ callee: CalleeKeys, returning value: Any?) {
        stub(callee) { _ in value }
    }
    
    func stub(_ callee: CalleeKeys, throwing value: Error) {
        stub(callee) { _ in throw value }
    }
    
}

public extension Mocked {
    
    func verify(_ callee: CalleeKeys) -> Bool {
        return mock.calls.first { callee == $0.callee } != nil
    }
    
    func verify(_ callee: CalleeKeys, times: Int) -> Bool {
        return times == mock.calls.filter({ callee == $0.callee }).count
    }
    
    func verify(_ callee: CalleeKeys, passing: (Invocations?) -> Void) {
        passing(mock.calls.lazy.filter({ callee == $0.callee }).map({ $0.arguments }))
    }
    
    func verify(missing callee: CalleeKeys) -> Bool {
        return mock.calls.filter({ callee == $0.callee }).count == 0
    }
    
    func verify(numberOfCalls: Int) -> Bool {
        return numberOfCalls == mock.calls.count
    }
    
    func verify(_ passing: ([Call]?) -> Void) {
        passing(mock.calls)
    }
    
    typealias Invocations = [Arguments]
    
}
