import XCTest

public enum Assertions {
    
    static func make(expression: @autoclosure () -> Bool,
                     message: String,
                     file: StaticString = #file,
                     line: UInt = #line) {
        handler(expression(), message, file, line)
    }
    
    public static var handler: Handler = {
        XCTAssert($0, $1, file: $2, line: $3)
    }
    
    public typealias Handler = (Bool, String, StaticString, UInt) -> Void
    
}
