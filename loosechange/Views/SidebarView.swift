import SwiftUI

/// Exposes the main sidebar of the app, which includes all common entry points to the app.
struct SidebarView: View {
    @EnvironmentObject var state: AppState
    
    func fetch() async {
        await authorizedFetchWithStatus(
            state: state,
            fetch: state.fetchAccounts
        )
    }
    
    var body: some View {
        List {
            NavigationLink(destination: BudgetView()) {
                Label("Budget", systemImage: "dollarsign.circle")
            }
                        
            Section(header: Text("Accounts & Assets")) {
                switch state.fetchStatus {
                case .notRequested:
                    EmptyView()
                case .errored:
                    ApiErrorView()
                case .fetching:
                    AccountsView(accounts: state.accounts)
                case .fetched:
                    AccountsView(accounts: state.accounts)
                }
            }
        }
        .listStyle(SidebarListStyle())
        .navigationTitle("LooseChange")
        .onReceive(state.$requiresLogin) { _ in
            async {
                await fetch()
            }
        }
        .task {
            await fetch()
        }
        .refreshable {
            await fetch()
        }
    }
}


private struct AccountsView: View {
    var accounts: [Account]
    
    var body: some View {
        ForEach(accounts, id: \.displayName) { account in
            VStack(alignment: .leading) {
                Text(account.formattedType.uppercased())
                    .padding(.bottom, 1)
                    .font(.caption)
                Text(account.displayName)
                    .bold()
                    .font(.title3)
                Text(account.formattedBalance)
                    .foregroundColor(.accentColor)
                    .font(.callout)
            }
            .padding(3)
            .listRowSeparator(.hidden)
        }
    }
}

struct Sidebar_Previews: PreviewProvider {
    static var previews: some View {
        SidebarView()
            .environmentObject(AppState())
    }
}
