import SnapshotTesting
import SwiftUI
import XCTest
@testable import Hymns

// https://troz.net/post/2020/swiftui_snapshots/
class SearchSnapshots: XCTestCase {

    var viewModel: SearchViewModel!

    override func setUp() {
        super.setUp()
        viewModel = SearchViewModel()
        viewModel.setUp()
    }

    func test_default() {
        viewModel.showSearchByTypeToolTip = false
        assertVersionedSnapshot(matching: SearchView(viewModel: viewModel).ignoresSafeArea(), as: .swiftUiImage())
    }

    func test_recentSongs() {
        viewModel.showSearchByTypeToolTip = false
        viewModel.state = .results
        viewModel.label = "Recent hymns"
        viewModel.songResults = [cupOfChrist_songResult, hymn1151_songResult, hymn1334_songResult]
        assertVersionedSnapshot(matching: SearchView(viewModel: viewModel).ignoresSafeArea(), as: .swiftUiImage())
    }

    func test_recentSongs_withToolTip() {
        viewModel.showSearchByTypeToolTip = true
        viewModel.state = .results
        viewModel.label = "Recent hymns"
        viewModel.songResults = [cupOfChrist_songResult, hymn1151_songResult, hymn1334_songResult]
        assertVersionedSnapshot(matching: SearchView(viewModel: viewModel).ignoresSafeArea(), as: .swiftUiImage())
    }

    func test_noRecentSongs() {
        viewModel.showSearchByTypeToolTip = false
        viewModel.state = .results
        assertVersionedSnapshot(matching: SearchView(viewModel: viewModel).ignoresSafeArea(), as: .swiftUiImage())
    }

    func test_searchActive() {
        viewModel.showSearchByTypeToolTip = false
        viewModel.state = .results
        viewModel.searchActive = true
        assertVersionedSnapshot(matching: SearchView(viewModel: viewModel).ignoresSafeArea(), as: .swiftUiImage())
    }

    func test_searchActive_withToolTip() {
        viewModel.showSearchByTypeToolTip = true
        viewModel.state = .results
        viewModel.searchActive = true
        assertVersionedSnapshot(matching: SearchView(viewModel: viewModel).ignoresSafeArea(), as: .swiftUiImage())
    }

    func test_loading() {
        viewModel.showSearchByTypeToolTip = false
        viewModel.state = .loading
        viewModel.searchActive = true
        viewModel.searchParameter = "She loves me not"
        assertVersionedSnapshot(matching: SearchView(viewModel: viewModel).ignoresSafeArea(), as: .swiftUiImage())
    }

    func test_searchResults() {
        viewModel.showSearchByTypeToolTip = false
        viewModel.state = .results
        viewModel.searchActive = true
        viewModel.searchParameter = "Do you love me?"
        viewModel.songResults = [hymn480_songResult, hymn1334_songResult, hymn1151_songResult]
        assertVersionedSnapshot(matching: SearchView(viewModel: viewModel).ignoresSafeArea(), as: .swiftUiImage())
    }

    func test_searchResults_withToolTip() {
        viewModel.showSearchByTypeToolTip = true
        viewModel.state = .results
        viewModel.searchActive = true
        viewModel.searchParameter = "Do you love me?"
        viewModel.songResults = [hymn480_songResult, hymn1334_songResult, hymn1151_songResult]
        assertVersionedSnapshot(matching: SearchView(viewModel: viewModel).ignoresSafeArea(), as: .swiftUiImage())
    }

    func test_noResults() {
        viewModel.showSearchByTypeToolTip = false
        viewModel.state = .empty
        viewModel.searchActive = true
        viewModel.searchParameter = "She loves me not"
        assertVersionedSnapshot(matching: SearchView(viewModel: viewModel).ignoresSafeArea(), as: .swiftUiImage())
    }
}
