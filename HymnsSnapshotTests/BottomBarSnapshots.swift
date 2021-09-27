import Foundation
import SnapshotTesting
import SwiftUI
import XCTest
@testable import Hymns

// https://troz.net/post/2020/swiftui_snapshots/
class BottomBarSnapshots: XCTestCase {

    var dialog: DialogViewModel<AnyView>?
    var viewModel: DisplayHymnBottomBarViewModel!

    override func setUp() {
        super.setUp()
        viewModel = DisplayHymnBottomBarViewModel(hymnToDisplay: PreviewHymnIdentifiers.hymn1151)
    }

    func test_noButtons() {
        let bottomBar = DisplayHymnBottomBar(dialogModel: Binding<DialogViewModel<AnyView>?>(
            get: {self.dialog},
            set: {self.dialog = $0}), viewModel: viewModel).padding()
        assertVersionedSnapshot(matching: bottomBar, as: .swiftUiImage())
    }

    func test_oneButton() {
        viewModel.buttons = [.tags]

        let bottomBar = DisplayHymnBottomBar(dialogModel: Binding<DialogViewModel<AnyView>?>(
            get: {self.dialog},
            set: {self.dialog = $0}), viewModel: viewModel).padding()
        assertVersionedSnapshot(matching: bottomBar, as: .image())
    }

    func test_twoButtons() {
        viewModel.buttons = [.tags, .fontSize]

        let bottomBar = DisplayHymnBottomBar(dialogModel: Binding<DialogViewModel<AnyView>?>(
            get: {self.dialog},
            set: {self.dialog = $0}), viewModel: viewModel).padding()
        assertVersionedSnapshot(matching: bottomBar, as: .image())
    }

    func test_maximumButtons() {
        viewModel.buttons = [
            .soundCloud(SoundCloudViewModel(url: URL(string: "https://soundcloud.com/search?q=query")!)),
            .youTube(URL(string: "https://www.youtube.com/results?search_query=search")!),
            .languages([SongResultViewModel(title: "language", destinationView: EmptyView().eraseToAnyView())]),
            .musicPlayback(AudioPlayerViewModel(url: URL(string: "https://www.hymnal.net/Hymns/NewSongs/mp3/ns0767.mp3")!)),
            .relevant([SongResultViewModel(title: "relevant", destinationView: EmptyView().eraseToAnyView())]),
            .tags,
            .songInfo(SongInfoDialogViewModel(hymnToDisplay: PreviewHymnIdentifiers.hymn1151))
        ]

        let bottomBar = DisplayHymnBottomBar(dialogModel: Binding<DialogViewModel<AnyView>?>(
            get: {self.dialog},
            set: {self.dialog = $0}), viewModel: viewModel).padding()
        assertVersionedSnapshot(matching: bottomBar, as: .image(precision: 0.99))
    }

    func test_overflowMenu() {
        viewModel.buttons = [
            .share("lyrics"),
            .fontSize,
            .languages([SongResultViewModel(title: "language", destinationView: EmptyView().eraseToAnyView())]),
            .musicPlayback(AudioPlayerViewModel(url: URL(string: "https://www.hymnal.net/Hymns/NewSongs/mp3/ns0767.mp3")!)),
            .relevant([SongResultViewModel(title: "relevant", destinationView: EmptyView().eraseToAnyView())]),
            .tags
        ]
        viewModel.overflowButtons = [
            .soundCloud(SoundCloudViewModel(url: URL(string: "https://soundcloud.com/search?q=query")!)),
            .youTube(URL(string: "https://www.youtube.com/results?search_query=search")!),
            .songInfo(SongInfoDialogViewModel(hymnToDisplay: PreviewHymnIdentifiers.hymn1151))
        ]

        let bottomBar = DisplayHymnBottomBar(dialogModel: Binding<DialogViewModel<AnyView>?>(
            get: {self.dialog},
            set: {self.dialog = $0}), viewModel: viewModel).padding()
        assertVersionedSnapshot(matching: bottomBar, as: .image())
    }
}
