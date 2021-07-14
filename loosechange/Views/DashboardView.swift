import SwiftUI
import Combine

/// Exposes the main sidebar of the app, which includes all common entry points to the app.
struct DashboardView: View {
    @EnvironmentObject var state: AppState
    @StateObject var accountsRemote = RemoteState<[Account]>()
    @State var cancellables: [AnyCancellable] = []
    
    var accountsService: AccountsService {
        AccountsService(token: state.accessToken)
    }
        
    func fetchCombine() {
        accountsRemote.fetch(
            appState: state,
            action: accountsService.fetchAccounts
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
                switch accountsRemote.remote {
                case .notRequested:
                    EmptyView()
                case .failed:
                    ApiErrorView()
                case .loading:
                    AccountsView(
                        loading: true,
                        accounts: Accounts.placeholder()
                    )
                case .done(let accounts):
                    AccountsView(
                        loading: false,
                        accounts: accounts
                    )
                }
            }
            
            Section(header: Text("Links")) {
                Button(action: {
                    openUrl("https://github.com/sleepyfran/loosechange")
                }) {
                    Label(
                        "App's source code",
                        systemImage: "curlybraces.square"
                    )
                }
                
                Button(action: {
                    openUrl("https://lunchmoney.app/")
                }) {
                    Label(
                        "Open LunchMoney",
                        systemImage: "arrow.up.right.square"
                    )
                }
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("Dashboard")
        .onReceive(state.$requiresLogin) { _ in
            fetchCombine()
        }
        .refreshable {
            fetchCombine()
        }
    }
}


private struct AccountsView: View {
    var loading = false
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
                    .foregroundColor(.accentColor)
                    .font(.callout)
            }
            .padding(.horizontal, 3)
            .listRowSeparator(.hidden)
        }
        .redacted(reason: loading ? .placeholder : .init())
    }
}

struct Sidebar_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
            .environmentObject(AppState())
        
        List {
            AccountsView(
                loading: true,
                accounts: Accounts.placeholder()
            )
        }
    }
}
