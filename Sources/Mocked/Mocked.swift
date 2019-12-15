public protocol Mocked {
    
    var mock: Mock { get }
    
    func mocked(callee: String, args: Any?...)
    func mocked<T>(callee: String, args: Any?...) -> T!
    func stub(callee: String, returning returnedValue: Any?)
    func stub(callee: String, handler: @escaping Mock.Stub.Handler)
    
}

public extension Mocked {
    
    func mocked(callee: String = #function, args: Any?...) {
        mock.calls.append(.init(callee: callee, args: args))
    }
    
    func mocked<T>(callee: String = #function, args: Any?...) -> T! {
        let call = Mock.Call(callee: callee, args: args)
        mock.calls.append(call)
        return mock.stubs[callee]?.onCall(call) as? T
    }
    
    
}

public extension Mocked {
    
    func stub(callee: String, returning returnedValue: Any?) {
        stub(callee: callee) { _ in
            returnedValue
        }
    }
    
    func stub(callee: String, handler: @escaping Mock.Stub.Handler) {
        mock.stubs[callee] = Mock.Stub(onCall: handler)
    }
    
}
