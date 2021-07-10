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

    debugPrint("GET: \(url.absoluteString))")
    let (data, response) = try await URLSession.shared.data(for: urlRequest)
    
    guard let httpResponse = response as? HTTPURLResponse else {
        debugPrint("Unable to parse response")
        throw ApiError.unknown
    }
    
    if httpResponse.statusCode == 401 {
        debugPrint("GET: Server responded with 401")
        throw ApiError.forbidden
    } else if httpResponse.statusCode != 200 {
        debugPrint("GET: Server responded with \(httpResponse.statusCode)")
        throw ApiError.invalidResponse
    }
    
    debugPrint("GET: Server responded with data \(String(data: data, encoding: .utf8) ?? "")")
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
    
    func getBudget(startDate: Date, endDate: Date) async throws -> Data {
        let dateFormat = "YYYY-MM-dd"
        let formattedStart = formatDate(date: startDate, format: dateFormat)
        let formattedEnd = formatDate(date: endDate, format: dateFormat)
        
        return try await httpGet(
            url: URL(string: "https://dev.lunchmoney.app/v1/budgets?start_date=\(formattedStart)&end_date=\(formattedEnd)")!,
            config: config
        )
    }
}
