public protocol ClassMocked: class, Mocked {
    
    associatedtype OverriddenCalleeKeys: CalleeKey
    
//    var mock: Mock<CalleeKeys> { get }
    
//    func defaultStub() -> Stub?
//    func mocked(callee stringValue: String, arguments: Any?...) throws -> Any!
//    func mocked<T>(callee stringValue: String, arguments: Any?...) throws -> T!
//    func stub(_ callee: CalleeKeys, doing: @escaping Mock<CalleeKeys>.Stub)
//    func stub(_ callee: CalleeKeys, doing: @escaping VoidStub)
//    func stub(_ callee: CalleeKeys, returning value: Any?)
//    func stub(_ callee: CalleeKeys, throwing value: Error)
    func stub(_ callee: OverriddenCalleeKeys, doing: @escaping SuperStub)
    
}

public extension ClassMocked {
    
    typealias SuperCall = () -> Void
    typealias SuperStub = (Call, SuperCall) throws -> Any?
    
}

public extension ClassMocked {
        
    @discardableResult
    func mocked(callee stringValue: String = #function, super call: SuperCall, arguments: Any?...) throws -> Any! {
        let call = recorded(stringValue, arguments)
        return try mock.stubs[stringValue]?(call) ?? defaultStub()?(call)
    }
    
}
