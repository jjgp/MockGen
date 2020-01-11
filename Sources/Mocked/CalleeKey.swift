public protocol CalleeKey: Hashable {
    
    var stringValue: String { get }
    
    init?(stringValue: String)

}

extension RawRepresentable where RawValue == String {
    
    var stringValue: String {
        rawValue
    }
    
    init?(stringValue: String) {
        self.init(rawValue: stringValue)
    }
    
}
