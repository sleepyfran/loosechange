import SwiftUI

///  Shows a transaction from either all accounts or a specific one.
struct TransactionsView: View {
    @EnvironmentObject var state: AppState
    @StateObject var transactionsRemote = RemoteState<[Transaction]>()
    let transactionAccount: TransactionAccount
    
    var transactionsService: TransactionsService {
        TransactionsService(token: state.accessToken)
    }
    
    func fetch() {
        transactionsRemote.fetch(
            appState: state,
            action: {
                switch transactionAccount {
                case .all(let accounts):
                    return transactionsService
                        .fetchMonthTransactions(for: accounts)
                case .specific(let account):
                    return transactionsService
                        .fetchMonthTransactions(for: [account])
                }
            }
        )
    }
        
    var body: some View {
        List {
            Section {
                switch transactionAccount {
                case .all(_):
                    Text("Showing this month's transactions from all accounts")
                        .font(.callout)
                case .specific(let account):
                    Text("Showing this month's transactions from \(account.displayName)")
                        .font(.callout)
                }
            }
            
            switch transactionsRemote.remote {
            case .notRequested:
                EmptyView()
            case .failed:
                ApiErrorView()
            case .loading:
                TransactionListView(
                    loading: true,
                    transactions: Transactions.placeholder()
                )
            case .done(let transactions):
                TransactionListView(
                    loading: false,
                    transactions: transactions
                )
            }
        }
        .refreshable {
            fetch()
        }
        .onAppear {
            fetch()
        }
        .navigationTitle("Transactions")
    }
}

struct TransactionListView: View {
    var loading = false
    var transactions: [Transaction]
    
    var groupedByDate: [(String, [Transaction])] {
        transactions
            .reduce(into: [:], { acc, transaction in
                let date = formatDate(
                    date: transaction.date,
                    format: "EEEE, MMM d"
                )
                var dateItems = acc[date] ?? []
                dateItems.append(transaction)
                acc[date] = dateItems
            })
            .reduce([], { acc, t in acc + [(t.key, t.value)] })
            .sorted(by: { t1, t2 in
                t1.1.first!.date > t2.1.first!.date
            })
    }
    
    var body: some View {
        ForEach(groupedByDate, id: \.0) { date, transactionList in
            Section {
                Text(date)
                    .font(.title2)
                    .bold()
                
                ForEach(transactionList, id: \.id) { transaction in
                    TransactionView(transaction: transaction)
                }
            }
            .redacted(reason: loading ? .placeholder : .init())
        }
    }
}

private struct TransactionView: View {
    let transaction: Transaction
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                VStack(alignment: .leading) {
                    Text(transaction.payee)
                        .bold()
                    Text(transaction.category.name)
                        .font(.caption)
                }
                Spacer()
                Text(transaction.formattedAmount)
                    .bold()
                    .font(.title3)
            }
            
            if !transaction.notes.isEmpty {
                Text(transaction.notes)
                    .foregroundColor(.accentColor)
                    .font(.callout)
                    .padding(.top, 1)
            }
        }
        .padding(3)
    }
}

struct TransactionsView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            TransactionListView(
                loading: false,
                transactions: Transactions.placeholder()
            )
        }
        
        List {
            TransactionListView(
                loading: true,
                transactions: Transactions.placeholder()
            )
        }
    }
}
