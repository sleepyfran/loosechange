import Foundation

func format(balance: String, currency: String) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currencyAccounting
    formatter.currencyCode = currency
    return formatter.string(from: NSDecimalNumber(string: balance))!
}
