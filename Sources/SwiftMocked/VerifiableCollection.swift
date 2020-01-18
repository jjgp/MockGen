public protocol VerifiableCollection {
    
    associatedtype Collectable
    
    var collection: [Collectable] { get }
    
    init(_ collection: [Collectable])
    
}


public struct Calls<C: CalleeKey>: VerifiableCollection {
    
    public let collection: [Call]
    
    public init(_ collection: [Call]) {
        self.collection = collection
    }
    
    public typealias Call = (callee: C, arguments: Arguments)
    
}

public extension Calls {
    
    func to(_ callee: C, file: StaticString = #file, line: UInt = #line) -> Invocations {
        let collection = arguments(in: self.collection, to: callee)
        Assertion.default(
            collection.count > 0,
            "expected \(callee.stringValue) to have been invoked",
            file,
            line
        )
        return Invocations(collection)
    }
    
}

public struct Invocations: VerifiableCollection {
    
    public let collection: [Arguments]
    
    public init(_ collection: [Arguments]) {
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
