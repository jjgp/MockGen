public protocol CalleeKey: Hashable, RawRepresentable where RawValue == String {}

extension CalleeKey {
    
    var stringValue: String {
        rawValue
    }
    
    init?(stringValue: String) {
        self.init(rawValue: stringValue)
    }
    
}
