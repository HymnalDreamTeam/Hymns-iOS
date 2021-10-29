import SnapshotTesting
import SwiftUI
import XCTest
@testable import Hymns

// https://troz.net/post/2020/swiftui_snapshots/
class AboutUsDialogSnapshots: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    func test_dialog() {
        assertVersionedSnapshot(
            matching: AboutUsDialogView().ignoresSafeArea(),
            as: .swiftUiImage())
    }
}
