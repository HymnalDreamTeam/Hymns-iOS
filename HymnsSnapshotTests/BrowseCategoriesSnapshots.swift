import SnapshotTesting
import SwiftUI
import XCTest
@testable import Hymns

// https://troz.net/post/2020/swiftui_snapshots/
class BrowseCategoriesSnapshots: XCTestCase {

    var viewModel: BrowseCategoriesViewModel!

    override func setUp() {
        super.setUp()
        viewModel = BrowseCategoriesViewModel(hymnType: .classic)
    }

    func test_error() {
        viewModel.categories = nil
        assertVersionedSnapshot(
            matching: BrowseCategoriesView(viewModel: viewModel).ignoresSafeArea(),
            as: .swiftUiImage())
    }

    func test_loading() {
        assertVersionedSnapshot(
            matching: BrowseCategoriesView(viewModel: viewModel).ignoresSafeArea(),
            as: .swiftUiImage())
    }

    func test_categories() {
        viewModel = BrowseCategoriesViewModel(hymnType: .german)
        viewModel.categories
            = [CategoryViewModel(category: "Category 1",
                                 hymnType: .german,
                                 subcategories: [SubcategoryViewModel(subcategory: "Subcategory 1", count: 15),
                                                 SubcategoryViewModel(subcategory: "Subcategory 2", count: 2)]),
               CategoryViewModel(category: "Category 2",
                                 hymnType: .german,
                                 subcategories: [SubcategoryViewModel(subcategory: "Subcategory 2", count: 12),
                                                 SubcategoryViewModel(subcategory: "Subcategory 3", count: 1)])]
        assertVersionedSnapshot(
            matching: BrowseCategoriesView(viewModel: viewModel),
            as: .swiftUiImage())
    }

    func test_browseView() {
        assertVersionedSnapshot(
            matching: BrowseView().ignoresSafeArea(),
            as: .swiftUiImage())
    }
}
