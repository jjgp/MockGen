public protocol Mocked {
    
    associatedtype CalleeKeys: CalleeKey
    
    var mock: Mock<CalleeKeys> { get }
    
    func mocked(callee stringValue: String, arguments: Any?...) throws
    func mocked<T>(callee stringValue: String, arguments: Any?...) throws -> T!
    func stub(_ callee: CalleeKeys, doing: @escaping Mock<CalleeKeys>.Doing)
    func stub(_ callee: CalleeKeys, returning value: Any?)
    func stub(_ callee: CalleeKeys, throwing value: Error)
    
}

public extension Mocked {
    
    typealias MockCall = Mock<CalleeKeys>.Call
    typealias MockDoing = Mock<CalleeKeys>.Doing
    
}

public extension Mocked {
    
    func mocked(callee stringValue: String = #function, arguments: Any?...) throws {
        let callee = CalleeKeys(stringValue: stringValue)!
        let call = MockCall(callee: callee, arguments: arguments)
        mock.calls.append(call)
        _ = try mock.stubs[stringValue]?(call)
    }
    
    func mocked<T>(callee stringValue: String = #function, arguments: Any?...) throws -> T! {
        let callee = CalleeKeys(stringValue: stringValue)!
        let call = MockCall(callee: callee, arguments: arguments)
        mock.calls.append(call)
        return try mock.stubs[stringValue]?(call) as? T
    }
    
}

public extension Mocked {

    func stub(_ callee: CalleeKeys, doing: @escaping MockDoing) {
        mock.stubs[callee.stringValue] = doing
    }
    
    func stub(_ callee: CalleeKeys, returning value: Any?) {
        stub(callee) { _ in
            value
        }
    }
    
    func stub(_ callee: CalleeKeys, throwing value: Error) {
        stub(callee) { _ in
            throw value
        }
    }

}
