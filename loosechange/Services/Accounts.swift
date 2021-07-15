import Foundation
import Combine

struct AccountsService {
    var lunchMoneyApi: LunchMoneyApi
    
    init(token: String) {
        lunchMoneyApi = LunchMoneyApi(config: ApiConfig(accessToken: token))
    }
    
    func fetchAccounts() -> AnyPublisher<[Account], ApiError> {
        let assetsPublisher = lunchMoneyApi
            .getAccounts()
            .map(\.assets)
            .map { assets in
                assets.map {
                    // When using special symbols in names those come wrapped in HTML
                    // entities, so unescape the string to show it normally.
                    Account(
                        id: $0.id,
                        displayName: $0.displayName.htmlUnescape(),
                        formattedBalance: formatCurrency(balance: $0.balance, currency: $0.currency),
                        formattedType: $0.typeName.capitalized,
                        formattedSubtype: $0.subtypeName.capitalized
                    )
                }
            }
        
        let plaidPublisher = lunchMoneyApi
            .getPlaidAccounts()
            .map(\.plaidAccounts)
            .map { plaidAccounts in
                plaidAccounts.map {
                    Account(
                        id: $0.id,
                        displayName: $0.name,
                        formattedBalance: formatCurrency(balance: $0.balance, currency: $0.currency),
                        formattedType: $0.type.capitalized,
                        formattedSubtype: $0.subtype.capitalized
                    )
                }
            }
        
        return assetsPublisher
            .zip(plaidPublisher)
            .map { $0 + $1 }
            .eraseToAnyPublisher()
    }
}
