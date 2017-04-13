
import Foundation

func formatInterval(_ interval: IntervalHour) -> IntervalHour {
    let start = interval.start < 0 ? 0 : interval.start
    let end = interval.start < 0 ? 0 : interval.end
    return start > end ? IntervalHour(start: end, end: start) : IntervalHour(start: start, end: end)
}

struct AvailabilityViewModel {
    let hoursArray = Array(8...22)
    
    var showButtonCallback: ((Bool) -> ())!
    
    fileprivate var selectedSequence: Set<IntervalHour> = [] {
        didSet {
            showButtonCallback?(selectedSequence.count < 1)
        }
    }
}

extension AvailabilityViewModel {
    
    func hours() -> [Hour] {
        
        return hoursArray.map {Hour(rawValue: String($0))}
    }
    
    mutating func resetSelectedSequence() {
        selectedSequence = []
    }
    
    fileprivate mutating func update(with interval: IntervalHour) {
        let formattedInterval = formatInterval(interval)
        selectedSequence.update(with: formattedInterval)
    }
    
    //TODO: !!! at this point I don't know how to extract better !!!
    mutating func extractInterval(_ indexPaths: [IndexPath]) {
        resetSelectedSequence()
        
        var startIndex: Int = 0
        var nextItem: Int = 0
        
        for (index, obj) in indexPaths.enumerated() {
            if index == 0 {
                startIndex = obj.row
                nextItem = startIndex
            }
            
            if nextItem == obj.row - 1 {
                nextItem = obj.row
            } else if index != 0 {
                update(with: IntervalHour(start: startIndex, end: nextItem))
                startIndex = obj.row
                nextItem = obj.row
            }
        }
        
        update(with: IntervalHour(start: startIndex, end: nextItem))
        
        print(selectedSequence)
    }
}
