public protocol NicelyMocked: Mocked {
    
    func returnValue(for call: MockCall) -> Any!
    
}

public extension NicelyMocked {
    
    func mocked<T>(callee stringValue: String = #function, arguments: Any?...) throws -> T! {
        let call = recorded(stringValue, arguments)
        return (try mock.stubs[stringValue]?(call) ?? returnValue(for: call)) as? T
    }
    
}
