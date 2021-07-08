import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var state: State
    
    var body: some View {
        VStack {
            if state.accounts.isEmpty {
                EmptyView()
            } else {
                AccountsView(accounts: state.accounts)
                Spacer()
            }
        }
        .navigationTitle("Accounts")
    }
}

private struct EmptyView: View {
    var body: some View {
        NoDataView(label: "No accounts added. Add one in LunchMoney")
    }
}

private struct AccountsView: View {
    var accounts: [Account]
        
    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack {
                ForEach(accounts, id: \.displayName) { account in
                    AccountCard(account: account)
                        .frame(width: 250, height: 120, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                        .padding()
                }
            }
        }
        .frame(maxHeight: 150)
    }
}

struct Dashboard_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
            .environmentObject(State(
                accounts: [
                    Account(
                        displayName: "Test",
                        formattedBalance: "1.950€"
                    ),
                    Account(
                        displayName: "Test 2",
                        formattedBalance: "100.950€"
                    ),
                    Account(
                        displayName: "Test 3",
                        formattedBalance: "192.950€"
                    ),
                ]
            ))
        
        DashboardView()
            .environmentObject(State())
    }
}
