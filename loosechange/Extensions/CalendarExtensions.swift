import Foundation

extension Calendar {
    /// Returns the date of the first day of the current month.
    func firstDayOfMonth() -> Date {
        var components = Calendar.current.dateComponents([.day, .month, .year], from: Date.now)
        components.day = 1
        return Calendar.current.date(from: components)!
    }
}
