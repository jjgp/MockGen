public protocol VerifiableCollection {
    
    associatedtype Collectable
    
    var assertion: Assertion.Callback { get }
    var collection: [Collectable] { get }
    
    init(_ collection: [Collectable], assertion: @escaping Assertion.Callback)
    
}

public extension VerifiableCollection {
    
    func inspect(ago: UInt = 0, file: StaticString = #file, line: UInt = #line) -> Verifiable<Collectable?> {
        assertion(
            ago < collection.count,
            "expected a \(Collectable.self) \(ago) ago (total is \(collection.count))",
            file,
            line
        )
        guard ago < collection.count, ago < Int.max else {
            return Verifiable(file: file, line: line, value: nil)
        }
        return Verifiable(file: file, line: line, value: collection[Int(ago)])
    }
    
}

public extension VerifiableCollection {
    
    func total(_ comparator: (Int, Int) -> Bool, _ total: Int, file: StaticString = #file, line: UInt = #line) {
        assertion(
            comparator(collection.count, total),
            "expected comparison with total to pass (total is \(collection.count))",
            file,
            line
        )
    }
    
}

public extension VerifiableCollection {
    
    func first(_ head: UInt = 1, file: StaticString = #file, line: UInt = #line) -> Verifiable<[Collectable]> {
        assertion(
            head < collection.count,
            "expected at least \(head) \(Collectable.self)(s) (total is \(collection.count))",
            file,
            line
        )
        guard head < collection.count, head < Int.max else {
            return Verifiable(file: file, line: line, value: [])
        }
        return Verifiable(file: file, line: line, value: Array(collection[(collection.count - Int(head))...]).reversed())
    }
    
    func last(_ tail: UInt = 1, file: StaticString = #file, line: UInt = #line) -> Verifiable<[Collectable]> {
        assertion(
            tail < collection.count,
            "expected at least \(tail) \(Collectable.self)(s) (total is \(collection.count))",
            file,
            line
        )
        guard tail < collection.count, tail < Int.max else {
            return Verifiable(file: file, line: line, value: [])
        }
        return Verifiable(file: file, line: line, value: Array(collection[..<Int(tail)]))
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
