import SwiftUI
import UIKit
import Resolver

struct AboutUsDialogView: View {

    @Environment(\.presentationMode) var presentationMode
    private let analytics: FirebaseLogger = Resolver.resolve()
    private let application: Application = Resolver.resolve()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                HStack {
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Image(systemName: "xmark").accessibilityLabel(Text("Close page", comment: "A11y label to close the 'About Us' page."))
                    })
                    Text("About us", comment: "'About Us' page title.").fontWeight(.bold).padding(.leading)
                    Spacer()
                }.padding().padding(.top).foregroundColor(.primary)
                Text("Hello there 👋", comment: "'About Us' page greeting.").font(.title).fontWeight(.bold).padding()
                Text("We're the team behind this hymnal app. We love Jesus, and we created this app as a free resource to help other believers access the thousands of hymns available on the internet. We also built in support for the hymns indexed by the Living Stream Ministry hymnal.", comment: "'About Us' page blurb.").font(.callout).padding()
                Text("Let the word of Christ dwell in you richly in all wisdom, teaching and admonishing one another with psalms and hymns and spiritual songs, singing with grace in your hearts to God.", comment: "'About Us' page verse.")
                    .font(.body).fontWeight(.light).padding().padding(.horizontal)
                HStack {
                    Spacer()
                    Text("- Col. 3:16", comment: "'About Us' page verse reference.").font(.body).fontWeight(.bold).padding(.trailing)
                }
                Spacer()
            }
        }
    }
}

#Preview {
    AboutUsDialogView()
}
