import Foundation
import Combine
import HTMLEntities

private func decoder() -> JSONDecoder {
    let dec = JSONDecoder()
    dec.keyDecodingStrategy = .convertFromSnakeCase
    return dec
}

private let ACCESS_TOKEN_KEY = "accessToken"

/// Holds the entire state of the app that will be observed by the UI to display.
class AppState: ObservableObject {
    @Published var accessToken = ""
    @Published var requiresLogin: Bool = true
    
    init() {
        accessToken = UserDefaults.standard.string(forKey: ACCESS_TOKEN_KEY) ?? ""
        requiresLogin = accessToken.isEmpty
    }
        
    func updateAccessToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: ACCESS_TOKEN_KEY)
        accessToken = token
        requiresLogin = false
    }
}
