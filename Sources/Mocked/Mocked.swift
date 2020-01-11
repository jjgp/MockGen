public protocol CalleeKey {
    
    var stringValue: String { get }
    
    init?(stringValue: String)

}

extension RawRepresentable where RawValue == String {
    
    init?(stringValue: String) {
        self.init(rawValue: stringValue)
    }
    
    var stringValue: String {
        rawValue
    }
    
}

public protocol Mocked {
    
    associatedtype CalleeKeys: CalleeKey
    
    var mock: Mock { get }
    
    func mocked(callee: String, args: Any?...)
    func mocked<T>(callee: String, args: Any?...) -> T!
    func stub(callee: CalleeKeys, returning returnedValue: Any?)
    func stub(callee: CalleeKeys, handler: @escaping Mock.Stub.Handler)
    
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

    func stub(callee: CalleeKeys, returning returnedValue: Any?) {
        stub(callee: callee) { _ in
            returnedValue
        }
    }

    func stub(callee: CalleeKeys, handler: @escaping Mock.Stub.Handler) {
        mock.stubs[callee.stringValue] = Mock.Stub(onCall: handler)
    }

}
