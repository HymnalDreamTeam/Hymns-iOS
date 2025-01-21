import Resolver
import SwiftUI

struct PrivacyPolicyView: View {

    @Binding var showPrivacyPolicy: Bool

    private let firebaseLogger: FirebaseLogger

    init(showPrivacyPolicy: Binding<Bool>, firebaseLogger: FirebaseLogger = Resolver.resolve()) {
        self._showPrivacyPolicy = showPrivacyPolicy
        self.firebaseLogger = firebaseLogger
    }

    var body: some View {
        guard let url = URL(string: "https://app.termly.io/document/privacy-policy/4b9dd46b-aca9-40ae-ac97-58b47e4b4cac") else {
            firebaseLogger.logError(MalformedPrivacyPolicyError(errorDescription: "Privacy policy url malformed"),
                                    extraParameters: ["url": "https://app.termly.io/document/privacy-policy/4b9dd46b-aca9-40ae-ac97-58b47e4b4cac"])
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

#Preview {
    PrivacyPolicyView(showPrivacyPolicy: .constant(true))
        .prefireIgnored()
}
