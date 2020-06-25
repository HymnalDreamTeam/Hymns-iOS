import SnapshotTesting
import SwiftUI
import XCTest
@testable import Hymns

// https://troz.net/post/2020/swiftui_snapshots/
class BrowseResultsListSnapshots: XCTestCase {

    var viewModel: BrowseResultsListViewModel!

    override func setUp() {
        super.setUp()
    }

    func test_empty() {
        viewModel = BrowseResultsListViewModel(tag: UiTag(title: "Best songs", color: .none))
        assertSnapshot(matching: BrowseResultsListView(viewModel: viewModel), as: .image())
    }

    func test_results() {
        let results = [SongResultViewModel(title: "Hymn 114", destinationView: EmptyView().eraseToAnyView()),
                       SongResultViewModel(title: "Cup of Christ", destinationView: EmptyView().eraseToAnyView()),
                       SongResultViewModel(title: "Avengers - Endgame", destinationView: EmptyView().eraseToAnyView())]
        viewModel = BrowseResultsListViewModel(category: "Experience of Christ")
        viewModel.songResults = results
        assertSnapshot(matching: BrowseResultsListView(viewModel: viewModel), as: .image())
    }
}
