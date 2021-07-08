import Foundation

/// Holds the entire state of the app that will be observed by the UI to display.
class State: ObservableObject {
    @Published var accounts: [Account]
    
    init() {
        accounts = []
    }
    
    init(accounts: [Account]) {
        self.accounts = accounts
    }
}
