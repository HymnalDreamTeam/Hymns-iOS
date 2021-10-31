import Foundation
import SnapshotTesting
import XCTest
@testable import Hymns

// https://troz.net/post/2020/swiftui_snapshots/
class BottomSheetSnapshots: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    func test_shareSheet() {
        assertVersionedSnapshot(
            matching: ShareSheet(activityItems: ["share text"]),
            as: .swiftUiImage())
    }

    func test_tagSheet_noTags() {
        let viewModel = TagSheetViewModel(hymnToDisplay: cupOfChrist_identifier)
        assertVersionedSnapshot(
            matching: TagSheetView(viewModel: viewModel, sheet: .constant(.tags)).ignoresSafeArea(),
            as: .swiftUiImage())
    }

    func test_tagSheet_oneTags() {
        let viewModel = TagSheetViewModel(hymnToDisplay: cupOfChrist_identifier)
        viewModel.tags = [UiTag(title: "Lord's table", color: .green)]
        assertVersionedSnapshot(
            matching: TagSheetView(viewModel: viewModel, sheet: .constant(.tags)).ignoresSafeArea(),
            as: .swiftUiImage())
    }

    func test_tagSheet_manyTags() {
        let viewModel = TagSheetViewModel(hymnToDisplay: cupOfChrist_identifier)
        viewModel.tags = [UiTag(title: "Long tag name", color: .none),
                          UiTag(title: "Tag 1", color: .green),
                          UiTag(title: "Tag 1", color: .red),
                          UiTag(title: "Tag 1", color: .yellow),
                          UiTag(title: "Tag 2", color: .blue),
                          UiTag(title: "Tag 3", color: .blue)]
        assertVersionedSnapshot(
            matching: TagSheetView(viewModel: viewModel, sheet: .constant(.tags)).ignoresSafeArea(),
            as: .swiftUiImage())
    }

    func test_songInfo_empty() {
        let viewModel = SongInfoDialogViewModel(hymnToDisplay: cupOfChrist_identifier)
        assertVersionedSnapshot(
            matching: SongInfoDialogView(viewModel: viewModel),
            as: .image(layout: .fixed(width: 250, height: 300)))
    }

    func test_songInfo_regularValues() {
        let viewModel = SongInfoDialogViewModel(hymnToDisplay: cupOfChrist_identifier)
        viewModel.songInfo = [SongInfoViewModel(label: "Category", values: ["Worship of the Father"]),
                              SongInfoViewModel(label: "Subcategory", values: ["As the Source of Life"]),
                              SongInfoViewModel(label: "Author", values: ["Will Jeng", "Titus Ting"])]
        assertVersionedSnapshot(
            matching: SongInfoDialogView(viewModel: viewModel).ignoresSafeArea(),
            as: .swiftUiImage())
    }

    func test_songInfo_longValues() {
        let viewModel = SongInfoDialogViewModel(hymnToDisplay: cupOfChrist_identifier)
        viewModel.songInfo = [SongInfoViewModel(label: "CategoryCategoryCategory", values: ["Worship Worship Worship of of of the the the Father Father Father"]),
                              SongInfoViewModel(label: "SubcategorySubcategorySubcategory", values: ["As As As the the the Source Source Source of of of Life Life Life"]),
                              SongInfoViewModel(label: "AuthorAuthorAuthor", values: ["Will Will Will Jeng Jeng Jeng", "Titus Titus Titus Ting Ting Ting"])]
        assertVersionedSnapshot(
            matching: SongInfoDialogView(viewModel: viewModel).ignoresSafeArea(),
            as: .swiftUiImage())
    }
}
