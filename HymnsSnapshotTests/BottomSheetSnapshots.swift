import Foundation
import SnapshotTesting
import XCTest
@testable import Hymns

// https://troz.net/post/2020/swiftui_snapshots/
class BottomSheetSnapshots: XCTestCase {

    func test_shareSheet() {
        assertVersionedSnapshot(
            matching: ShareSheet(activityItems: ["share text"]),
            as: .swiftUiImage())
    }
}
