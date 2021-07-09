import SwiftUI

struct BudgetView: View {
    @EnvironmentObject var state: AppState
        
    var body: some View {
        Text("TBD")
            .navigationTitle("Budget")
    }
}

struct Dashboard_Previews: PreviewProvider {
    static var previews: some View {
        BudgetView()
    }
}
