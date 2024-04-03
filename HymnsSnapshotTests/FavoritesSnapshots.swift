import SnapshotTesting
import SwiftUI
import XCTest
@testable import Hymns

// https://troz.net/post/2020/swiftui_snapshots/
class FavoritesSnapshots: XCTestCase {

    var viewModel: FavoritesViewModel!

    override func setUp() {
        super.setUp()
        viewModel = FavoritesViewModel()
    }

    func test_loading() {
        assertSnapshot(viewModel: viewModel)
    }

    func test_noFavorites() {
        viewModel.favorites = [SongResultViewModel]()
        assertSnapshot(viewModel: viewModel)
    }

    func test_favorites() {
        viewModel.favorites = [cupOfChrist_songResult, hymn1151_songResult, joyUnspeakable_songResult, sinfulPast_songResult]
        assertSnapshot(viewModel: viewModel)
    }

    private func assertSnapshot(viewModel: FavoritesViewModel,
                                file: StaticString = #file,
                                testName: String = #function,
                                line: UInt = #line) {
        let view = NavigationStack {
            FavoritesView(viewModel: viewModel).ignoresSafeArea()
        }
        assertVersionedSnapshot(matching: view.ignoresSafeArea(), as: .image(layout: .sizeThatFits), file: file, testName: testName, line: line)
    }
}
