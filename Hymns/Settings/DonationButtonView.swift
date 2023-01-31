import FirebaseCrashlytics
import SwiftUI

struct DonationButtonView: View {

    @Binding var result: Result<SettingsToastItem, Error>?
    @State private var showDonationOptions = false

    var body: some View {
        Button(action: {
            self.showDonationOptions.toggle()
        }, label: {
            Text("Buy us coffee!", comment: "Settings item for making a donation.").font(.callout)
        }).padding().foregroundColor(.primary)
            .sheet(isPresented: $showDonationOptions) {
                DonationView(viewModel: DonationViewModel(result: self.$result))
            }
    }
}

#if DEBUG
struct DonationButtonView_Previews: PreviewProvider {
    static var previews: some View {
        DonationButtonView(result: .constant(nil))
    }
}
#endif
