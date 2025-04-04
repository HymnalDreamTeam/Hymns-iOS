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

    func populateSettings(result: Binding<SettingsResult<SettingsToastItem, Error>?>) {
        let repeatChorusViewModel = RepeatChorusViewModel()
        let clearHistoryViewModel = SimpleSettingViewModel(title: NSLocalizedString("Clear recent songs", comment: "Clear the 'recent songs' list."), action: {
            do {
                try self.historyStore.clearHistory()
                result.wrappedValue = .success(.clearHistory)
            } catch let error {
                result.wrappedValue = .failure(error)
            }
        })

        settings = [
            .repeatChorus(repeatChorusViewModel), .preferredSearchLanguage,
            .aboutUs, .feedback(result), .privacyPolicy, .clearHistory(clearHistoryViewModel)]

        if !systemUtil.donationProducts.isEmpty {
            settings?.append(.donate(coffeeDonations: systemUtil.donationProducts, resultBinding: result))
        }

        let versionViewModel = SimpleSettingViewModel(title: NSLocalizedString("Version information",
                                                                               comment: "Displaying information about the app's version and device's version."),
                                                      action: {
            self.navigationCoordinator.showVersionInformation()
        })
        settings?.append(.version(versionViewModel))

#if DEBUG
        settings?.append(.clearUserDefaults)
#endif
    }
}

enum SettingsModel {
    case repeatChorus(RepeatChorusViewModel)
    case preferredSearchLanguage
    case clearHistory(SimpleSettingViewModel)
    case aboutUs
    case feedback(Binding<SettingsResult<SettingsToastItem, Error>?>)
    case privacyPolicy
    case clearUserDefaults
    case version(SimpleSettingViewModel)
    case donate(coffeeDonations: [any CoffeeDonation], resultBinding: Binding<SettingsResult<SettingsToastItem, Error>?>)
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
        case .donate(let coffeeDonations, let resultBinding):
            return DonationButtonView(coffeeDonations: coffeeDonations, resultBinding: resultBinding).eraseToAnyView()
        case .preferredSearchLanguage:
            return PreferredSearchLanguageView().eraseToAnyView()
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
        case .preferredSearchLanguage:
            return 8
        }
    }
}

extension Resolver {
    public static func registerSettingsViewModel() {
        register {SettingsViewModel()}.scope(.graph)
    }
}
