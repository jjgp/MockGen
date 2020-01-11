public class Mock<C: CalleeKey> {
    
    var calls = [Call]()
    var stubs = [String: Doing]()
    
    public init() {}
    
    public typealias Call = (callee: C, arguments: [Any?])
    public typealias Doing = (Call) throws -> Any?
    
}
