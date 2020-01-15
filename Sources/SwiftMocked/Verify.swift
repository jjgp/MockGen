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

public protocol VerifiableCollection {
    
    associatedtype Collectable
    
    var assertion: Assertion.Callback { get }
    var collection: [Collectable] { get }
    
    init(_ collection: [Collectable], assertion: @escaping Assertion.Callback)
    
}

public extension VerifiableCollection {
    
    func inspect(ago: UInt = 0, file: StaticString = #file, line: UInt = #line) -> Collectable? {
        assertion(
            ago < collection.count,
            "expected a \(Collectable.self) \(ago) ago (total is \(collection.count))",
            file,
            line
        )
        guard ago < collection.count, ago < Int.max else {
            return nil
        }
        return collection[Int(ago)]
    }
    
}

public extension VerifiableCollection {
    
    func total(_ total: UInt, file: StaticString = #file, line: UInt = #line) {
        assertion(
            collection.count == total,
            "expected total to equal \(total) instead of (total is \(collection.count))",
            file,
            line
        )
    }
    
    func total(lessThan total: UInt, file: StaticString = #file, line: UInt = #line) {
        assertion(
            collection.count < total,
            "expected total to be less than \(total) (total is \(collection.count))",
            file,
            line
        )
    }
    
    func total(greaterThan total: UInt, file: StaticString = #file, line: UInt = #line) {
        assertion(
            collection.count > total,
            "expected total to be greater than \(total) (total is \(collection.count))",
            file,
            line
        )
    }
    
}

public extension VerifiableCollection {
    
    func first(_ head: UInt = 1, file: StaticString = #file, line: UInt = #line) -> [Collectable] {
        assertion(
            head < collection.count,
            "expected at least \(head) \(Collectable.self)(s) (total is \(collection.count))",
            file,
            line
        )
        guard head < collection.count, head < Int.max else {
            return []
        }
        return Array(collection[(collection.count - Int(head))...]).reversed()
    }
    
    func last(_ tail: UInt = 1, file: StaticString = #file, line: UInt = #line) -> [Collectable] {
        assertion(
            tail < collection.count,
            "expected at least \(tail) \(Collectable.self)(s) (total is \(collection.count))",
            file,
            line
        )
        guard tail < collection.count, tail < Int.max else {
            return []
        }
        return Array(collection[..<Int(tail)])
    }
    
}

public struct Calls<C: CalleeKey>: VerifiableCollection {
    
    public let assertion: Assertion.Callback
    public let collection: [Call]
    
    public init(_ collection: [Call], assertion: @escaping Assertion.Callback) {
        self.assertion = assertion
        self.collection = collection
    }
    
    public typealias Call = (callee: C, arguments: Arguments)
    
}

public extension Calls {
    
    func callees() -> Callees<C> {
        return Callees(collection.compactMap({ $0.callee }), assertion: assertion)
    }
    
    func to(_ callee: C, file: StaticString = #file, line: UInt = #line) -> Invocations {
        let collection = arguments(in: self.collection, to: callee)
        assertion(
            collection.count > 0,
            "expected \(callee.stringValue) to have been invoked",
            file,
            line
        )
        return Invocations(collection, assertion: assertion)
    }
    
}

public struct Callees<C: CalleeKey>: VerifiableCollection {
    
    public let assertion: Assertion.Callback
    public let collection: [C]
    
    public init(_ collection: [C], assertion: @escaping Assertion.Callback) {
        self.assertion = assertion
        self.collection = collection
    }
    
}

public struct Invocations: VerifiableCollection {
    
    public let assertion: Assertion.Callback
    public let collection: [Arguments]
    
    public init(_ collection: [Arguments], assertion: @escaping Assertion.Callback) {
        self.assertion = assertion
        self.collection = collection
    }
    
}

fileprivate func arguments<C: CalleeKey>(in calls: [(C, Arguments)], to callee: C) -> [Arguments] {
    return calls.filter {
        callee == $0.0
    }.compactMap {
        $0.1
    }
}
