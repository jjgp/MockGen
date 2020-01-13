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
        let invocations = self.invocations(for: callee)
        assertion(
            invocations.count == 0,
            "expected \(callee.rawValue) to have not been invoked",
            file,
            line
        )
    }
    
    @discardableResult
    func calls(to callee: M.CalleeKeys, file: StaticString = #file, line: UInt = #line) -> Invocations {
        let invocations = self.invocations(for: callee)
        let stringValue = callee.stringValue
        assertion(
            invocations.count > 0,
            "expected \(stringValue) to have been invoked",
            file,
            line
        )
        return Invocations(invocations, assertion: assertion)
    }
    
}

extension Verify {
    
    func invocations(for callee: M.CalleeKeys) -> [Arguments] {
        return mocked.mock.calls
            .filter { callee == $0.callee }
            .compactMap { $0.arguments }
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

public struct Calls<C: CalleeKey>: VerifiableCollection {
    
    public let assertion: Assertion.Callback
    public let collection: [Call]
    
    public init(_ collection: [Call], assertion: @escaping Assertion.Callback) {
        self.assertion = assertion
        self.collection = collection
    }
    
    public typealias Call = (callee: C, arguments: Arguments)
    
}

public struct Invocations : VerifiableCollection {
    
    public let assertion: Assertion.Callback
    public let collection: [Arguments]
    
    public init(_ collection: [Arguments], assertion: @escaping Assertion.Callback) {
        self.assertion = assertion
        self.collection = collection
    }
    
}
