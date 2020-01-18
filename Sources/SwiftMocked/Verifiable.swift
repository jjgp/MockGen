public struct Verifiable<T> {
    
    let file: StaticString
    let line: UInt
    let value: T
    
}

public extension Verifiable where T == Arguments? {
    
    func argument<U>(_ position: Int, file: StaticString = #file, line: UInt = #line) -> Verifiable<U?> {
        let argument: U? = value?.argument(position)
        return .init(file: file, line: line, value: argument)
    }
    
}

public func ==<T: Equatable>(lhs: Verifiable<Any?>, rhs: T?) {
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
