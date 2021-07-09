import SwiftUI

struct AuthView: View {
    @EnvironmentObject var state: AppState
    @State var accessToken = ""
    var loginAvailable: Bool {
        accessToken.count >= 40
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Login")
                .font(.title)
                .bold()
                .padding()
            
            Form {
                TextField("Access token", text: $accessToken)
                Button(action: {
                    state.updateAccessToken(accessToken)
                }) {
                    Text("Login")
                        .frame(maxWidth: 400)
                }
                .disabled(!loginAvailable)
                .listRowSeparator(.hidden)
                .buttonStyle(.bordered)
                .controlSize(.large)
                .controlProminence(.increased)
                
                Text("You can get an access token from **LaunchMoney > Settings > Developers > Request new access token**")
                    .padding()
            }
        }
        .navigationTitle("Login")
    }
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView()
            .environmentObject(AppState())
    }
}
