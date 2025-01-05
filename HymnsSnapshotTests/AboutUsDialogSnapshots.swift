import PreviewSnapshotsTesting
import SnapshotTesting
import SwiftUI
import XCTest
@testable import Hymns

// https://troz.net/post/2020/swiftui_snapshots/
class AboutUsDialogSnapshots: XCTestCase {

    func test() {
        AboutUsDialogView_Previews.snapshots.assertVersionedSnapshots(as: .swiftUiImage())
    }
}
