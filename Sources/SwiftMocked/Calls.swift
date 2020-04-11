public protocol CalleeKey: Hashable, RawRepresentable where RawValue == String {}

extension CalleeKey {
    
    var stringValue: String {
        rawValue
    }
    
    init?(stringValue: String) {
        self.init(rawValue: stringValue)
    }
    
}

public struct Call<C: CalleeKey> {
    
    public let arguments: [Any?]
    public let key: C
    
    init(_ key: C, _ arguments: [Any?]) {
        self.arguments = arguments
        self.key = key
    }
    
}

public extension Call {
    
    subscript(argument position: Int) -> Any? {
        guard position < arguments.count else {
            return nil
        }
        
        return arguments[position]
    }
    
    subscript<T>(argument position: Int) -> T? {
        return self[argument: position] as? T
    }

    
}

public struct Calls<C: CalleeKey> {
    
    private var calls = CallsType()
    
    public typealias CallsType = [Call<C>]
    
}

extension Calls: Collection {
    
    public var endIndex: Index { return calls.endIndex }
    public var startIndex: Index { return calls.startIndex }

    public subscript(index: Index) -> Iterator.Element {
        get { return calls[index] }
    }

    public func index(after i: Index) -> Index {
        return calls.index(after: i)
    }
    
    public typealias Element = CallsType.Element
    public typealias Index = CallsType.Index
    
}

extension Calls {
    
    mutating func append(_ call: Call<C>) {
        calls.append(call)
    }
    
    public var last: Call<C>? {
        calls.last
    }
    
}

public extension Calls {
    
    var keys: [C] {
        calls.compactMap { $0.key }
    }
    
    var arguments: [[Any?]] {
        calls.compactMap { $0.arguments }
    }
    
}

public extension Calls {
    
    subscript(to key: C) -> Calls<C> {
        get {
            return Calls(calls: calls.filter {
                key == $0.key
            })
        }
    }
    
    subscript(tail index: Int) -> Calls<C> {
        let index = calls.index(calls.startIndex, offsetBy: calls.count - Swift.min(index, calls.count))
        return Calls(calls: Array(calls[index...]))
    }
    
    subscript(head index: Int) -> Calls<C> {
        let index = calls.index(calls.startIndex, offsetBy: Swift.min(index, calls.count))
        return Calls(calls: Array(calls[..<index]))
    }
    
    subscript(afterFirst index: Int) -> Call<C>? {
        guard index < calls.count else {
            return nil
        }
        return calls[index]
    }
    
    subscript(beforeLast index: Int) -> Call<C>? {
        let index = calls.count - index - 1
        guard calls.count > 0, index >= 0 else {
            return nil
        }
        return calls[index]
    }
    
}

