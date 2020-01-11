public protocol NicelyMocked: Mocked {
    
    func returnValue(for callee: CalleeKeys) -> Any!
    
}

public extension NicelyMocked {
    
    func mocked<T>(callee stringValue: String = #function, args: Any?...) -> T! {
        let callee = CalleeKeys(stringValue: stringValue)!
        let call = Mock.Call(callee: callee, args: args)
        mock.calls.append(call)
        return (mock.stubs[stringValue]?.do(call)
            ?? returnValue(for: callee)) as? T
    }
    
}
