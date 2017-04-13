
struct IntervalHour {
    let start: Int
    let end: Int
}

extension IntervalHour: Hashable {
    /// Returns a Boolean value indicating whether two values are equal.
    static func ==(lhs: IntervalHour, rhs: IntervalHour) -> Bool {
        return lhs.start == rhs.start && lhs.start == rhs.end
    }
    
    /// The hash value.
    var hashValue: Int {
        return start.hashValue ^ end.hashValue
    }
}
