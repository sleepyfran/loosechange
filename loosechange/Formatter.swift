import Foundation

/// Formats a balance and a currency into a formatted currency value.
func formatCurrency(balance: String, currency: String) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currencyAccounting
    formatter.currencyCode = currency
    let formattedCurrency = formatter.string(from: NSDecimalNumber(string: balance))!
    
    // If the balance is negative, replace () with -. Although the formatter
    // suppors a format for this case it does not take into account the currency
    // symbol or the position from the locale, so it's easier to just replace it
    // after formatting.
    return formattedCurrency
        .replacingOccurrences(of: "(", with: "-")
        .replacingOccurrences(of: ")", with: "")
}

/// Formats a date into the given format.
func formatDate(date: Date, format: String) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = format
    return formatter.string(from: date)
}
