import SwiftUI

/// Exposes a view to be shown whenever there's no data available.
struct NoDataView: View {
    var label = "There's nothing here yet."
    
    var body: some View {
        VStack {
            Image(systemName: "eyes")
                .font(.system(size: 100))
            
            Text(label)
                .padding()
        }
    }
}

struct NoDataView_Previews: PreviewProvider {
    static var previews: some View {
        NoDataView()
        
        NoDataView(label: "Oops. A very long message to test the paddings are correct")
    }
}
