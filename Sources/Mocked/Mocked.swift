public protocol Mocked {
    
    associatedtype CalleeKeys: CalleeKey
    
    var mock: Mock<CalleeKeys> { get }
    
    func mocked(callee stringValue: String, args: Any?...)
    func mocked<T>(callee stringValue: String, args: Any?...) -> T!
    func stub(_ callee: CalleeKeys, returning returnedValue: Any?)
    func stub(_ callee: CalleeKeys, doing: @escaping Mock<CalleeKeys>.Stub.Doing)
    
}

public extension Mocked {
    
    func mocked(callee stringValue: String = #function, args: Any?...) {
        let callee = CalleeKeys(stringValue: stringValue)!
        mock.calls.append(.init(callee: callee, args: args))
    }
    
    func mocked<T>(callee stringValue: String = #function, args: Any?...) -> T! {
        let callee = CalleeKeys(stringValue: stringValue)!
        let call = Mock.Call(callee: callee, args: args)
        mock.calls.append(call)
        return mock.stubs[stringValue]?.do(call) as? T
    }
    
}

public extension Mocked {

    func stub(_ callee: CalleeKeys, returning returnedValue: Any?) {
        stub(callee) { _ in
            returnedValue
        }
    }

    func stub(_ callee: CalleeKeys, doing: @escaping Mock<CalleeKeys>.Stub.Doing) {
        mock.stubs[callee.stringValue] = Mock.Stub(do: doing)
    }

}
