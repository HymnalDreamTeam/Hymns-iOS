import Foundation
import MessageUI
import Resolver
import SwiftUI
import UIKit

class SettingsViewModel: ObservableObject {

    let historyStore: HistoryStore = Resolver.resolve()
    let navigationCoordinator: NavigationCoordinator = Resolver.resolve()

    @Published var settings: [SettingsModel]? = [SettingsModel]()

    func populateSettings(result: Binding<Result<SettingsToastItem, Error>?>) {
        let repeatChorusViewModel = RepeatChorusViewModel()
        let clearHistoryViewModel = SimpleSettingViewModel(title: NSLocalizedString("Clear recent songs", comment: "Clear the 'recent songs' list."), action: {
            do {
                try self.historyStore.clearHistory()
                result.wrappedValue = .success(.clearHistory)
            } catch let error {
                result.wrappedValue = .failure(error)
            }
        })

        settings = [.repeatChorus(RepeatChorusViewModel()), .clearHistory(clearHistoryViewModel), .aboutUs, .feedback(result), .privacyPolicy]

        if #available(iOS 16, *) {
            let versionViewModel = SimpleSettingViewModel(title: NSLocalizedString("Version information",
                                                                                   comment: "Displaying information about the app's version and device's version."),
                                                          action: {
                self.navigationCoordinator.showVersionInformation()
            })
            settings?.append(.version(versionViewModel))
        }

        #if DEBUG
        settings?.append(.clearUserDefaults)
        #endif
    }
}

enum SettingsModel {
    case repeatChorus(RepeatChorusViewModel)
    case clearHistory(SimpleSettingViewModel)
    case aboutUs
    case feedback(Binding<Result<SettingsToastItem, Error>?>)
    case privacyPolicy
    case clearUserDefaults
    case version(SimpleSettingViewModel)
}

extension SettingsModel {

    var view: some View {
        switch self {
        case .repeatChorus(let viewModel):
            return RepeatChorusView(viewModel: viewModel).eraseToAnyView()
        case .clearHistory(let viewModel):
            return SimpleSettingView(viewModel: viewModel).eraseToAnyView()
        case .aboutUs:
            return AboutUsButtonView().eraseToAnyView()
        case .feedback(let result):
            return FeedbackView(result: result).eraseToAnyView()
        case .privacyPolicy:
            return PrivacyPolicySettingView().eraseToAnyView()
        case .clearUserDefaults:
            return ClearUserDefaultsView().eraseToAnyView()
        case .version(let viewModel):
            return SimpleSettingView(viewModel: viewModel).eraseToAnyView()
        }
    }
}

extension SettingsModel: Identifiable {
    var id: Int {
        switch self {
        case .repeatChorus:
            return 0
        case .clearHistory:
            return 1
        case .aboutUs:
            return 2
        case .feedback:
            return 3
        case .privacyPolicy:
            return 4
        case .clearUserDefaults:
            return 5
        case .version:
            return 6
        }
    }
}

extension Resolver {
    public static func registerSettingsViewModel() {
        register {SettingsViewModel()}.scope(.graph)
    }
}
