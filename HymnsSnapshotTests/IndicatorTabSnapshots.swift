import SnapshotTesting
import SwiftUI
import XCTest
@testable import Hymns

// https://troz.net/post/2020/swiftui_snapshots/
class IndicatorTabSnapshots: XCTestCase {

    private let tabs: [HymnTab] = [.lyrics(Text("Lyrics here").eraseToAnyView()), .music(Text("Music here").eraseToAnyView())]

    func test_firstTabSelected() {
        assertVersionedSnapshot(matching: IndicatorTabView(currentTab: .constant(self.tabs[0]), tabItems: self.tabs).ignoresSafeArea(),
                                as: .swiftUiImage())
    }

    func test_secondTabSelected_noDivider() {
        assertVersionedSnapshot(matching: IndicatorTabView(currentTab: .constant(self.tabs[1]), tabItems: self.tabs, showDivider: false).ignoresSafeArea(),
                                as: .swiftUiImage())
    }

    func test_manyTabs() {
        let classic: BrowseTab = .classic(EmptyView().eraseToAnyView())
        let newTunes: BrowseTab = .newTunes(EmptyView().eraseToAnyView())
        let newSongs: BrowseTab = .newSongs(EmptyView().eraseToAnyView())
        let childrens: BrowseTab = .children(EmptyView().eraseToAnyView())
        let scriptures: BrowseTab = .scripture(EmptyView().eraseToAnyView())
        let all: BrowseTab = .all(EmptyView().eraseToAnyView())

        let view = IndicatorTabView(currentTab: .constant(classic),
                                   tabItems: [classic, newTunes, newSongs, childrens, scriptures, all])
        assertVersionedSnapshot(matching: view.ignoresSafeArea(), as: .swiftUiImage())
    }

    func test_tabBar_iconTabs_onBottom() {
        let view = IndicatorTabView<HomeTab>(currentTab: .constant(.search),
                                             tabItems: [.search, .browse, .favorites, .settings], tabAlignment: .bottom)
        assertVersionedSnapshot(matching: view.ignoresSafeArea(), as: .swiftUiImage())
    }

    func test_tabBar_customSpacing() {
        let view = IndicatorTabView<HymnTab>(currentTab: .constant(.lyrics(EmptyView().eraseToAnyView())),
                                             tabItems: [.lyrics(EmptyView().eraseToAnyView()), .music(EmptyView().eraseToAnyView())],
                                             tabSpacing: .custom(spacing: 0))
        assertVersionedSnapshot(matching: view.ignoresSafeArea(), as: .swiftUiImage())
    }

    func test_tabBar_noIndicator() {
        let view = IndicatorTabView<HymnTab>(currentTab: .constant(.lyrics(EmptyView().eraseToAnyView())),
                                            tabItems: [.lyrics(EmptyView().eraseToAnyView()), .music(EmptyView().eraseToAnyView())],
                                            tabSpacing: .custom(spacing: 0),
                                            showIndicator: false)
        assertVersionedSnapshot(matching: view.ignoresSafeArea(), as: .swiftUiImage())
    }
}
