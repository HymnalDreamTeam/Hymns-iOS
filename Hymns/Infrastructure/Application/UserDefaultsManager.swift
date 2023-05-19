import Combine
import Foundation
import SwiftUI

/**
 * Wrapper class for managing `UserDefaults`
 */
class UserDefaultsManager {

    let fontSizeSubject: CurrentValueSubject<Float, Never>

    var fontSize: Float {
        didSet {
            fontSizeSubject.send(fontSize)
            UserDefaults.standard.set(fontSize, forKey: "fontSize")
        }
    }

    @AppStorage("favorites_migrated") var favoritesMigrated = false
    @AppStorage("tags_migrated") var tagsMigrated = false
    @AppStorage("history_migrated") var historyMigrated = false
    @AppStorage("repeat_chorus") var shouldRepeatChorus = false
    @AppStorage("has_seen_soundcloud_minimize_tooltip") var hasSeenSoundCloudMinimizeTooltip = false
    @AppStorage("has_seen_display_hymn_close_tool_tip") var hasSeenDisplayHymnCloseToolTip = false

    init() {
        // Migrate font size to be a float instead of a string
        let initialFontSize: Float
        switch UserDefaults.standard.string(forKey: "fontSize") {
        case "Normal":
            initialFontSize = 17.0
        case "Large":
            initialFontSize = 20.0
        case "Extra Large":
            initialFontSize = 24.0
        default:
            // "Normal" falls into this case.
            if UserDefaults.standard.float(forKey: "fontSize") != 0.0 {
                initialFontSize = UserDefaults.standard.float(forKey: "fontSize")
            } else {
                initialFontSize = 15.0
            }
        }
        UserDefaults.standard.set(initialFontSize, forKey: "fontSize")

        self.fontSize = initialFontSize
        self.fontSizeSubject = CurrentValueSubject<Float, Never>(initialFontSize)
    }
}
