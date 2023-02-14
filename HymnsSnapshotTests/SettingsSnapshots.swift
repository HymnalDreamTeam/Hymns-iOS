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
}

class MockDonation: CoffeeDonation {
    var id: String = ""

    func purchase(options: Set<Product.PurchaseOption>) async throws -> PurchaseResultWrapper {
        return .other
    }
}
