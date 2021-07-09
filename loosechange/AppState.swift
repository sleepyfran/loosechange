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
    @Published var requiresLogin: Bool = true
    @Published private(set) var accounts: [Account]
    
    init(accounts: [Account]) {
        self.lunchMoneyApi = LunchMoneyApi(config: ApiConfig())
        self.accounts = accounts
    }
    
    init() {
        let accessToken = UserDefaults.standard.string(forKey: ACCESS_TOKEN_KEY)
        self.lunchMoneyApi = LunchMoneyApi(config: ApiConfig(
            accessToken: accessToken ?? ""
        ))
        requiresLogin = accessToken == nil || accessToken!.isEmpty
        accounts = []
    }
    
    @MainActor func updateAccessToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: ACCESS_TOKEN_KEY)
        lunchMoneyApi = LunchMoneyApi(config: ApiConfig(accessToken: token))
        requiresLogin = false
    }
        
    @MainActor func fetchAccounts() async throws {
        let data = try await lunchMoneyApi.getAccounts()
        let decodedData = try decoder().decode(Api.Assets.self, from: data)
        let decodedAccounts = decodedData.assets.map {
            // When using special symbols in names those come wrapped in HTML
            // entities, so unescape the string to show it normally.
            Account(
                displayName: $0.displayName.htmlUnescape(),
                formattedBalance: format(balance: $0.balance, currency: $0.currency),
                formattedType: $0.typeName.capitalized
            )
        }
        
        accounts = decodedAccounts
    }
}
