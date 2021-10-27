import SnapshotTesting
import SwiftUI
import XCTest
@testable import Hymns

// https://troz.net/post/2020/swiftui_snapshots/
class TagSheetSnapshots: XCTestCase {

    var viewModel: TagSheetViewModel!

    override func setUp() {
        super.setUp()
    }

    func test_noTags() {
        viewModel = TagSheetViewModel(hymnToDisplay: cupOfChrist_identifier)
        assertVersionedSnapshot(matching: TagSheetView(viewModel: viewModel, sheet: Binding.constant(.tags)).ignoresSafeArea(), as: .swiftUiImage())
    }

    func test_oneTag() {
        viewModel = TagSheetViewModel(hymnToDisplay: cupOfChrist_identifier)
        viewModel.tags = [UiTag(title: "Lord's table", color: .green)]
        assertVersionedSnapshot(matching: TagSheetView(viewModel: viewModel, sheet: Binding.constant(.tags)).ignoresSafeArea(), as: .swiftUiImage())
    }

    func test_manyTags() {
        viewModel = TagSheetViewModel(hymnToDisplay: cupOfChrist_identifier)
        viewModel.tags = [UiTag(title: "Long tag name", color: .none),
                          UiTag(title: "Tag 1", color: .green),
                          UiTag(title: "Tag 1", color: .red),
                          UiTag(title: "Tag 1", color: .yellow),
                          UiTag(title: "Tag 2", color: .blue),
                          UiTag(title: "Tag 3", color: .blue)]
        assertVersionedSnapshot(matching: TagSheetView(viewModel: viewModel, sheet: Binding.constant(.tags)).ignoresSafeArea(), as: .swiftUiImage())
    }

    func test_colorSeletor_unselected() {
        assertVersionedSnapshot(matching: ColorSelectorView(tagColor: .constant(.none)).ignoresSafeArea(), as: .swiftUiImage())
    }

    func test_colorSeletor_blueSelected() {
        assertVersionedSnapshot(matching: ColorSelectorView(tagColor: .constant(.blue)).ignoresSafeArea(), as: .swiftUiImage())
    }
}
