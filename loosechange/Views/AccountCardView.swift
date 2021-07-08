import SwiftUI

/// Displays the name and balance of an acocunt inside of a card.
struct AccountCard: View {
    var account: Account
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color(UIColor.systemGray6))
                .shadow(radius: 5)

            VStack {
                Text(account.displayName)
                    .font(.largeTitle)
                    .foregroundColor(Color(UIColor.label))

                Text(account.formattedBalance)
                    .font(.title)
                    .foregroundColor(Color(UIColor.secondaryLabel))
            }
            .padding(20)
            .multilineTextAlignment(.center)
        }
    }
}

struct AccountCard_Previews: PreviewProvider {
    static var previews: some View {
        AccountCard(account: Account(
            displayName: "Test", formattedBalance: "1.950€"
        ))
    }
}
