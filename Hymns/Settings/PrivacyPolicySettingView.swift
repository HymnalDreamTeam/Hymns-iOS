import FirebaseCrashlytics
import SwiftUI

struct PrivacyPolicySettingView: View {

    @State private var showPrivacyPolicy = false

    var body: some View {
        Button(action: {self.showPrivacyPolicy.toggle()}, label: {
            Text("Privacy policy", comment: "Show the privacy policy.").font(.callout)
        }).padding().foregroundColor(.primary)
            .sheet(isPresented: self.$showPrivacyPolicy, content: {
                PrivacyPolicyView(showPrivacyPolicy: self.$showPrivacyPolicy)
            })
    }
}

#if DEBUG
struct PrivacyPolicySettingView_Previews: PreviewProvider {
    static var previews: some View {
        PrivacyPolicySettingView().toPreviews()
    }
}
#endif
