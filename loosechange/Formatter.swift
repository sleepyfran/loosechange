import Foundation

/// Formats a balance and a currency into a formatted currency value.
func formatCurrency(balance: String, currency: String) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currencyAccounting
    formatter.currencyCode = currency
    return formatter.string(from: NSDecimalNumber(string: balance))!
}

/// Formats a date into the given format.
func formatDate(date: Date, format: String) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = format
    return formatter.string(from: date)
}
