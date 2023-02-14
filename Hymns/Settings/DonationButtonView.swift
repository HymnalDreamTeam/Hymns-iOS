import FirebaseCrashlytics
import StoreKit
import SwiftUI

struct DonationButtonView: View {

    private let coffeeDonations: [any CoffeeDonation]
    @Binding var resultBinding: Result<SettingsToastItem, Error>?
    @State private var showDonationOptions = false

    init(coffeeDonations: [any CoffeeDonation], resultBinding: Binding<Result<SettingsToastItem, Error>?>) {
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

#if DEBUG
struct DonationButtonView_Previews: PreviewProvider {
    static var previews: some View {
        DonationButtonView(coffeeDonations: [], resultBinding: .constant(nil)).previewLayout(.sizeThatFits)
    }
}
#endif
