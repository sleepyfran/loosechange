import Foundation
import Combine

struct BudgetsService {
    var lunchMoneyApi: LunchMoneyApi
    
    init(token: String) {
        lunchMoneyApi = LunchMoneyApi(config: ApiConfig(accessToken: token))
    }
    
    func fetchCurrentMonthBudget() -> AnyPublisher<Budget, ApiError> {
        let startDate = Calendar.current.firstDayOfMonth()
        let endDate = Calendar.current.date(byAdding: .day, value: 1, to: Date.now)!
        
        return lunchMoneyApi
            .getBudget(startDate: startDate, endDate: endDate)
            .flatMap { cbs in
                cbs.publisher
            }
            .filter { cb in
                let value = cb.data.first?.value
                
                // Ignore empty data and those that have any of the budget
                // fields set to nil as we cannot parse them.
                return
                    !cb.data.isEmpty &&
                    value?.budgetCurrency != nil &&
                    value?.spendingToBase != nil &&
                    value?.budgetToBase != nil
            }
            .reduce(Dictionary<String, [CategoryBudget]>()) { acc, cb in
                let unescapedCategoryName = cb.categoryName.htmlUnescape()
                let unescapedCategoryGroupName = cb.categoryGroupName?.htmlUnescape()
                var dict = acc
                
                // Category is a group, we only initialize a new key in the dict.
                if cb.isGroup ?? false {
                    dict.updateValue([], forKey: unescapedCategoryName)
                // Category has a parent, append to the group.
                } else if !(unescapedCategoryGroupName?.isEmpty ?? true) {
                    var groupBudget = dict[unescapedCategoryGroupName!]!
                    groupBudget.append(categoryFromApi(budget: cb))
                    dict.updateValue(groupBudget, forKey: unescapedCategoryGroupName!)
                // Category doesn't have a parent, add it to the empty group.
                } else {
                    var ungroupedBudget = dict[""] ?? []
                    ungroupedBudget.append(categoryFromApi(budget: cb))
                    dict.updateValue(ungroupedBudget, forKey: "")
                }
                
                return dict
            }
            .map { budgetByKey in
                budgetByKey
                    .reduce([], { acc, cb in acc + [(cb.key, cb.value)] })
                    .map { ($0.0, $0.1.sorted(by: { cb1, cb2 in cb1.name > cb2.name })) }
                    .sorted(by: { group1, group2 in group1.0 > group2.0 })
            }
            .eraseToAnyPublisher()
    }
    
    private func categoryFromApi(budget: Api.CategoryBudget) -> CategoryBudget {
        let data = budget.data.first!.value
        let available = data.budgetToBase! - data.spendingToBase!
        
        return CategoryBudget(
            name: budget.categoryName.htmlUnescape(),
            formattedAvailable: formatCurrency(
                balance: "\(available)",
                currency: data.budgetCurrency!
            ),
            availableStatus: available >= 0 ? .positive : .negative
        )
    }
}
