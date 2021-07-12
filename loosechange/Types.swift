import Foundation

enum FetchStatus {
    case notRequested, fetching, errored, fetched
}

enum RemoteContent<Value> {
    case notRequested
    case loading
    case failed(Error)
    case done(Value)
}

/// Defines an account or asset that the user is holding.
struct Account {
    let displayName: String
    let formattedBalance: String
    let formattedType: String
    let formattedSubtype: String
    
    static func placeholder(_ i: Int) -> Account {
        Account(
            displayName: "Placeholder account \(i)",
            formattedBalance: "1.000€",
            formattedType: "cash",
            formattedSubtype: "checking"
        )
    }
}

struct Accounts {
    static func placeholder() -> [Account] {
        (1...10).map { i in
            Account.placeholder(i)
        }
    }
}

enum AvailableStatus {
    case positive, negative
}

/// Defines the budget associated with a certain category.
struct CategoryBudget {
    let name: String
    let formattedAvailable: String
    let availableStatus: AvailableStatus
    
    static func placeholder(_ i: Int) -> CategoryBudget {
        CategoryBudget(
            name: "Placeholder Category Budget \(i)",
            formattedAvailable: "340€",
            availableStatus: .positive
        )
    }
}

/// Groups each budget for a category under the name of the group. Categories without a group go under
/// the special key "".
typealias Budget = [(String, [CategoryBudget])]

extension Budget {
    static func placeholder() -> Budget {
        [
            ("Placeholder 1", (1...10).map { i in CategoryBudget.placeholder(i) }),
            ("Placeholder 2", (1...10).map { i in CategoryBudget.placeholder(i) }),
            ("Placeholder 3", (1...10).map { i in CategoryBudget.placeholder(i) }),
            ("Placeholder 4", (1...10).map { i in CategoryBudget.placeholder(i) })
        ]
    }
}

enum Api {
    struct Asset: Codable {
        let displayName: String
        let balance: String
        let currency: String
        let typeName: String
        let subtypeName: String
    }
    
    struct PlaidAccount: Codable {
        // TODO: Switch to displayName once the API returns it
        let name: String
        let balance: String
        let currency: String
        let type: String
        let subtype: String
    }
    
    struct BudgetData: Codable {
        let budgetToBase: Decimal?
        let spendingToBase: Decimal?
        let budgetCurrency: String?
    }
    
    typealias BudgetDataMonthly = [String: BudgetData]
    
    struct CategoryBudget: Codable {
        let categoryName: String
        let categoryGroupName: String?
        let categoryId: Int?
        let isGroup: Bool?
        let excludeFromBudget: Bool
        let data: BudgetDataMonthly
    }
    
    struct Assets: Codable {
        let assets: [Asset]
    }
    
    struct PlaidAccounts: Codable {
        let plaidAccounts: [PlaidAccount]
    }
    
    typealias CategoryBudgets = [CategoryBudget]
}
