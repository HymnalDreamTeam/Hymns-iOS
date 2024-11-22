import SnapshotTesting
import SwiftUI
import XCTest
@testable import Hymns

// https://troz.net/post/2020/swiftui_snapshots/
class BrowseResultsListSnapshots: XCTestCase {

    var viewModel: BrowseResultsListViewModel!

    func test_loading() {
        viewModel = BrowseResultsListViewModel(tag: UiTag(title: "Best songs", color: .none))
        assertVersionedSnapshot(
            matching: BrowseResultsListView(viewModel: viewModel).ignoresSafeArea(),
            as: .swiftUiImage())
    }

    func test_empty() {
        viewModel = BrowseResultsListViewModel(tag: UiTag(title: "Best songs", color: .none))
        viewModel.songResults = [SingleSongResultViewModel]()
        assertVersionedSnapshot(
            matching: BrowseResultsListView(viewModel: viewModel).ignoresSafeArea(),
            as: .swiftUiImage())
    }

    func test_results() {
        let results = [SingleSongResultViewModel(stableId: "Hymn 114", title: "Hymn 114", destinationView: EmptyView().eraseToAnyView()),
                       SingleSongResultViewModel(stableId: "Cup of Christ", title: "Cup of Christ", destinationView: EmptyView().eraseToAnyView()),
                       SingleSongResultViewModel(stableId: "Avengers - Endgame", title: "Avengers - Endgame", destinationView: EmptyView().eraseToAnyView())]
        viewModel = BrowseResultsListViewModel(category: "Experience of Christ")
        viewModel.songResults = results
        assertVersionedSnapshot(
            matching: BrowseResultsListView(viewModel: viewModel).ignoresSafeArea(),
            as: .swiftUiImage())
    }
}
