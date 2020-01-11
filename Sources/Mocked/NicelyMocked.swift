public protocol NicelyMocked: Mocked {
    
    func returnValue(for callee: CalleeKeys) -> Any!
    
}

public extension NicelyMocked {
    
    func mocked<T>(callee stringValue: String = #function, arguments: Any?...) throws -> T! {
        let callee = CalleeKeys(stringValue: stringValue)!
        let call = Mock<CalleeKeys>.Call(callee: callee, arguments: arguments)
        mock.calls.append(call)
        return (try mock.stubs[stringValue]?(call)
            ?? returnValue(for: callee)) as? T
    }
    
}
