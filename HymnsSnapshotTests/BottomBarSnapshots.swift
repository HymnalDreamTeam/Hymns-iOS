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
        let hymn: UiHymn = UiHymn(hymnIdentifier: HymnIdentifier(hymnType: .classic, hymnNumber: "23"), title: "temp", lyrics: [Verse]())
        viewModel = DisplayHymnBottomBarViewModel(hymnToDisplay: PreviewHymnIdentifiers.hymn1151, hymn: hymn)
    }

    func test_noButtons() {
        viewModel.buttons = []
        let bottomBar = DisplayHymnBottomBar(dialogModel: Binding<DialogViewModel<AnyView>?>(
            get: {self.dialog},
            set: {self.dialog = $0}), viewModel: viewModel).padding().ignoresSafeArea()
        assertVersionedSnapshot(matching: bottomBar, as: .image(layout: .fixed(width: 200, height: 50)))
    }

    func test_oneButton() {
        viewModel.buttons = [.tags]

        let bottomBar = DisplayHymnBottomBar(dialogModel: Binding<DialogViewModel<AnyView>?>(
            get: {self.dialog},
            set: {self.dialog = $0}), viewModel: viewModel).padding().ignoresSafeArea()
        assertVersionedSnapshot(matching: bottomBar, as: .image(layout: .sizeThatFits))
    }

    func test_twoButtons() {
        viewModel.buttons = [.tags, .fontSize(FontPickerViewModel())]

        let bottomBar = DisplayHymnBottomBar(dialogModel: Binding<DialogViewModel<AnyView>?>(
            get: {self.dialog},
            set: {self.dialog = $0}), viewModel: viewModel).padding().ignoresSafeArea()
        assertVersionedSnapshot(matching: bottomBar, as: .image(layout: .sizeThatFits))
    }

    func test_maximumButtons() {
        viewModel.buttons = [
            .soundCloud(SoundCloudViewModel(url: URL(string: "https://soundcloud.com/search?q=query")!)),
            .youTube(URL(string: "https://www.youtube.com/results?search_query=search")!),
            .languages([SongResultViewModel(stableId: "empty language view", title: "language", destinationView: EmptyView().eraseToAnyView())]),
            .musicPlayback(AudioPlayerViewModel(url: URL(string: "https://www.hymnal.net/Hymns/NewSongs/mp3/ns0767.mp3")!)),
            .relevant([SongResultViewModel(stableId: "empty relevant view", title: "relevant", destinationView: EmptyView().eraseToAnyView())]),
            .tags,
            .songInfo(SongInfoDialogViewModel(hymnToDisplay: PreviewHymnIdentifiers.hymn1151,
                                              hymn: UiHymn(hymnIdentifier: PreviewHymnIdentifiers.hymn40, title: "", lyrics: nil, author: "MC"))!)
        ]

        let bottomBar = DisplayHymnBottomBar(dialogModel: Binding<DialogViewModel<AnyView>?>(
            get: {self.dialog},
            set: {self.dialog = $0}), viewModel: viewModel).padding().ignoresSafeArea()
        assertVersionedSnapshot(matching: bottomBar, as: .image(layout: .sizeThatFits))
    }

    func test_overflowMenu() {
        viewModel.buttons = [
            .share("lyrics"),
            .fontSize(FontPickerViewModel()),
            .languages([SongResultViewModel(stableId: "empty language view", title: "language", destinationView: EmptyView().eraseToAnyView())]),
            .musicPlayback(AudioPlayerViewModel(url: URL(string: "https://www.hymnal.net/Hymns/NewSongs/mp3/ns0767.mp3")!)),
            .relevant([SongResultViewModel(stableId: "empty relevant view", title: "relevant", destinationView: EmptyView().eraseToAnyView())]),
            .tags
        ]
        viewModel.overflowButtons = [
            .soundCloud(SoundCloudViewModel(url: URL(string: "https://soundcloud.com/search?q=query")!)),
            .youTube(URL(string: "https://www.youtube.com/results?search_query=search")!),
            .songInfo(SongInfoDialogViewModel(hymnToDisplay: PreviewHymnIdentifiers.hymn1151,
                                              hymn: UiHymn(hymnIdentifier: PreviewHymnIdentifiers.hymn40, title: "", lyrics: nil, author: "MC"))!)
        ]

        let bottomBar = DisplayHymnBottomBar(dialogModel: Binding<DialogViewModel<AnyView>?>(
            get: {self.dialog},
            set: {self.dialog = $0}), viewModel: viewModel).padding().ignoresSafeArea()
        assertVersionedSnapshot(matching: bottomBar, as: .image(layout: .sizeThatFits))
    }

    func test_fontSize_selected() {
        let fontSize = BottomBarButton.fontSize(FontPickerViewModel())
        assertVersionedSnapshot(matching: fontSize.selectedLabel, as: .image(layout: .sizeThatFits))
    }

    func test_fontSize_unselected() {
        let fontSize = BottomBarButton.fontSize(FontPickerViewModel())
        assertVersionedSnapshot(matching: fontSize.unselectedLabel, as: .image(layout: .sizeThatFits))
    }

    func test_soundCloud_selected() {
        let soundCloud = BottomBarButton.soundCloud(SoundCloudViewModel(url: URL(string: "http://www.soundcloud.com")!))
        assertVersionedSnapshot(matching: soundCloud.selectedLabel, as: .image(layout: .sizeThatFits))
    }

    func test_soundCloud_unselected() {
        let soundCloud = BottomBarButton.soundCloud(SoundCloudViewModel(url: URL(string: "http://www.soundcloud.com")!))
        assertVersionedSnapshot(matching: soundCloud.unselectedLabel, as: .image(layout: .sizeThatFits))
    }

    func test_youtube_selected() {
        let youtube = BottomBarButton.youTube(URL(string: "http://www.youtube.com")!)
        assertVersionedSnapshot(matching: youtube.selectedLabel, as: .image(layout: .sizeThatFits))
    }

    func test_youtube_unselected() {
        let youtube = BottomBarButton.youTube(URL(string: "http://www.youtube.com")!)
        assertVersionedSnapshot(matching: youtube.unselectedLabel, as: .image(layout: .sizeThatFits))
    }
}
