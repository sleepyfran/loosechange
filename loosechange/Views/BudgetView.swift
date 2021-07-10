import SwiftUI

struct BudgetView: View {
    @EnvironmentObject var state: AppState
    var currentMonthYear: String {
        formatDate(date: Date.now, format: "MM/YYYY")
    }
    
    func fetch() async {
        await authorizedFetchWithStatus(
            state: state,
            fetch: state.fetchCurrentMonthBudget
        )
    }
        
    var body: some View {
        VStack(alignment: .leading) {
            switch state.fetchStatus {
            case .notRequested:
                EmptyView()
            case .fetching:
                DelayedView {
                    ProgressView()
                }
            case .errored:
                ApiErrorView()
            case .fetched:
                BudgetInfoView(budget: state.currentBudget)
            }
        }
        .navigationTitle("Budget for \(currentMonthYear)")
        .task {
            await fetch()
        }
        .refreshable {
            await fetch()
        }
    }
}

private struct BudgetInfoView: View {
    let budget: Budget
    
    var body: some View {
        List {
            ForEach(budget, id: \.0) { category, content in
                Text(category)
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
                    ? .teal
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
