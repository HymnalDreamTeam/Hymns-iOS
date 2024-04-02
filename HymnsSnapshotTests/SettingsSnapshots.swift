import SnapshotTesting
import StoreKit
import SwiftUI
import XCTest
@testable import Hymns

// https://troz.net/post/2020/swiftui_snapshots/
class SettingsSnapshots: XCTestCase {

    var viewModel: SettingsViewModel!

    private var originalShowPreferredSearchLanguageValue: Bool?

    override func setUp() {
        super.setUp()
        originalShowPreferredSearchLanguageValue = UserDefaults.standard.bool(forKey: "show_preferred_search_language_announcement")
        UserDefaults.standard.setValue(false, forKey: "show_preferred_search_language_announcement")

        viewModel = SettingsViewModel()
    }

    override func tearDown() {
        originalShowPreferredSearchLanguageValue.map { UserDefaults.standard.setValue($0, forKey: "show_preferred_search_language_announcement") }
        originalShowPreferredSearchLanguageValue = nil
    }

    func test_settings_withDonationOption() {
        let systemUtil = SystemUtilImpl()
        systemUtil.donationProducts = [MockDonation()]
        viewModel = SettingsViewModel(systemUtil: systemUtil)
        viewModel.settings = [.privacyPolicy, .feedback(.constant(nil)), .aboutUs]
        assertVersionedSnapshot(
            matching: SettingsView(viewModel: viewModel).ignoresSafeArea(),
            as: .swiftUiImage())
    }

    func test_settings_withoutDonationOption() {
        viewModel.settings = [.privacyPolicy, .feedback(.constant(nil)), .aboutUs]
        assertVersionedSnapshot(
            matching: SettingsView(viewModel: viewModel).ignoresSafeArea(),
            as: .swiftUiImage())
    }

    func test_settings_withDefaultLangaugeTooltip() {
        UserDefaults.standard.setValue(true, forKey: "show_preferred_search_language_announcement")

        viewModel.settings = [.privacyPolicy, .feedback(.constant(nil)), .aboutUs]
        assertVersionedSnapshot(
            matching: SettingsView(viewModel: viewModel).ignoresSafeArea(),
            as: .swiftUiImage())
    }
}

class MockDonation: CoffeeDonation {
    var id: String = ""

    func purchase(options: Set<Product.PurchaseOption>) async throws -> PurchaseResultWrapper {
        return .other
    }
}
