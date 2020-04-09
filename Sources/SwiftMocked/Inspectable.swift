public struct Inspectable<T> {
    
    let value: T
    
    init(_ value: T) {
        self.value = value
    }
    
}

// MARK:- Mocked Extension

public extension Mocked {
    
    var calls: Inspectable<[Call]> {
        return Inspectable(mock.calls)
    }
    
    func calls(missing callee: CalleeKeys) -> Bool {
        return arguments(to: callee).count == 0
    }
    
    @discardableResult
    func calls(to callee: CalleeKeys) -> Inspectable<[Arguments]> {
        return Inspectable(arguments(to: callee))
    }
    
}

public extension Mocked {
    
    var callees: Inspectable<[CalleeKeys]> {
        Inspectable(mock.calls.compactMap({ $0.callee }))
    }
    
}

fileprivate extension Mocked {
    
    func arguments(to callee: CalleeKeys) -> [Arguments] {
        return mock.calls.filter {
            callee == $0.0
        }.compactMap {
            $0.1
        }
    }
    
}

// MARK:-

public typealias InspectableCalls<C: CalleeKey> = Inspectable<[(callee: C, arguments: Arguments)]>

public enum Inspect {
    
    static func arguments<C: CalleeKey>(in calls: InspectableCalls<C>,
                                        at position: UInt = 0) -> Inspectable<Arguments?> {
        return calls.inspect(position).flatMap({ $0?.arguments })
    }
    
    static func callees<C: CalleeKey>(in calls: InspectableCalls<C>) -> Inspectable<[C]> {
        return calls.compactMap({ $0.callee })
    }
    
    static func invocations<C: CalleeKey>(to callee: C,
                                          in calls: InspectableCalls<C>) -> Inspectable<[Arguments]> {
        return Inspectable<[Arguments]>(
            calls.value.filter({ $0.callee == callee }).compactMap({ $0.arguments })
        )
    }
    
}

// MARK:-

public extension Inspectable {
    
    func map<U>(_ transform: (T) throws -> U) rethrows -> Inspectable<U?> {
        return Inspectable<U?>(try transform(value))
    }
    
    func flatMap<U>(_ transform: (T) throws -> U?) rethrows -> Inspectable<U?> {
        return Inspectable<U?>(try transform(value))
    }
    
}

// MARK:-

public extension Inspectable where T == Arguments? {
    
    func argument<U>(_ position: Int = 0) -> Inspectable<U?> {
        let argument: U? = value?.argument(position)
        return .init(argument)
    }
    
}

// MARK:- Verifiable Collection Methods

public extension Inspectable where T: Collection {
    
    func compactMap<ElementOfResult>(_ transform: (T.Element) throws -> ElementOfResult?) rethrows -> Inspectable<[ElementOfResult]> {
        return Inspectable<[ElementOfResult]>(try value.compactMap(transform))
    }
    
    // TODO: add other Collection methods
}

public extension Inspectable where T: Collection {
    
    func first(_ head: UInt = 1) -> Inspectable<[T.Element]> {
        let head = min(Int(head), value.count)
        let index = value.index(value.startIndex, offsetBy: value.count - head)
        return Inspectable<[T.Element]>(Array(value[index...]).reversed())
    }
    
    func inspect(_ position: UInt = 0) -> Inspectable<T.Element?> {
        guard position < value.count else {
            return Inspectable<T.Element?>(nil)
        }
        
        let index = value.index(value.startIndex, offsetBy: Int(position))
        return Inspectable<T.Element?>(value[index])
    }
    
    func last(_ tail: UInt = 1) -> Inspectable<[T.Element]> {
        let tail = min(Int(tail), value.count)
        let index = value.index(value.startIndex, offsetBy: tail)
        return Inspectable<[T.Element]>(Array(value[..<index]))
    }
    
    var total: Int {
        value.count
    }
    
}

// MARK:- Operators

public func ==<T: Equatable>(lhs: Inspectable<T>, rhs: T) -> Bool {
    return lhs.value == rhs
}

public func <=<T: Comparable>(lhs: Inspectable<T>, rhs: T) -> Bool {
    return lhs.value <= rhs
}

public func >=<T: Comparable>(lhs: Inspectable<T>, rhs: T) -> Bool {
    return lhs.value >= rhs
}

public func <<T: Comparable>(lhs: Inspectable<T>, rhs: T) -> Bool {
    return lhs.value < rhs
}

public func ><T: Comparable>(lhs: Inspectable<T>, rhs: T) -> Bool {
    return lhs.value > rhs
}

public func ==<T: Equatable>(lhs: Inspectable<Any?>, rhs: T) -> Bool {
    return (lhs.value as? T) == rhs
}

public func ==<C: CalleeKey>(lhs: Inspectable<Array<C>>, rhs: [C]) -> Bool {
    return lhs.value == rhs
}

public func ==<C: CalleeKey>(lhs: Inspectable<C>, rhs: C) -> Bool {
    return lhs.value == rhs
}
