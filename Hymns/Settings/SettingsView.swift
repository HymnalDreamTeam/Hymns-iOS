import MessageUI
import Prefire
import Resolver
import StoreKit
import SwiftUI

struct SettingsView: View {

    @ObservedObject private var viewModel: SettingsViewModel

    @State var result: SettingsResult<SettingsToastItem, Error>?

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

// Create a bespoke result item insted of using Swift.Result because
// Swift.Result mysteriously causes a crash:
// EXC_BAD_ACCESS KERN_INVALID_ADDRESS 0x0000000000000000
// https://console.firebase.google.com/u/0/project/release-a8614/crashlytics/app/ios:com.lukelu.Hymns/issues/f9b8fbc490df5f4eeef8237dac104e7c?time=last-seven-days&types=crash&sessionEventKey=de70ea435d1a4375b181bd5c33fe5790_2035012781348792825
enum SettingsResult<Success, Failure> where Failure: Error {

    /// A success, storing a `Success` value.
    case success(Success)

    /// A failure, storing a `Failure` value.
    case failure(Failure)
}

public enum SettingsToastItem {
    case clearHistory
    case feedback(MFMailComposeResult)
    case donate(DonationResult)
}

#if DEBUG
struct SettingsView_Previews: PreviewProvider, PrefireProvider {
    static var previews: some View {

        let loadingViewModel = NoOpSettingsViewModel()
        let loading = SettingsView(viewModel: loadingViewModel)

        let errorViewModel = NoOpSettingsViewModel()
        errorViewModel.settings = nil
        let error = SettingsView(viewModel: errorViewModel)

        let settingsViewModel = NoOpSettingsViewModel()
        settingsViewModel.settings = [.repeatChorus(RepeatChorusViewModel()), .aboutUs, .privacyPolicy, .clearUserDefaults]
        let settings = SettingsView(viewModel: settingsViewModel)

        return Group {
            loading.previewDisplayName("loading")
            error.previewDisplayName("error")
            settings.previewDisplayName("settings")
        }
    }
}

class NoOpSettingsViewModel: SettingsViewModel {
    override func populateSettings(result: Binding<SettingsResult<SettingsToastItem, any Error>?>) {
        // no op
    }
}
#endif
