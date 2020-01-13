import XCTest

public enum Assertion {
    
    public static let `default`: Callback = Self.xctAssert
    public static let xctAssert: Callback = {
        XCTAssert($0, $1, file: $2, line: $3)
    }
    
    public typealias Callback = (Bool, String, StaticString, UInt) -> Void
    
}
