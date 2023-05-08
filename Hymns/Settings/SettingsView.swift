import MessageUI
import Resolver
import StoreKit
import SwiftUI

struct SettingsView: View {

    @ObservedObject private var viewModel: SettingsViewModel

    @State var result: Result<SettingsToastItem, Error>?

    private let firebaseLogger: FirebaseLogger

    init(firebaseLogger: FirebaseLogger = Resolver.resolve(), viewModel: SettingsViewModel = Resolver.resolve()) {
        self.firebaseLogger = firebaseLogger
        self.viewModel = viewModel
    }

    var body: some View {
        Group { () -> AnyView in
            guard let settings = viewModel.settings else {
                return ErrorView().maxSize().eraseToAnyView()
            }

            guard !settings.isEmpty else {
                return ActivityIndicator().maxSize().eraseToAnyView()
            }
            return
                ScrollView {
                    VStack(alignment: .leading) {
                        CustomTitle(title: NSLocalizedString("Settings", comment: "Settings tab title."))
                        ForEach(settings) { setting in
                            setting.view
                        }
                    }
                }.eraseToAnyView()
        }.onAppear {
            firebaseLogger.logScreenView(screenName: "SettingsView")
            self.viewModel.populateSettings(result: self.$result)
        }.toast(item: $result, options: ToastOptions(alignment: .bottom, disappearAfter: 5)) { result -> AnyView in
            switch result {
            case .success(let success):
                switch success {
                case .feedback(let mailComposeResult):
                    switch mailComposeResult {
                    case .sent:
                        return HStack {
                            Image(systemName: "checkmark").foregroundColor(.green).padding()
                            Text("Feedback sent", comment: "Toast message for when feedback was succesfully sent.").padding(.trailing)
                        }.eraseToAnyView()
                    case .saved:
                        return Text("Feedback not sent but was saved to drafts", comment: "Toast message for when feedback was saved to drafts by the user.").padding().eraseToAnyView()
                    case .cancelled:
                        return Text("Feedback not sent", comment: "Toast message for when feedback was cancelled by the user.").padding().eraseToAnyView()
                    case .failed:
                        return Text("Feedback failed to send", comment: "Toast message for when feedback failed to send.").padding().eraseToAnyView()
                    @unknown default:
                        return Text("Feedback failed to send").padding().eraseToAnyView()
                    }
                case .clearHistory:
                    return Text("Recent songs cleared", comment: "Toast message for when recent songs are cleared.").padding().eraseToAnyView()
                case .donate(let purchaseResult):
                    switch purchaseResult {
                    case .success:
                        return Text("Thank you for keeping us caffeinated! 🤩", comment: "Toast message for when the donation was successful.").padding().eraseToAnyView()
                    default:
                        return Text("Something went wrong with your donation. No worries, you haven't been charged!", comment: "Toast message for when the donation was unsuccessful.").padding().eraseToAnyView()
                    }
                }
            case .failure:
                return Text("Oops! Something went wrong. Please try again", comment: "Generic error toast.").padding().eraseToAnyView()
            }
        }
    }
}

public enum SettingsToastItem {
    case clearHistory
    case feedback(MFMailComposeResult)
    case donate(DonationResult)
}

#if DEBUG
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {

        let loadingViewModel = SettingsViewModel()
        let loading = SettingsView(viewModel: loadingViewModel)

        let errorViewModel = SettingsViewModel()
        errorViewModel.settings = nil
        let error = SettingsView(viewModel: errorViewModel)

        let settingsViewModel = SettingsViewModel()
        settingsViewModel.settings = [.repeatChorus(RepeatChorusViewModel()), .aboutUs, .privacyPolicy, .clearUserDefaults]
        let settings = SettingsView(viewModel: settingsViewModel)

        return Group {
            loading.previewDisplayName("loading")
            error.previewDisplayName("error")
            settings.previewDisplayName("settings")
        }
    }
}
#endif
