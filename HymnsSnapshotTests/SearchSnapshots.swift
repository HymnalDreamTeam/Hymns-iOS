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
        assertSnapshot(viewModel: viewModel)
    }

    func test_recentSongs() {
        viewModel.showSearchByTypeToolTip = false
        viewModel.state = .results
        viewModel.label = "Recent hymns"
        viewModel.songResults = [cupOfChrist_songResult, hymn1151_songResult, hymn1334_songResult]
        assertSnapshot(viewModel: viewModel)
    }

    func test_recentSongs_withToolTip() {
        viewModel.showSearchByTypeToolTip = true
        viewModel.state = .results
        viewModel.label = "Recent hymns"
        viewModel.songResults = [cupOfChrist_songResult, hymn1151_songResult, hymn1334_songResult]
        assertSnapshot(viewModel: viewModel)
    }

    func test_noRecentSongs() {
        viewModel.showSearchByTypeToolTip = false
        viewModel.state = .results
        assertSnapshot(viewModel: viewModel)
    }

    func test_searchActive() {
        viewModel.showSearchByTypeToolTip = false
        viewModel.state = .results
        viewModel.searchActive = true
        assertSnapshot(viewModel: viewModel)
    }

    func test_searchActive_withToolTip() {
        viewModel.showSearchByTypeToolTip = true
        viewModel.state = .results
        viewModel.searchActive = true
        assertSnapshot(viewModel: viewModel)
    }

    func test_loading() {
        viewModel.showSearchByTypeToolTip = false
        viewModel.state = .loading
        viewModel.searchActive = true
        viewModel.searchParameter = "She loves me not"
        assertSnapshot(viewModel: viewModel)
    }

    func test_searchResults() {
        viewModel.showSearchByTypeToolTip = false
        viewModel.state = .results
        viewModel.searchActive = true
        viewModel.searchParameter = "Do you love me?"
        viewModel.songResults = [hymn480_songResult, hymn1334_songResult, hymn1151_songResult]
        assertSnapshot(viewModel: viewModel)
    }

    func test_searchResultsDark() {
        viewModel.showSearchByTypeToolTip = false
        viewModel.state = .results
        viewModel.searchActive = true
        viewModel.searchParameter = "Do you love me?"
        viewModel.songResults = [hymn480_songResult, hymn1334_songResult, hymn1151_songResult]
        let view = NavigationStack {
            SearchView(viewModel: viewModel).ignoresSafeArea()
        }
        assertVersionedSnapshot(matching: view.ignoresSafeArea(),
                                as: .image(layout: .sizeThatFits, traits: .init(userInterfaceStyle: .dark)))
    }

    func test_searchResults_withToolTip() {
        viewModel.showSearchByTypeToolTip = true
        viewModel.state = .results
        viewModel.searchActive = true
        viewModel.searchParameter = "Do you love me?"
        viewModel.songResults = [hymn480_songResult, hymn1334_songResult, hymn1151_songResult]
        assertSnapshot(viewModel: viewModel)
    }

    func test_noResults() {
        viewModel.showSearchByTypeToolTip = false
        viewModel.state = .empty
        viewModel.searchActive = true
        viewModel.searchParameter = "She loves me not"
        assertSnapshot(viewModel: viewModel)
    }

    private func assertSnapshot(viewModel: SearchViewModel,
                                file: StaticString = #file,
                                testName: String = #function,
                                line: UInt = #line) {
        let view = NavigationStack {
            SearchView(viewModel: viewModel).ignoresSafeArea()
        }
        assertVersionedSnapshot(matching: view.ignoresSafeArea(), as: .image(layout: .sizeThatFits), file: file, testName: testName, line: line)
    }
}
