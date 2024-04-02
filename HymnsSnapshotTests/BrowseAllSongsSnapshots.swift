import SnapshotTesting
import SwiftUI
import XCTest
@testable import Hymns

// https://troz.net/post/2020/swiftui_snapshots/
class BrowseAllSongsSnapshots: XCTestCase {

    func test_allSongsView() {
        let viewModel = AllSongsViewModel()
        assertVersionedSnapshot(matching: AllSongsView(viewModel: viewModel).ignoresSafeArea(),
                                as: .swiftUiImage())
    }
}
