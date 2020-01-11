public class Mock {
    
    public struct Call {
        
        public let callee: String
        public let args: [Any?]
        
        init(callee: String, args: [Any?]) {
            self.callee = callee
            self.args = args
        }
        
    }
    
    public struct Stub {
        
        let onCall: Handler
        
        public typealias Handler = (Mock.Call) -> Any?
        
    }
    
    var calls = [Call]()
    var stubs = [String: Stub]()
    
    public init() {}
    
}
