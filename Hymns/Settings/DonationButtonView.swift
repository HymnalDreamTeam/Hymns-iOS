import StoreKit
import SwiftUI

struct DonationButtonView: View {

    private let coffeeDonations: [any CoffeeDonation]
    @Binding var resultBinding: SettingsResult<SettingsToastItem, Error>?
    @State private var showDonationOptions = false

    init(coffeeDonations: [any CoffeeDonation], resultBinding: Binding<SettingsResult<SettingsToastItem, Error>?>) {
        self.coffeeDonations = coffeeDonations
        self._resultBinding = resultBinding
    }

    var body: some View {
        Button(action: {
            self.showDonationOptions.toggle()
        }, label: {
            Text("Buy us coffee!", comment: "Settings item for making a donation.").font(.callout)
        }).padding().foregroundColor(.primary)
            .sheet(isPresented: $showDonationOptions) {
                DonationView(viewModel: DonationViewModel(coffeeDonations: coffeeDonations, resultBinding: self.$resultBinding))
            }
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    DonationButtonView(coffeeDonations: [], resultBinding: .constant(nil))
}
