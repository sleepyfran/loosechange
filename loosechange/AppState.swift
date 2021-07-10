import Foundation
import HTMLEntities

private func decoder() -> JSONDecoder {
    let dec = JSONDecoder()
    dec.keyDecodingStrategy = .convertFromSnakeCase
    return dec
}

private let ACCESS_TOKEN_KEY = "accessToken"

/// Holds the entire state of the app that will be observed by the UI to display.
class AppState: ObservableObject {
    private var lunchMoneyApi: LunchMoneyApi
    @Published var fetchStatus: FetchStatus = .notRequested
    @Published var requiresLogin: Bool = true
    @Published private(set) var accounts: [Account]
    @Published private(set) var currentBudget: Budget
    
    init(accounts: [Account]) {
        self.lunchMoneyApi = LunchMoneyApi(config: ApiConfig())
        self.accounts = accounts
        currentBudget = []
    }
    
    init() {
        let accessToken = UserDefaults.standard.string(forKey: ACCESS_TOKEN_KEY)
        self.lunchMoneyApi = LunchMoneyApi(config: ApiConfig(
            accessToken: accessToken ?? ""
        ))
        requiresLogin = accessToken == nil || accessToken!.isEmpty
        accounts = []
        currentBudget = []
    }
    
    @MainActor func updateAccessToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: ACCESS_TOKEN_KEY)
        lunchMoneyApi = LunchMoneyApi(config: ApiConfig(accessToken: token))
        requiresLogin = false
    }
        
    @MainActor func fetchAccounts() async throws {
        var data = try await lunchMoneyApi.getAccounts()
        let accountsData = try decoder().decode(Api.Assets.self, from: data)
        let decodedAccounts = accountsData.assets.map {
            // When using special symbols in names those come wrapped in HTML
            // entities, so unescape the string to show it normally.
            Account(
                displayName: $0.displayName.htmlUnescape(),
                formattedBalance: formatCurrency(balance: $0.balance, currency: $0.currency),
                formattedType: $0.typeName.capitalized,
                formattedSubtype: $0.subtypeName.capitalized
            )
        }
        
        data = try await lunchMoneyApi.getPlaidAccounts()
        let plaidData = try decoder().decode(Api.PlaidAccounts.self, from: data)
        let decodedPlaidAccounts = plaidData.plaidAccounts.map {
            Account(
                displayName: $0.name,
                formattedBalance: formatCurrency(balance: $0.balance, currency: $0.currency),
                formattedType: $0.type.capitalized,
                formattedSubtype: $0.subtype.capitalized
            )
        }
        
        accounts = decodedAccounts + decodedPlaidAccounts
    }
    
    @MainActor func fetchCurrentMonthBudget() async throws {
        let startDate = Calendar.current.firstDayOfMonth()
        let endDate = Calendar.current.date(byAdding: .day, value: 1, to: Date.now)!
        
        let data = try await lunchMoneyApi.getBudget(startDate: startDate, endDate: endDate)
        let decodedData = try decoder().decode(Api.CategoryBudgets.self, from: data)
        var budgetByCategory = Dictionary<String, [CategoryBudget]>()
        
        for budget in decodedData {
            // If there's no data there's no point in trying to display it.
            if budget.data.isEmpty {
                continue
            }
            
            let unescapedCategoryName = budget.categoryName.htmlUnescape()
            let unescapedCategoryGroupName = budget.categoryGroupName?.htmlUnescape()
            
            // Category is a group, we only want to get the header to organize it.
            if budget.isGroup != nil && budget.isGroup! {
                if !budgetByCategory.contains(where: { (key, _) in key == unescapedCategoryName }) {
                    budgetByCategory.updateValue([], forKey: unescapedCategoryName)
                }
            // Category has a parent, retrieve its data and add it to the group.
            } else if budget.categoryGroupName != nil && !unescapedCategoryGroupName!.isEmpty {
                var groupBudget = budgetByCategory[unescapedCategoryGroupName!]!
                groupBudget.append(categoryFromApi(budget: budget))
                budgetByCategory.updateValue(groupBudget, forKey: unescapedCategoryGroupName!)
            // Category does not have a parent, retrieve its data and add it to
            // the empty group.
            } else {
                var ungroupedBudget = budgetByCategory[""] ?? []
                ungroupedBudget.append(categoryFromApi(budget: budget))
            }
        }
        
        // Transform into an array of tuples for easy access in the view.
        var budget: Budget = []
        for (category, items) in budgetByCategory {
            budget.append((category, items))
        }
        
        currentBudget = budget
    }
}

private func categoryFromApi(budget: Api.CategoryBudget) -> CategoryBudget {
    let data = budget.data.first!.value
    let available = data.budgetToBase - data.spendingToBase
    
    return CategoryBudget(
        name: budget.categoryName.htmlUnescape(),
        formattedAvailable: formatCurrency(
            balance: "\(available)",
            currency: data.budgetCurrency
        ),
        availableStatus: available >= 0 ? .positive : .negative
    )
}
