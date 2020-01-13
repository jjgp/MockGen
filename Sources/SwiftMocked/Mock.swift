public class Mock<C: CalleeKey> {
    
    var calls = [Call]()
    var stubs = [String: Stub]()
    
    public init() {}
    
    public typealias Call = (callee: C, arguments: Arguments)
    public typealias Stub = (Call) throws -> Any?
    
}

public struct Arguments {
    
    let arguments: [Any?]
    
    init(_ arguments: [Any?]) {
        self.arguments = arguments
    }
    
}

public extension Arguments {

    func at<T>(_ position: Int) -> T? {
        guard position < arguments.count else {
            return nil
        }
        
        return arguments[position] as? T
    }
    
    var count: Int {
        arguments.count
    }
    
}