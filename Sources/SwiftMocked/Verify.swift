public class Verify<M: Mocked> {
    
    let assertion: Assertion.Callback
    let mocked: M
    
    public init(_ mocked: M, assertion: @escaping Assertion.Callback = Assertion.default) {
        self.assertion = assertion
        self.mocked = mocked
    }
    
}

public extension Verify {
    
    func calls() -> Calls<M.CalleeKeys> {
        return Calls(mocked.mock.calls, assertion: assertion)
    }
    
    func calls(missing callee: M.CalleeKeys, file: StaticString = #file, line: UInt = #line) {
        let collection = arguments(in: mocked.mock.calls, to: callee)
        assertion(
            collection.count == 0,
            "expected \(callee.stringValue) to have not been invoked",
            file,
            line
        )
    }
    
    @discardableResult
    func calls(to callee: M.CalleeKeys, file: StaticString = #file, line: UInt = #line) -> Invocations {
        let collection = arguments(in: mocked.mock.calls, to: callee)
        assertion(
            collection.count > 0,
            "expected \(callee.stringValue) to have been invoked",
            file,
            line
        )
        return Invocations(collection, assertion: assertion)
    }
    
}

fileprivate func arguments<C: CalleeKey>(in calls: [(C, Arguments)], to callee: C) -> [Arguments] {
    return calls.filter {
        callee == $0.0
    }.compactMap {
        $0.1
    }
}

