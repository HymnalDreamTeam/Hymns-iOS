import SnapshotTesting
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

    func test_settings() {
        viewModel.settings = [.privacyPolicy, .feedback(.constant(nil)), .aboutUs]
        assertVersionedSnapshot(
            matching: SettingsView(viewModel: viewModel).ignoresSafeArea(),
            as: .swiftUiImage())
    }
}
