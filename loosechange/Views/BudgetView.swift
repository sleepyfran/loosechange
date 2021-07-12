import SwiftUI

struct BudgetView: View {
    @EnvironmentObject var state: AppState
    @StateObject var budgetRemote = RemoteState<Budget>()
    
    var budgetsService: BudgetsService {
        BudgetsService(token: state.accessToken)
    }
    
    var currentMonthYear: String {
        formatDate(date: Date.now, format: "MM/YYYY")
    }
    
    func fetch() {
        budgetRemote.fetch(
            appState: state,
            action: budgetsService.fetchCurrentMonthBudget
        )
    }
        
    var body: some View {
        VStack(alignment: .leading) {
            switch budgetRemote.remote {
            case .notRequested:
                EmptyView()
            case .failed:
                ApiErrorView()
            case .loading:
                BudgetInfoView(budget: Budget.placeholder())
                    .redacted(reason: .placeholder)
            case .done(let budget):
                BudgetInfoView(budget: budget)
            }
        }
        .navigationTitle("Budget for \(currentMonthYear)")
        .onAppear {
            fetch()
        }
        .refreshable {
            fetch()
        }
    }
}

private struct BudgetInfoView: View {
    let budget: Budget
    
    var body: some View {
        List {
            ForEach(budget, id: \.0) { category, content in
                Text(category.isEmpty ? "Ungrouped" : category)
                    .font(.title)
                    .bold()
                
                ForEach(content, id: \.name) { categoryBudget in
                    BudgetItemInfoView(item: categoryBudget)
                }
            }
            .listRowSeparator(.hidden)
            
            Section {
                Text("Amounts represent either the money left or the overspending on the category")
                    .font(.callout)
            }
        }
    }
}

private struct BudgetItemInfoView: View {
    let item: CategoryBudget
    
    var body: some View {
        HStack(alignment: .center) {
            Text(item.name)
                .font(.title3)
            Spacer()
            Text(item.formattedAvailable)
                .foregroundColor(
                    item.availableStatus == .positive
                    ? .accentColor
                    : .red
                )
                .font(.callout)
        }
        .listRowSeparator(.visible)
    }
}

struct Dashboard_Previews: PreviewProvider {
    static var previews: some View {
        BudgetView()
            .environmentObject(AppState())
    }
}
