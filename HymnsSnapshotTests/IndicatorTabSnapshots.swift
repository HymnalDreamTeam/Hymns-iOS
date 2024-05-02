import SnapshotTesting
import SwiftUI
import XCTest
@testable import Hymns

// https://troz.net/post/2020/swiftui_snapshots/
class IndicatorTabSnapshots: XCTestCase {

    private let tabs: [HymnTab] = [.lyrics(Text("Lyrics here").eraseToAnyView()), .music(Text("Music here").eraseToAnyView())]

    func test_tabBar_lyricsTabSelected() {
        let lyricsTab: HymnTab = .lyrics(EmptyView().eraseToAnyView())
        let view = TabBar(
            currentTab: .constant(lyricsTab),
            tabItems: [lyricsTab, .music(EmptyView().eraseToAnyView())],
            tabSpacing: .maxWidth,
            showIndicator: true).ignoresSafeArea()
        assertVersionedSnapshot(matching: view, as: .swiftUiImage())
    }

    func test_tabBar_homeTabSelected() {
        var search: HomeTab = .search
        let view = TabBar(
            currentTab: Binding<HomeTab>(
                get: {search},
                set: {search = $0}),
            tabItems: [.search, .browse, .favorites, .settings],
            tabSpacing: .maxWidth,
            showIndicator: true).ignoresSafeArea()
        assertVersionedSnapshot(matching: view, as: .swiftUiImage())
    }

    func test_tabBar_browseTabSelected() {
        var browse: HomeTab = .browse
        let view = TabBar(
            currentTab: Binding<HomeTab>(
                get: {browse},
                set: {browse = $0}),
            tabItems: [.search, .browse, .favorites, .settings],
            tabSpacing: .maxWidth,
            showIndicator: true).ignoresSafeArea()
        assertVersionedSnapshot(matching: view, as: .swiftUiImage())
    }

    func test_tabBar_customSpacing() {
        let lyricsTab: HymnTab = .lyrics(EmptyView().eraseToAnyView())
        let view = TabBar(
            currentTab: .constant(lyricsTab),
            tabItems: [lyricsTab, .music(EmptyView().eraseToAnyView())],
            tabSpacing: .custom(spacing: 0),
            showIndicator: true).ignoresSafeArea()
        assertVersionedSnapshot(matching: view, as: .swiftUiImage())
    }

    func test_tabBar_noIndicator() {
        let lyricsTab: HymnTab = .lyrics(EmptyView().eraseToAnyView())
        let view = TabBar(
            currentTab: .constant(lyricsTab),
            tabItems: [lyricsTab, .music(EmptyView().eraseToAnyView())],
            tabSpacing: .custom(spacing: 5),
            showIndicator: false).ignoresSafeArea()
        assertVersionedSnapshot(matching: view, as: .swiftUiImage())
    }

    func test_tabView_firstTabSelected() {
        let view = ScrollView(showsIndicators: false) {
            IndicatorTabView(currentTab: .constant(self.tabs[0]), tabItems: self.tabs)
        }.ignoresSafeArea()
        assertVersionedSnapshot(matching: view, as: .swiftUiImage())
    }

    func test_tabView_secondTabSelected_noDivider() {
        let view = ScrollView(showsIndicators: false) {
            IndicatorTabView(currentTab: .constant(self.tabs[1]), tabItems: self.tabs, showDivider: false)
        }.ignoresSafeArea()
        assertVersionedSnapshot(matching: view, as: .swiftUiImage())
    }

    func test_tabView_manyTabs() {
        let classic: BrowseTab = .classic(EmptyView().eraseToAnyView())
        let newTunes: BrowseTab = .newTunes(EmptyView().eraseToAnyView())
        let newSongs: BrowseTab = .newSongs(EmptyView().eraseToAnyView())
        let childrens: BrowseTab = .children(EmptyView().eraseToAnyView())
        let scriptures: BrowseTab = .scripture(EmptyView().eraseToAnyView())
        let all: BrowseTab = .all(EmptyView().eraseToAnyView())

        let view = ScrollView(showsIndicators: false) {
            IndicatorTabView(currentTab: .constant(classic),
                             tabItems: [classic, newTunes, newSongs, childrens, scriptures, all])
        }.ignoresSafeArea()
        assertVersionedSnapshot(matching: view, as: .swiftUiImage())
    }

    func test_tabView_iconTabs_onBottom() {
        let view =
            IndicatorTabView<HomeTab>(currentTab: .constant(.search),
                                      tabItems: [.search, .browse, .favorites, .settings], tabAlignment: .bottom).ignoresSafeArea()
        assertVersionedSnapshot(matching: view, as: .swiftUiImage())
    }

    func test_tabView_customSpacing() {
        let view = ScrollView(showsIndicators: false) {
            IndicatorTabView<HymnTab>(currentTab: .constant(.lyrics(EmptyView().eraseToAnyView())),
                                      tabItems: [.lyrics(EmptyView().eraseToAnyView()), .music(EmptyView().eraseToAnyView())],
                                      tabSpacing: .custom(spacing: 0))
        }.ignoresSafeArea()
        assertVersionedSnapshot(matching: view, as: .swiftUiImage())
    }

    func test_tabView_noIndicator() {
        let view = ScrollView(showsIndicators: false) {
            IndicatorTabView<HymnTab>(currentTab: .constant(.lyrics(EmptyView().eraseToAnyView())),
                                      tabItems: [.lyrics(EmptyView().eraseToAnyView()), .music(EmptyView().eraseToAnyView())],
                                      tabSpacing: .custom(spacing: 0),
                                      showIndicator: false)
        }.ignoresSafeArea()
        assertVersionedSnapshot(matching: view, as: .swiftUiImage())
    }
}
