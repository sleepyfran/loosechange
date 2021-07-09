import Foundation

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

private func httpGet(url: URL, config: ApiConfig) async throws -> Data {
    var urlRequest = URLRequest(url: url)
    urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
    urlRequest.setValue(
        bearer(from: config),
        forHTTPHeaderField: "Authorization"
    )

    let (data, response) = try await URLSession.shared.data(for: urlRequest)
    
    guard let httpResponse = response as? HTTPURLResponse else {
        throw ApiError.unknown
    }
    
    if httpResponse.statusCode == 401 {
        throw ApiError.forbidden
    } else if httpResponse.statusCode != 200 {
        throw ApiError.invalidResponse
    }
    
    return data
}

struct LunchMoneyApi {
    let config: ApiConfig
    
    func getAccounts() async throws -> Data {
        try await httpGet(
            url: URL(string: "https://dev.lunchmoney.app/v1/assets")!,
            config: config
        )
    }
    
    func getPlaidAccounts() async throws -> Data {
        try await httpGet(
            url: URL(string: "https://dev.lunchmoney.app/v1/plaid_accounts")!,
            config: config
        )
    }
}
