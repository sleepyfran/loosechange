import SwiftUI

/// Wrapper around NavigationLink that automatically hides its content.
struct HiddenNavigationLink<Destination: View>: View {
    var destination: Destination
    @Binding var isActive: Bool
        
    var body: some View {
        NavigationLink(
            destination: destination,
            isActive: $isActive
        ) {
            EmptyView()
        }
        .hidden()
    }
}

/// Exposes a view to be shown whenever there's an error fetching something.
struct ApiErrorView: View {
    var body: some View {
        VStack {
            Image(systemName: "xmark.icloud")
                .font(.system(size: 100))
                .foregroundColor(.red)
            Text("There was an error fetching that, maybe the access token is not valid?")
                .bold()
                .padding()
        }
    }
}

/// Exposes a view to be shown whenever there's no data available.
struct NoDataView: View {
    var label = "There's nothing here yet."
    
    var body: some View {
        VStack {
            Image(systemName: "eyes")
                .foregroundColor(.accentColor)
                .font(.system(size: 100))
            
            Text(label)
                .bold()
                .padding()
        }
    }
}

/// Wrapper around a view that delays its content for a brief period of time. Used with loading indicators to
/// not show them inmediately in case whatever the loading indicator is wrapping is instant.
struct DelayedView<Content: View>: View {
    var content: Content
    @State private var showing = false
    
    init(@ViewBuilder contentBuilder: () -> Content) {
        content = contentBuilder()
    }
    
    var body: some View {
        VStack {
            if showing {
                content
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                showing = true
            }
        }
    }
}

struct Common_Previews: PreviewProvider {
    static var previews: some View {
        ApiErrorView()
        NoDataView()
        NoDataView(label: "Oops. A very long message to test the paddings are correct")
    }
}
