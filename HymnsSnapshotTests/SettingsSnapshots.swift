import SnapshotTesting
import StoreKit
import SwiftUI
import XCTest
@testable import Hymns

// https://troz.net/post/2020/swiftui_snapshots/
class SettingsSnapshots: XCTestCase {

    var viewModel: SettingsViewModel!

    override func setUp() {
        super.setUp()
        viewModel = SettingsViewModel()
    }

    func test_settings_withDonationOption() {
        let originalValue = UserDefaults.standard.bool(forKey: "show_default_search_type_announcement")
        UserDefaults.standard.setValue(false, forKey: "show_default_search_type_announcement")

        let systemUtil = SystemUtilImpl()
        systemUtil.donationProducts = [MockDonation()]
        viewModel = SettingsViewModel(systemUtil: systemUtil)
        viewModel.settings = [.privacyPolicy, .feedback(.constant(nil)), .aboutUs]
        assertVersionedSnapshot(
            matching: SettingsView(viewModel: viewModel).ignoresSafeArea(),
            as: .swiftUiImage())

        UserDefaults.standard.setValue(originalValue, forKey: "show_default_search_type_announcement")
    }

    func test_settings_withoutDonationOption() {
        let originalValue = UserDefaults.standard.bool(forKey: "show_default_search_type_announcement")
        UserDefaults.standard.setValue(false, forKey: "show_default_search_type_announcement")
        
        viewModel.settings = [.privacyPolicy, .feedback(.constant(nil)), .aboutUs]
        assertVersionedSnapshot(
            matching: SettingsView(viewModel: viewModel).ignoresSafeArea(),
            as: .swiftUiImage())

        UserDefaults.standard.setValue(originalValue, forKey: "show_default_search_type_announcement")
    }

    func test_settings_withDefaultLangaugeTooltip() {
        let originalValue = UserDefaults.standard.bool(forKey: "show_default_search_type_announcement")
        UserDefaults.standard.setValue(true, forKey: "show_default_search_type_announcement")

        viewModel.settings = [.privacyPolicy, .feedback(.constant(nil)), .aboutUs]
        assertVersionedSnapshot(
            matching: SettingsView(viewModel: viewModel).ignoresSafeArea(),
            as: .swiftUiImage())

        UserDefaults.standard.setValue(originalValue, forKey: "show_default_search_type_announcement")
    }
}

class MockDonation: CoffeeDonation {
    var id: String = ""

    func purchase(options: Set<Product.PurchaseOption>) async throws -> PurchaseResultWrapper {
        return .other
    }
}
