import SnapshotTesting
import SwiftUI
import XCTest
@testable import Hymns

// https://troz.net/post/2020/swiftui_snapshots/
class BrowseScripturesSnapshots: XCTestCase {

    var viewModel: BrowseScripturesViewModel!

    override func setUp() {
        super.setUp()
        viewModel = BrowseScripturesViewModel()
    }

    func test_error() {
        viewModel.scriptures = nil
        assertVersionedSnapshot(
            matching: BrowseScripturesView(viewModel: viewModel).ignoresSafeArea(),
            as: .image(layout: .sizeThatFits))
    }

    func test_loading() {
        assertVersionedSnapshot(
            matching: BrowseScripturesView(viewModel: viewModel).ignoresSafeArea(),
            as: .image(layout: .sizeThatFits))
    }

    func test_scriptures() {
        viewModel.scriptures
            = [ScriptureViewModel(book: .genesis,
                                  scriptureSongs: [ScriptureSongViewModel(reference: "1:1", title: "Tree of life", hymnIdentifier: cupOfChrist_identifier),
                                                   ScriptureSongViewModel(reference: "1:26", title: "God created man", hymnIdentifier: hymn1151_identifier)]),
               ScriptureViewModel(book: .revelation,
                                  scriptureSongs: [ScriptureSongViewModel(reference: "13:5", title: "White horse?", hymnIdentifier: hymn40_identifier)])]
        assertVersionedSnapshot(
            matching: BrowseScripturesView(viewModel: viewModel).ignoresSafeArea(),
            as: .image(layout: .sizeThatFits))
    }

    func test_scripture_song_medium() {
        let viewModel = ScriptureSongViewModel(reference: "1:19", title: "And we have the prophetic word",
                                               hymnIdentifier: PreviewHymnIdentifiers.cupOfChrist)
        assertVersionedSnapshot(
            matching: ScriptureSongView(viewModel: viewModel)
                .environment(\.sizeCategory, .medium)
                .ignoresSafeArea(),
            as: .swiftUiImage(size: CGSize(width: 400, height: 200)))
    }

    func test_scripture_song_extraExtraExtraLarge() {
        let viewModel = ScriptureSongViewModel(reference: "1:19", title: "And we have the prophetic word",
                                               hymnIdentifier: PreviewHymnIdentifiers.cupOfChrist)
        assertVersionedSnapshot(
            matching: ScriptureSongView(viewModel: viewModel)
                .environment(\.sizeCategory, .extraExtraExtraLarge)
                .ignoresSafeArea(),
            as: .swiftUiImage(size: CGSize(width: 400, height: 200)))
    }

    func test_scripture_song_accessibilityMedium() {
        let viewModel = ScriptureSongViewModel(reference: "1:19", title: "And we have the prophetic word",
                                               hymnIdentifier: PreviewHymnIdentifiers.cupOfChrist)
        assertVersionedSnapshot(
            matching: ScriptureSongView(viewModel: viewModel)
                .environment(\.sizeCategory, .accessibilityMedium)
                .ignoresSafeArea(),
            as: .swiftUiImage(size: CGSize(width: 400, height: 200)))
    }

    func test_scripture_song_accessibilityExtraExtraExtraLarge() {
        let viewModel = ScriptureSongViewModel(reference: "1:19", title: "And we have the prophetic word",
                                               hymnIdentifier: PreviewHymnIdentifiers.cupOfChrist)
        assertVersionedSnapshot(
            matching: ScriptureSongView(viewModel: viewModel)
                .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
                .ignoresSafeArea(),
            as: .swiftUiImage(size: CGSize(width: 400, height: 200)))
    }
}
