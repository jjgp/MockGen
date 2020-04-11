public class Mock<C: CalleeKey> {
    
    var calls = Calls<C>()
    var stubs = [String: Stub]()
    
    public init() {}
    
    public typealias Stub = (Call<C>) throws -> Any?
    
}

public protocol Mocked {
    
    associatedtype CalleeKeys: CalleeKey
    
    var mock: Mock<CalleeKeys> { get }
    
    func defaultStub() -> Stub?
    func mocked(key stringValue: String, arguments: Any?...) throws -> Any!
    func mocked<T>(key stringValue: String, arguments: Any?...) throws -> T!
    func stub(_ key: CalleeKeys, doing: @escaping Stub)
    func stub(_ key: CalleeKeys, doing: @escaping VoidStub)
    func stub(_ key: CalleeKeys, returning value: Any?)
    func stub(_ key: CalleeKeys, throwing value: Error)
    
}

public extension Mocked {
    
    typealias Call = SwiftMocked.Call<CalleeKeys>
    typealias Calls = SwiftMocked.Calls<CalleeKeys>
    typealias Stub = Mock<CalleeKeys>.Stub
    typealias VoidStub = (Call) throws -> Void
    
}

public extension Mocked {
    
    @discardableResult
    func mocked(key stringValue: String = #function, arguments: Any?...) throws -> Any! {
        let call = recorded(stringValue, arguments)
        return try mock.stubs[stringValue]?(call) ?? defaultStub()?(call)
    }
    
    func mocked<T>(key stringValue: String = #function, arguments: Any?...) throws -> T! {
        let call = recorded(stringValue, arguments)
        return (try mock.stubs[stringValue]?(call) ?? defaultStub()?(call)) as? T
    }
    
}

extension Mocked {
    
    func recorded(_ stringValue: String = #function, _ arguments: [Any?]) -> Call {
        let key = CalleeKeys(stringValue: stringValue)!
        let call = Call(key, arguments)
        mock.calls.append(call)
        return call
    }
    
}

public extension Mocked {
    
    func stub(_ key: CalleeKeys, doing: @escaping Stub) {
        mock.stubs[key.stringValue] = doing
    }
    
    func stub(_ key: CalleeKeys, doing: @escaping VoidStub) {
        mock.stubs[key.stringValue] = doing
    }
    
    func stub(_ key: CalleeKeys, returning value: Any?) {
        stub(key) { _ in value }
    }
    
    func stub(_ key: CalleeKeys, throwing value: Error) {
        let stub: Stub = { _ in throw value }
        self.stub(key, doing: stub)
    }
    
    func removeStubs() {
        mock.stubs.removeAll()
    }
    
}

public extension Mocked {
    
    var calls: Calls {
        return mock.calls
    }
    
}
