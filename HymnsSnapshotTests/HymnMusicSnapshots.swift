import PDFKit
import SnapshotTesting
import SwiftUI
import XCTest
@testable import Hymns

// https://troz.net/post/2020/swiftui_snapshots/
class HymnMusicSnapshots: XCTestCase {

    func test_empty() {
        let view = HymnMusicView(viewModel: HymnMusicViewModel(musicViews: []))
        assertVersionedSnapshot(matching: view, as: .swiftUiImage())
    }

    func test_pianoOnly() {
        let view = HymnMusicView(viewModel: HymnMusicViewModel(musicViews: [.piano(Text("Piano sheet music here").eraseToAnyView())]))
        assertVersionedSnapshot(matching: view, as: .swiftUiImage())
    }

    func test_guitarOnly() {
        let view = HymnMusicView(viewModel: HymnMusicViewModel(musicViews: [.guitar(Text("Guitar sheet music here").eraseToAnyView())]))
        assertVersionedSnapshot(matching: view, as: .swiftUiImage())
    }

    func test_pianoAndGuitar_pianoSelected() {
        let viewModel = HymnMusicViewModel(musicViews: [.piano(Text("Piano sheet music here").eraseToAnyView()),
                                                        .guitar(Text("Guitar sheet music here").eraseToAnyView())])
        viewModel.currentTab = .piano(Text("Piano sheet music here").eraseToAnyView())
        let view = HymnMusicView(viewModel: viewModel)
        assertVersionedSnapshot(matching: view, as: .swiftUiImage())
    }

    func test_pianoAndGuitar_guitarSelected() {
        let viewModel = HymnMusicViewModel(musicViews: [.piano(Text("Piano sheet music here").eraseToAnyView()),
                                                        .guitar(Text("Guitar sheet music here").eraseToAnyView())])
        viewModel.currentTab = .guitar(Text("Guitar sheet music here").eraseToAnyView())
        let view = HymnMusicView(viewModel: viewModel)
        assertVersionedSnapshot(matching: view, as: .swiftUiImage())
    }
}
