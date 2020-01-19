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

// MARK:- Mocked Extension

public extension Mocked {
    
    func calls(file: StaticString = #file, line: UInt = #line) -> Verifiable<[Call]> {
        return Verifiable(mock.calls, file: file, line: line)
    }
    
    func calls(missing callee: CalleeKeys, file: StaticString = #file, line: UInt = #line) {
        let invocations = self.arguments(to: callee)
        
        Assertion.default(
            invocations.count == 0,
            "WIP",
            file,
            line
        )
    }
    
    @discardableResult
    func calls(to callee: CalleeKeys, file: StaticString = #file, line: UInt = #line) -> Verifiable<[Arguments]> {
        let invocations = arguments(to: callee)
        
        Assertion.default(
            invocations.count > 0,
            "WIP",
            file,
            line
        )
        
        return Verifiable(invocations, file: file, line: line)
    }
    
}

public extension Mocked {
    
    func callees(file: StaticString = #file, line: UInt = #line) -> Verifiable<[CalleeKeys]> {
        return Verifiable(mock.calls.compactMap({ $0.callee }), file: file, line: line)
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

// MARK:- Operators

public func ==<T: Equatable>(lhs: Verifiable<T>, rhs: T) {
    Assertion.default(
        lhs.value == rhs,
        "WIP",
        lhs.file,
        lhs.line
    )
}

public func <=<T: Comparable>(lhs: Verifiable<T>, rhs: T) {
    Assertion.default(
        lhs.value <= rhs,
        "WIP",
        lhs.file,
        lhs.line
    )
}

public func >=<T: Comparable>(lhs: Verifiable<T>, rhs: T) {
    Assertion.default(
        lhs.value >= rhs,
        "WIP",
        lhs.file,
        lhs.line
    )
}

public func <<T: Comparable>(lhs: Verifiable<T>, rhs: T) {
    Assertion.default(
        lhs.value < rhs,
        "WIP",
        lhs.file,
        lhs.line
    )
}

public func ><T: Comparable>(lhs: Verifiable<T>, rhs: T) {
    Assertion.default(
        lhs.value > rhs,
        "WIP",
        lhs.file,
        lhs.line
    )
}

public func ==<T: Equatable>(lhs: Verifiable<Any?>, rhs: T) {
    Assertion.default(
        (lhs.value as? T) == rhs,
        "WIP",
        lhs.file,
        lhs.line
    )
}

public func ==<C: CalleeKey>(lhs: Verifiable<Array<C>>, rhs: [C]) {
    Assertion.default(
        lhs.value == rhs,
        "WIP",
        lhs.file,
        lhs.line
    )
}

public func ==<C: CalleeKey>(lhs: Verifiable<C>, rhs: C) {
    Assertion.default(
        lhs.value == rhs,
        "WIP",
        lhs.file,
        lhs.line
    )
}

// MARK:-

public typealias VerifiableCalls<C: CalleeKey> = Verifiable<[(callee: C, arguments: Arguments)]>

public enum Verify {
    
    static func arguments<C: CalleeKey>(in calls: VerifiableCalls<C>,
                                        at position: UInt = 0,
                                        file: StaticString = #file,
                                        line: UInt = #line) -> Verifiable<Arguments?> {
        return calls.inspect(position).flatMap({ $0?.arguments })
    }
    
    static func callees<C: CalleeKey>(in calls: VerifiableCalls<C>,
                                      file: StaticString = #file,
                                      line: UInt = #line) -> Verifiable<[C]> {
        return calls.compactMap({ $0.callee })
    }
    
    static func invocations<C: CalleeKey>(in calls: VerifiableCalls<C>,
                                          to callee: C,
                                          file: StaticString = #file,
                                          line: UInt = #line) -> Verifiable<[Arguments]> {
        return Verifiable<[Arguments]>(calls.value.lazy.filter({ $0.callee == callee }).compactMap({ $0.arguments }),
                                       file: file,
                                       line: line)
    }
    
}

// MARK:-

public extension Verifiable {
    
    func map<U>(_ transform: (T) throws -> U, file: StaticString = #file, line: UInt = #line) rethrows -> Verifiable<U?> {
        return Verifiable<U?>(try transform(value),
                              file: file,
                              line: line)
    }
    
    func flatMap<U>(_ transform: (T) throws -> U?, file: StaticString = #file, line: UInt = #line) rethrows -> Verifiable<U?> {
        return Verifiable<U?>(try transform(value),
                              file: file,
                              line: line)
    }
    
}

// MARK:-

public extension Verifiable where T == Arguments? {
    
    func argument<U>(_ position: Int = 0, file: StaticString = #file, line: UInt = #line) -> Verifiable<U?> {
        let argument: U? = value?.argument(position)
        return .init(argument, file: file, line: line)
    }
    
}

// MARK:- Verifiable Collection Methods

public extension Verifiable where T: Collection {
    
    func compactMap<ElementOfResult>(_ transform: (T.Element) throws -> ElementOfResult?, file: StaticString = #file, line: UInt = #line) rethrows -> Verifiable<[ElementOfResult]> {
        return Verifiable<[ElementOfResult]>(try value.compactMap(transform),
                                             file: file,
                                             line: line)
    }
    
    // TODO: add other Collection methods
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
    
    func inspect(_ position: UInt = 0, file: StaticString = #file, line: UInt = #line) -> Verifiable<T.Element?> {
        Assertion.default(
            position < value.count,
            "WIP",
            file,
            line
        )
        
        guard position < value.count, position < Int.max else {
            return Verifiable<T.Element?>(nil, file: file, line: line)
        }
        
        let index = value.index(value.startIndex, offsetBy: Int(position))
        return Verifiable<T.Element?>(value[index], file: file, line: line)
    }
    
    func last(_ tail: UInt = 1, file: StaticString = #file, line: UInt = #line) -> Verifiable<[T.Element]> {
        Assertion.default(
            tail < value.count,
            "WIP",
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
