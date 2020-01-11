public class Mock<C: CalleeKey> {
    
    public struct Arguments {
        
        let arguments: [Any?]
        
        init(_ arguments: [Any?]) {
            self.arguments = arguments
        }
        
    }
    
    public var calls = [Call]()
    public var stubs = [String: Stub]()
    
    public init() {}
    
    public typealias Call = (callee: C, arguments: Arguments)
    public typealias Stub = (Call) throws -> Any?
    
}

public extension Mock.Arguments {
    
    subscript<T>(index: Int) -> T? {
        get {
            guard index < arguments.count else {
                return nil
            }
            
            return arguments[index] as? T
        }
    }
    
    var count: Int {
        arguments.count
    }
    
}
