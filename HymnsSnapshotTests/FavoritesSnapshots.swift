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
        assertVersionedSnapshot(matching: FavoritesView(viewModel: viewModel).ignoresSafeArea(), as: .swiftUiImage())
    }

    func test_noFavorites() {
        viewModel.favorites = [SongResultViewModel]()
        assertVersionedSnapshot(matching: FavoritesView(viewModel: viewModel).ignoresSafeArea(), as: .swiftUiImage())
    }

    func test_searchActive() {
        viewModel.favorites = [cupOfChrist_songResult, hymn1151_songResult, joyUnspeakable_songResult, sinfulPast_songResult]
        assertVersionedSnapshot(matching: FavoritesView(viewModel: viewModel).ignoresSafeArea(), as: .swiftUiImage())
    }
}
