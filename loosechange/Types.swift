enum FetchStatus {
    case notRequested, fetching, errored, fetched
}

/// Defines an account or asset that the user is holding.
struct Account {
    let displayName: String
    let formattedBalance: String
    let formattedType: String
}

enum Api {
    struct Asset: Codable {
        let displayName: String
        let balance: String
        let currency: String
        let typeName: String
    }
    
    struct PlaidAccount: Codable {
        // TODO: Switch to displayName once the API returns it
        let name: String
        let balance: String
        let currency: String
        let type: String
    }
    
    struct Assets: Codable {
        let assets: [Asset]
    }
    
    struct PlaidAccounts: Codable {
        let plaidAccounts: [PlaidAccount]
    }
}
