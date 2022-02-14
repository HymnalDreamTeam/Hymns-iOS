import Foundation
import Darwin
import Resolver
import SwiftUI

/**
 * Debug setting that allows us to clear the user defaults for debugging/testing purposes.
 */
struct ClearUserDefaultsView: View {

    @State private var showPrivacyPolicy = false

    var body: some View {
        Button(action: {
            if let bundleID = Bundle.main.bundleIdentifier {
                UserDefaults.standard.removePersistentDomain(forName: bundleID)
                exit(0)
            }
        }, label: {
            Text("Clear user defaults", comment: "Debug feature, does not need translation.").font(.callout)
        }).padding().foregroundColor(.primary)
    }
}

#if DEBUG
struct ClearUserDefaultsView_Previews: PreviewProvider {
    static var previews: some View {
        ClearUserDefaultsView().toPreviews()
    }
}
#endif
