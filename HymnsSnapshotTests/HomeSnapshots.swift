import SnapshotTesting
import SwiftUI
import XCTest
@testable import Hymns

// https://troz.net/post/2020/swiftui_snapshots/
class HomeSnapshots: XCTestCase {
    
    private var originalHasSeenSearchByTooltip: Bool?
    private var originalShowPreferredSearchLanguageAnnouncementValue: Bool?

    override func setUp() {
        super.setUp()
        originalHasSeenSearchByTooltip = UserDefaults.standard.bool(forKey: "has_seen_search_by_type_tooltip")
        UserDefaults.standard.setValue(false, forKey: "has_seen_search_by_type_tooltip")

        originalShowPreferredSearchLanguageAnnouncementValue = UserDefaults.standard.bool(forKey: "show_preferred_search_language_announcement")
        UserDefaults.standard.setValue(true, forKey: "show_preferred_search_language_announcement")
    }

    override func tearDown() {
        originalHasSeenSearchByTooltip.map { UserDefaults.standard.setValue($0, forKey: "has_seen_search_by_type_tooltip") }
        originalHasSeenSearchByTooltip = nil

        originalShowPreferredSearchLanguageAnnouncementValue.map { UserDefaults.standard.setValue($0, forKey: "show_preferred_search_language_announcement") }
        originalShowPreferredSearchLanguageAnnouncementValue = nil
    }

    func test_default() {
        assertVersionedSnapshot(
            matching: HomeContainerView().ignoresSafeArea(),
            as: .swiftUiImage())
    }

    func test_announcementsOff() {
        UserDefaults.standard.setValue(true, forKey: "has_seen_search_by_type_tooltip")
        UserDefaults.standard.setValue(false, forKey: "show_preferred_search_language_announcement")
        assertVersionedSnapshot(
            matching: HomeContainerView().ignoresSafeArea(),
            as: .swiftUiImage())
    }
}
