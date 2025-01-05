import SnapshotTesting
import SwiftUI
import XCTest
@testable import Hymns

// https://troz.net/post/2020/swiftui_snapshots/
class AudioPlayerSnapshots: XCTestCase {

    func test() {
        AudioView_Previews.snapshots.assertVersionedSnapshots(
            as: .swiftUiImage(size: CGSize(width: 400, height: 100)))
    }
}
