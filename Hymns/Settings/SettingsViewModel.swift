import Foundation
import MessageUI
import Resolver
import SwiftUI
import UIKit

class SettingsViewModel: ObservableObject {

    let historyStore: HistoryStore = Resolver.resolve()

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

        #if DEBUG
        settings = [.repeatChorus(repeatChorusViewModel), .clearHistory(clearHistoryViewModel), .aboutUs, .feedback(result), .privacyPolicy, .clearUserDefaults]
        #else
        settings = [.repeatChorus(RepeatChorusViewModel()), .clearHistory(clearHistoryViewModel), .aboutUs, .feedback(result), .privacyPolicy]
        #endif

        if let url = URL(string: "https://www.buymeacoffee.com/hymnsmobile") {
            let donateViewModel = SimpleSettingViewModel(title: NSLocalizedString("Buy us coffee!", comment: "Settings item for making a donation."), action: {
                UIApplication.shared.open(url)
            })
            settings?.append(.donate(donateViewModel))
        }
    }
}

enum SettingsModel {
    case repeatChorus(RepeatChorusViewModel)
    case clearHistory(SimpleSettingViewModel)
    case aboutUs
    case feedback(Binding<Result<SettingsToastItem, Error>?>)
    case privacyPolicy
    case donate(SimpleSettingViewModel)
    case clearUserDefaults
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
        case .donate(let viewModel):
            return SimpleSettingView(viewModel: viewModel).eraseToAnyView()
        case .clearUserDefaults:
            return ClearUserDefaultsView().eraseToAnyView()
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
        case .donate:
            return 5
        case .clearUserDefaults:
            return 6
        }
    }
}

extension Resolver {
    public static func registerSettingsViewModel() {
        register {SettingsViewModel()}.scope(.graph)
    }
}
