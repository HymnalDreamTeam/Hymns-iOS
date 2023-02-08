import Foundation
import MessageUI
import Resolver
import StoreKit
import SwiftUI
import UIKit

class SettingsViewModel: ObservableObject {

    let historyStore: HistoryStore
    let navigationCoordinator: NavigationCoordinator
    let systemUtil: SystemUtil

    @Published var settings: [SettingsModel]? = [SettingsModel]()

    init(historyStore: HistoryStore = Resolver.resolve(), navigationCoordinator: NavigationCoordinator = Resolver.resolve(),
         systemUtil: SystemUtil = Resolver.resolve()) {
        self.historyStore = historyStore
        self.navigationCoordinator = navigationCoordinator
        self.systemUtil = systemUtil
    }

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

        settings = [.repeatChorus(repeatChorusViewModel), .clearHistory(clearHistoryViewModel), .aboutUs, .feedback(result), .privacyPolicy]

        if systemUtil.isNetworkAvailable() {
            settings?.append(.donate(result))
        }

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
    case donate(Binding<Result<SettingsToastItem, Error>?>)
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
        case .donate(let result):
            return DonationButtonView(result: result).eraseToAnyView()
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
        case .donate:
            return 7
        }
    }
}

extension Resolver {
    public static func registerSettingsViewModel() {
        register {SettingsViewModel()}.scope(.graph)
    }
}
