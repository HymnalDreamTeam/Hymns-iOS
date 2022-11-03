import SnapshotTesting
import SwiftUI
import XCTest
@testable import Hymns

// https://troz.net/post/2020/swiftui_snapshots/
class SongInfoDialogSnapshots: XCTestCase {

    let hymn = UiHymn(hymnIdentifier: PreviewHymnIdentifiers.hymn40, title: "", lyrics: nil, author: "MC")
    var viewModel: SongInfoDialogViewModel!

    override func setUp() {
        super.setUp()
        viewModel = SongInfoDialogViewModel(hymnToDisplay: hymn40_identifier, hymn: hymn)!
    }

    func test_songInfo() {
        viewModel.songInfo = [SongInfoViewModel(type: .category, values: ["Worship of the Father"]),
                              SongInfoViewModel(type: .category, values: ["As the Source of Life"]),
                              SongInfoViewModel(type: .category, values: ["Will Jeng", "Titus Ting"])]
        assertVersionedSnapshot(
            matching: SongInfoDialogView(viewModel: viewModel).ignoresSafeArea(),
            as: .swiftUiImage())
    }

    func test_longValues() {
        viewModel.songInfo = [SongInfoViewModel(type: .category, values: ["Worship Worship Worship of of of the the the Father Father Father"]),
                              SongInfoViewModel(type: .subcategory, values: ["As As As the the the Source Source Source of of of Life Life Life"]),
                              SongInfoViewModel(type: .author, values: ["Will Will Will Jeng Jeng Jeng", "Titus Titus Titus Ting Ting Ting"])]
        assertVersionedSnapshot(
            matching: SongInfoDialogView(viewModel: viewModel).ignoresSafeArea(),
            as: .swiftUiImage())
    }
}
