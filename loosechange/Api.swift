import Foundation
import Combine

struct ApiConfig {
    let accessToken: String
    
    init() {
        accessToken = ""
    }
    
    init(accessToken: String) {
        self.accessToken = accessToken
    }
}

enum ApiError: Error {
    case forbidden, invalidResponse, unknown
}

private func bearer(from config: ApiConfig) -> String {
    "Bearer \(config.accessToken)"
}

func httpGet(url: URL, config: ApiConfig) -> AnyPublisher<Data, ApiError> {
    var urlRequest = URLRequest(url: url)
    urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
    urlRequest.setValue(
        bearer(from: config),
        forHTTPHeaderField: "Authorization"
    )

    debugPrint("GET: \(url.absoluteString))")
    
    return URLSession.shared.dataTaskPublisher(for: urlRequest)
        .map(\.data)
        .mapError { _ in
            ApiError.unknown
        }
        .eraseToAnyPublisher()
}

struct LunchMoneyApi {
    let config: ApiConfig
    let decoder: JSONDecoder
    
    init(config: ApiConfig) {
        self.config = config
        self.decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
    }
    
    func getAccounts() -> AnyPublisher<Api.Assets, ApiError> {
        httpGet(
            url: URL(string: "https://dev.lunchmoney.app/v1/assets")!,
            config: config
        )
        .decode(type: Api.Assets.self, decoder: decoder)
        .mapError { _ in ApiError.unknown }
        .eraseToAnyPublisher()
    }
    
    func getPlaidAccounts() -> AnyPublisher<Api.PlaidAccounts, ApiError> {
        httpGet(
            url: URL(string: "https://dev.lunchmoney.app/v1/plaid_accounts")!,
            config: config
        )
        .decode(type: Api.PlaidAccounts.self, decoder: decoder)
        .mapError { _ in ApiError.unknown }
        .eraseToAnyPublisher()
    }
    
    func getBudget(startDate: Date, endDate: Date) -> AnyPublisher<Api.CategoryBudgets, ApiError> {
        let dateFormat = "YYYY-MM-dd"
        let formattedStart = formatDate(date: startDate, format: dateFormat)
        let formattedEnd = formatDate(date: endDate, format: dateFormat)
        
        return httpGet(
            url: URL(string: "https://dev.lunchmoney.app/v1/budgets?start_date=\(formattedStart)&end_date=\(formattedEnd)")!,
            config: config
        )
        .decode(type: Api.CategoryBudgets.self, decoder: decoder)
        .mapError { _ in ApiError.unknown }
        .eraseToAnyPublisher()
    }
}
