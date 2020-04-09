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
        return invocations(to: callee).count == 0
    }
    
    @discardableResult
    func calls(to callee: CalleeKeys) -> Inspectable<[Arguments]> {
        return Inspectable(invocations(to: callee))
    }
    
}

public extension Mocked {
    
    var callees: Inspectable<[CalleeKeys]> {
        Inspectable(mock.calls.compactMap({ $0.callee }))
    }
    
}

fileprivate extension Mocked {
    
    func invocations(to callee: CalleeKeys) -> [Arguments] {
        return mock.calls.filter {
            callee == $0.0
        }.compactMap {
            $0.1
        }
    }
    
}

// MARK:- Verifiable Collection Methods

public extension Inspectable where T: Collection {
    
    var count: Int {
        value.count
    }
    
}

public extension Inspectable where T: Collection {
    
    func first(_ head: UInt = 1) -> [T.Element] {
        let head = min(Int(head), value.count)
        let index = value.index(value.startIndex, offsetBy: value.count - head)
        return Array(value[index...]).reversed()
    }
    
    func inspect(_ position: UInt = 0) -> T.Element? {
        guard position < value.count else {
            return nil
        }
        
        let index = value.index(value.startIndex, offsetBy: Int(position))
        return value[index]
    }
    
    func last(_ tail: UInt = 1) -> [T.Element] {
        let tail = min(Int(tail), value.count)
        let index = value.index(value.startIndex, offsetBy: tail)
        return Array(value[..<index])
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
