import FirebaseCrashlytics
import SwiftUI

struct PrivacyPolicyView: View {

    @Binding var showPrivacyPolicy: Bool

    var body: some View {
        guard let url = URL(string: "https://app.termly.io/document/privacy-policy/4b9dd46b-aca9-40ae-ac97-58b47e4b4cac") else {
            Crashlytics.crashlytics().log("Privacy policy url: 'https://app.termly.io/document/privacy-policy/4b9dd46b-aca9-40ae-ac97-58b47e4b4cac'")
            Crashlytics.crashlytics().record(error: NonFatal(localizedDescription: "Privacy policy url malformed"))
            return ErrorView().eraseToAnyView()
        }
        return VStack(alignment: .leading) {
            Button(action: {
                self.showPrivacyPolicy = false
            }, label: {
                Text("Close", comment: "Close the Privacy Policy.").padding([.top, .horizontal])
            })
            WebView(url: url)
        }.eraseToAnyView()
    }
}

#if DEBUG
struct PrivacyPolicyView_Previews: PreviewProvider {
    static var previews: some View {
        PrivacyPolicyView(showPrivacyPolicy: .constant(true))
    }
}
#endif
