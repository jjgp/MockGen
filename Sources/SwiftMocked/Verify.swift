public class Verify<M: Mocked> {
    
    let mocked: M
    
    public init(_ mocked: M) {
        self.mocked = mocked
    }
    
}

extension Verify {
    
    func calls(to: M.CalleeKeys) {
        
    }
    
}
