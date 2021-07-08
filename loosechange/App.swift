import SwiftUI

@main
struct LooseChangeApp: App {
    @ObservedObject var state = State()
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                DashboardView()
            }
            .environmentObject(state)
        }
    }
}
