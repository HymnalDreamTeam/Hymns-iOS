import FirebaseAnalytics
import StoreKit
import SwiftUI

struct DonationView: View {

    @Environment(\.presentationMode) var presentationMode

    @ObservedObject private var viewModel: DonationViewModel

    init(viewModel: DonationViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        Group { () -> AnyView in
            guard !viewModel.coffeeDonations.isEmpty else {
                return ErrorView().maxSize().eraseToAnyView()
            }
            return ScrollView {
                VStack(alignment: .leading) {
                    HStack {
                        Button(action: {
                            self.presentationMode.wrappedValue.dismiss()
                        }, label: {
                            Image(systemName: "xmark").accessibilityLabel(Text("Close page", comment: "A11y label to close the 'Donation' page."))
                        })
                        Text("Buy us coffee!", comment: "'Donation' page title.").fontWeight(.bold).padding(.leading)
                        Spacer()
                    }.padding().padding(.top).foregroundColor(.primary)
                    Text("All of us have regular day jobs and each of us has volunteered our time and effort to create this app for you to enjoy. While we are committed to keeping this app in tip-top shape, the maintenance costs unfortunately grow with our user base. In addition to the costs of putting the app on the app store, we also maintain an API to ensure you get all the latest songs delivered right to your phone in a seamless way. So far, these costs have been borne by a few folks who want to see it succeed. However, if you feel led to help with some of these costs, feel free to donate a few bucks to keep our team caffeinated! ☕", comment: "'Donation' page greeting.").font(.callout).padding()
                    ForEach(viewModel.coffeeDonations, id: \.self) { coffeeDonation in
                        Button(action: {
                            Task {
                                await self.viewModel.initiatePurchase(donationType: coffeeDonation)
                                self.presentationMode.wrappedValue.dismiss()
                            }
                        }, label: {
                            Text(.init(coffeeDonation.displayText)).padding().foregroundColor(.primary).multilineTextAlignment(.leading)
                        })
                    }
                    Spacer()
                }
            }.eraseToAnyView()
        }.task {
            let params: [String: Any] = [
                AnalyticsParameterScreenName: "DonationView"]
            Analytics.logEvent(AnalyticsEventScreenView, parameters: params)
        }
    }
}

#if DEBUG
struct DonationView_Previews: PreviewProvider {
    static var previews: some View {
        let errorViewModel = DonationViewModel(coffeeDonations: [CoffeeDonation](), resultBinding: .constant(nil))
        errorViewModel.coffeeDonations = []
        let error = DonationView(viewModel: errorViewModel)

        let donationsViewModel = DonationViewModel(coffeeDonations: [CoffeeDonation](), resultBinding: .constant(nil))
        donationsViewModel.coffeeDonations = [.donationCoffee1, .donationCoffee5, .donationCoffee10]
        let donations = DonationView(viewModel: donationsViewModel)

        return Group {
            error.previewDisplayName("error")
            donations.previewDisplayName("donations")
        }
    }
}
#endif
