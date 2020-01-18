public struct Verifiable<T> {
    
    let file: StaticString
    let line: UInt
    let value: T
    
    init(_ value: T, file: StaticString, line: UInt) {
        self.value = value
        self.file = file
        self.line = line
    }
    
}

public extension Verifiable where T == Arguments? {
    
    func argument<U>(_ position: Int, file: StaticString = #file, line: UInt = #line) -> Verifiable<U?> {
        let argument: U? = value?.argument(position)
        return .init(argument, file: file, line: line)
    }
    
}

public extension Verifiable where T: Collection {
    
    func first(_ head: UInt = 1, file: StaticString = #file, line: UInt = #line) -> Verifiable<[T.Element]> {
        Assertion.default(
            head < value.count,
            "expected at least \(head) \(T.self)(s) (total is \(value.count))",
            file,
            line
        )
        
        guard head < value.count, head < Int.max else {
            return Verifiable<[T.Element]>([], file: file, line: line)
        }
        
        let index = value.index(value.startIndex, offsetBy: value.count - Int(head))
        return Verifiable<[T.Element]>(Array(value[index...]).reversed(), file: file, line: line)
    }
    
    func inspect(ago: UInt = 0, file: StaticString = #file, line: UInt = #line) -> Verifiable<T.Element?> {
        Assertion.default(
            ago < value.count,
            "expected a \(T.Element.self) \(ago) ago (total is \(value.count))",
            file,
            line
        )
        
        guard ago < value.count, ago < Int.max else {
            return Verifiable<T.Element?>(nil, file: file, line: line)
        }
        
        let index = value.index(value.startIndex, offsetBy: Int(ago))
        return Verifiable<T.Element?>(value[index], file: file, line: line)
    }
    
    func last(_ tail: UInt = 1, file: StaticString = #file, line: UInt = #line) -> Verifiable<[T.Element]> {
        Assertion.default(
            tail < value.count,
            "expected at least \(tail) \(T.Element.self)(s) (total is \(value.count))",
            file,
            line
        )
        
        guard tail < value.count, tail < Int.max else {
            return Verifiable<[T.Element]>([], file: file, line: line)
        }
        
        let index = value.index(value.startIndex, offsetBy: Int(tail))
        return Verifiable<[T.Element]>(Array(value[..<index]), file: file, line: line)
    }
    
    func total(file: StaticString = #file, line: UInt = #line) -> Verifiable<Int> {
        return Verifiable<Int>(value.count, file: file, line: line)
    }
    
}

public func ==<T: Equatable>(lhs: Verifiable<T>, rhs: T) {
    Assertion.default(
        lhs.value == rhs,
        "expected \(String(describing: lhs.value)) to equal \(String(describing: rhs))",
        lhs.file,
        lhs.line
    )
}

public func <=<T: Comparable>(lhs: Verifiable<T>, rhs: T) {
    Assertion.default(
        lhs.value <= rhs,
        "expected \(String(describing: lhs.value)) to equal \(String(describing: rhs))",
        lhs.file,
        lhs.line
    )
}

public func >=<T: Comparable>(lhs: Verifiable<T>, rhs: T) {
    Assertion.default(
        lhs.value >= rhs,
        "expected \(String(describing: lhs.value)) to equal \(String(describing: rhs))",
        lhs.file,
        lhs.line
    )
}

public func <<T: Comparable>(lhs: Verifiable<T>, rhs: T) {
    Assertion.default(
        lhs.value < rhs,
        "expected \(String(describing: lhs.value)) to equal \(String(describing: rhs))",
        lhs.file,
        lhs.line
    )
}

public func ><T: Comparable>(lhs: Verifiable<T>, rhs: T) {
    Assertion.default(
        lhs.value > rhs,
        "expected \(String(describing: lhs.value)) to equal \(String(describing: rhs))",
        lhs.file,
        lhs.line
    )
}

public func ==<T: Equatable>(lhs: Verifiable<Any?>, rhs: T) {
    Assertion.default(
        (lhs.value as? T) == rhs,
        "expected \(String(describing: lhs.value)) to equal \(String(describing: rhs))",
        lhs.file,
        lhs.line
    )
}

public func ==<C: CalleeKey>(lhs: Verifiable<Array<C>>, rhs: [C]) {
    Assertion.default(
        lhs.value == rhs,
        "expected \(String(describing: lhs.value)) to equal \(String(describing: rhs))",
        lhs.file,
        lhs.line
    )
}

public func ==<C: CalleeKey>(lhs: Verifiable<C>, rhs: C) {
    Assertion.default(
        lhs.value == rhs,
        "expected \(String(describing: lhs.value)) to equal \(String(describing: rhs))",
        lhs.file,
        lhs.line
    )
}

public extension Mocked {
    
    func calls(file: StaticString = #file, line: UInt = #line) -> Verifiable<[Call]> {
        return Verifiable(mock.calls, file: file, line: line)
    }
    
    func callees(file: StaticString = #file, line: UInt = #line) -> Verifiable<[CalleeKeys]> {
        return Verifiable(mock.calls.compactMap({ $0.callee }), file: file, line: line)
    }
    
    func calls(missing callee: CalleeKeys, file: StaticString = #file, line: UInt = #line) {
        let collection = arguments(in: mock.calls, to: callee)
        
        Assertion.default(
            collection.count == 0,
            "expected \(callee.stringValue) to have not been invoked",
            file,
            line
        )
    }
    
    @discardableResult
    func calls(to callee: CalleeKeys, file: StaticString = #file, line: UInt = #line) -> Verifiable<[Arguments]> {
        let collection = arguments(in: mock.calls, to: callee)
        
        Assertion.default(
            collection.count > 0,
            "expected \(callee.stringValue) to have been invoked",
            file,
            line
        )
        
        return Verifiable(collection, file: file, line: line)
    }
    
}

fileprivate func arguments<C: CalleeKey>(in calls: [(C, Arguments)], to callee: C) -> [Arguments] {
    return calls.filter {
        callee == $0.0
    }.compactMap {
        $0.1
    }
}
