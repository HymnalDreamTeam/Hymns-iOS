import FirebaseAnalytics
import MessageUI
import Resolver
import SwiftUI

struct SettingsView: View {

    @ObservedObject private var viewModel: SettingsViewModel

    @State var result: Result<SettingsToastItem, Error>?

    init(viewModel: SettingsViewModel = Resolver.resolve()) {
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
                        CustomTitle(title: NSLocalizedString("Settings", comment: "Settings tab title"))
                        ForEach(settings) { setting in
                            setting.view
                        }
                    }
                }.eraseToAnyView()
        }.onAppear {
            self.viewModel.populateSettings(result: self.$result)
            let params: [String: Any] = [
                AnalyticsParameterScreenName: "SettingsView"]
            Analytics.logEvent(AnalyticsEventScreenView, parameters: params)
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
