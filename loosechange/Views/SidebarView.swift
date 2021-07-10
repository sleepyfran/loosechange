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
    
    func openUrl(_ url: String) {
        UIApplication.shared.open(URL(string: url)!)
    }
    
    var body: some View {
        List {
            NavigationLink(destination: BudgetView()) {
                Label("Budget", systemImage: "dollarsign.square")
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
            
            Section(header: Text("Links")) {
                Button(action: {
                    openUrl("https://github.com/sleepyfran/loosechange")
                }) {
                    Label("App's source code", systemImage: "curlybraces.square")
                }
                
                Button(action: {
                    openUrl("https://lunchmoney.app/")
                }) {
                    Label("Open LunchMoney", systemImage: "arrow.up.right.square")
                }
            }
        }
        .listStyle(.sidebar)
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
                Text("\(account.formattedType.uppercased()) > \(account.formattedSubtype.uppercased())")
                    .padding(.bottom, 1)
                    .font(.caption)
                Text(account.displayName)
                    .bold()
                    .font(.title3)
                Text(account.formattedBalance)
                    .foregroundColor(.teal)
                    .font(.callout)
            }
            .padding(.horizontal, 3)
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
