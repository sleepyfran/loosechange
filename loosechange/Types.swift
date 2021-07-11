import Foundation
enum FetchStatus {
    case notRequested, fetching, errored, fetched
}

/// Defines an account or asset that the user is holding.
struct Account {
    let displayName: String
    let formattedBalance: String
    let formattedType: String
    let formattedSubtype: String
}

enum AvailableStatus {
    case positive, negative
}

/// Defines the budget associated with a certain category.
struct CategoryBudget {
    let name: String
    let formattedAvailable: String
    let availableStatus: AvailableStatus
}

/// Groups each budget for a category under the name of the group. Categories without a group go under
/// the special key "".
typealias Budget = [(String, [CategoryBudget])]

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
