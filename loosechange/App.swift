import SwiftUI

@main
struct LooseChangeApp: App {
    @ObservedObject var state = AppState()
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                DashboardView()
                BudgetView()
            }
            .fullScreenCover(
                isPresented: $state.requiresLogin,
                onDismiss: {}
            ) {
                AuthView()
            }
            .environmentObject(state)
            .accentColor(.teal)
        }
    }
}
