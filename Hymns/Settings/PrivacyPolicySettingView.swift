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

#Preview(traits: .sizeThatFitsLayout) {
    PrivacyPolicySettingView()
}
