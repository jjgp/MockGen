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
        
        public typealias Handler = (Mock.Call) -> Any?
        let onCall: Handler
        
    }
    
    var calls = [Call]()
    var stubs = [String: Stub]()
    
    public init() {}
    
}
