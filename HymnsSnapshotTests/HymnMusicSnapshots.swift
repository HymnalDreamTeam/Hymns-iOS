import PDFKit
import SnapshotTesting
import SwiftUI
import XCTest
@testable import Hymns

// https://troz.net/post/2020/swiftui_snapshots/
class HymnMusicSnapshots: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    func test_empty() {
        let view = HymnMusicView(viewModel: HymnMusicViewModel(musicViews: []))
        assertVersionedSnapshot(matching: view, as: .swiftUiImage(size: CGSize(width: 300, height: 200)))
    }

    func test_pianoOnly() {
        let view = HymnMusicView(viewModel: HymnMusicViewModel(musicViews: [.piano(Text("Piano sheet music here").eraseToAnyView())]))
        assertVersionedSnapshot(matching: view, as: .swiftUiImage(size: CGSize(width: 200, height: 50)))
    }

    func test_guitarOnly() {
        let view = HymnMusicView(viewModel: HymnMusicViewModel(musicViews: [.guitar(Text("Guitar sheet music here").eraseToAnyView())]))
        assertVersionedSnapshot(matching: view, as: .swiftUiImage(size: CGSize(width: 200, height: 50)))
    }

    func test_inlineAndPianoAndGuitar_inlineSelected() {
        let viewModel = HymnMusicViewModel(musicViews: [.inline(Text("Inline chords here").eraseToAnyView()),
                                                        .piano(Text("Piano sheet music here").eraseToAnyView()),
                                                        .guitar(Text("Guitar sheet music here").eraseToAnyView())])
        viewModel.currentTab = .inline(Text("Inline chords here").eraseToAnyView())
        let view = ScrollView(showsIndicators: false) {
            HymnMusicView(viewModel: viewModel)
        }
        assertVersionedSnapshot(matching: view, as: .image(layout: .sizeThatFits))
    }

    func test_pianoAndGuitar_pianoSelected() {
        let viewModel = HymnMusicViewModel(musicViews: [.piano(Text("Piano sheet music here").eraseToAnyView()),
                                                        .guitar(Text("Guitar sheet music here").eraseToAnyView())])
        viewModel.currentTab = .piano(Text("Piano sheet music here").eraseToAnyView())
        let view = ScrollView(showsIndicators: false) {
            HymnMusicView(viewModel: viewModel)
        }
        assertVersionedSnapshot(matching: view, as: .image(layout: .sizeThatFits))
    }

    func test_pianoAndGuitar_guitarSelected() {
        let viewModel = HymnMusicViewModel(musicViews: [.piano(Text("Piano sheet music here").eraseToAnyView()),
                                                        .guitar(Text("Guitar sheet music here").eraseToAnyView())])
        viewModel.currentTab = .guitar(Text("Guitar sheet music here").eraseToAnyView())
        let view = ScrollView(showsIndicators: false) {
            HymnMusicView(viewModel: viewModel)
        }
        assertVersionedSnapshot(matching: view, as: .image(layout: .sizeThatFits))
    }

    func test_inline_selected() {
        let inline = HymnMusicTab.inline(EmptyView().eraseToAnyView())
        assertVersionedSnapshot(matching: inline.selectedLabel, as: .swiftUiImage(size: CGSize(width: 30, height: 30)))
    }

    func test_inline_unselected() {
        let inline = HymnMusicTab.inline(EmptyView().eraseToAnyView())
        assertVersionedSnapshot(matching: inline.selectedLabel, as: .swiftUiImage(size: CGSize(width: 30, height: 30)))
    }

    func test_guitar_selected() {
        let guitar = HymnMusicTab.guitar(EmptyView().eraseToAnyView())
        assertVersionedSnapshot(matching: guitar.selectedLabel, as: .swiftUiImage(size: CGSize(width: 30, height: 30)))
    }

    func test_guitar_unselected() {
        let guitar = HymnMusicTab.guitar(EmptyView().eraseToAnyView())
        assertVersionedSnapshot(matching: guitar.selectedLabel, as: .swiftUiImage(size: CGSize(width: 30, height: 30)))
    }

    func test_piano_selected() {
        let piano = HymnMusicTab.piano(EmptyView().eraseToAnyView())
        assertVersionedSnapshot(matching: piano.selectedLabel, as: .swiftUiImage(size: CGSize(width: 30, height: 30)))
    }

    func test_piano_unselected() {
        let piano = HymnMusicTab.piano(EmptyView().eraseToAnyView())
        assertVersionedSnapshot(matching: piano.selectedLabel, as: .swiftUiImage(size: CGSize(width: 30, height: 30)))
    }
}
