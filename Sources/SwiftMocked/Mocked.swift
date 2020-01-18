public protocol Mocked {
    
    associatedtype CalleeKeys: CalleeKey
    
    var mock: Mock<CalleeKeys> { get }
    
    func defaultStub() -> Stub?
    func mocked(callee stringValue: String, arguments: Any?...) throws -> Any!
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
    
    @discardableResult
    func mocked(callee stringValue: String = #function, arguments: Any?...) throws -> Any! {
        let call = recorded(stringValue, arguments)
        return try mock.stubs[stringValue]?(call) ?? defaultStub()?(call)
    }
    
    func mocked<T>(callee stringValue: String = #function, arguments: Any?...) throws -> T! {
        let call = recorded(stringValue, arguments)
        return (try mock.stubs[stringValue]?(call) ?? defaultStub()?(call)) as? T
    }
    
}

extension Mocked {
    
    func recorded(_ stringValue: String = #function, _ arguments: [Any?]) -> Call {
        let callee = CalleeKeys(stringValue: stringValue)!
        let call = Call(callee: callee, arguments: .init(arguments))
        mock.calls.insert(call, at: 0)
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
    
    func removeStubs() {
        mock.stubs.removeAll()
    }
    
}
