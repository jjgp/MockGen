public class Mock<C: CalleeKey> {
    
    public struct Call {
        
        public let callee: C
        public let args: [Any?]
        
        init(callee: C, args: [Any?]) {
            self.callee = callee
            self.args = args
        }
        
    }
    
    public struct Stub {
        
        let `do`: Doing
        
        public typealias Doing = (Mock.Call) -> Any?
        
    }
    
    var calls = [Call]()
    var stubs = [String: Stub]()
    
    public init() {}
    
}
