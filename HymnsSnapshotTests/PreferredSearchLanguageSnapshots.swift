import SnapshotTesting
import SwiftUI
import XCTest
@testable import Hymns

// https://troz.net/post/2020/swiftui_snapshots/
// swiftlint:disable:next type_name
class PreferredSearchLanguageSnapshots: XCTestCase {

    private var originalPreferredSearchLanguage: Language?
    // swiftlint:disable:next identifier_name
    private var originalShowPreferredSearchLanguageAnnouncementValue: Bool?

    override func setUp() {
        super.setUp()
        originalPreferredSearchLanguage = Language(rawValue: UserDefaults.standard.integer(forKey: "preferred_search_language"))
        UserDefaults.standard.setValue(Language.english.rawValue, forKey: "preferred_search_language")

        originalShowPreferredSearchLanguageAnnouncementValue = UserDefaults.standard.bool(forKey: "show_preferred_search_language_announcement")
        UserDefaults.standard.setValue(false, forKey: "show_preferred_search_language_announcement")
    }

    override func tearDown() {
        originalPreferredSearchLanguage.map { UserDefaults.standard.setValue($0.rawValue, forKey: "preferred_search_language") }
        originalPreferredSearchLanguage = nil

        originalShowPreferredSearchLanguageAnnouncementValue.map { UserDefaults.standard.setValue($0, forKey: "show_preferred_search_language_announcement") }
        originalShowPreferredSearchLanguageAnnouncementValue = nil
    }

    func test_default() {
        assertVersionedSnapshot(
            matching: PreferredSearchLanguageView().ignoresSafeArea(),
            as: .swiftUiImage())
    }

    func test_chineseSimplified() {
        UserDefaults.standard.setValue(Language.chineseSimplified.rawValue, forKey: "preferred_search_language")
        assertVersionedSnapshot(
            matching: PreferredSearchLanguageView().ignoresSafeArea(),
            as: .swiftUiImage())
    }

    func test_showPreferredSearchLanguageAnnouncement() {
        UserDefaults.standard.setValue(true, forKey: "show_preferred_search_language_announcement")
        assertVersionedSnapshot(
            matching: PreferredSearchLanguageView().ignoresSafeArea(),
            as: .swiftUiImage())
    }
}
